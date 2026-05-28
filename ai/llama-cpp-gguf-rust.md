# llama.cpp + GGUF + Rust 本地模型应用方案

本文整理使用 `llama.cpp`、GGUF 量化模型和 Rust 构建本地大模型应用的方案，适合本地聊天助手、本地知识库问答、离线文档总结、设备说明书问答、工业/电网/指挥类边缘终端等场景。

核心思路是：模型以 GGUF 文件存放在本地，`llama.cpp` 负责推理，Rust 负责模型进程管理、HTTP 封装、RAG 检索、权限控制、配置管理和桌面/边缘应用集成。

## 推荐架构

```text
┌──────────────────────────┐
│  Tauri / Web / CLI 前端   │
└────────────┬─────────────┘
             │ HTTP / Command
┌────────────▼─────────────┐
│      Rust 本地服务        │
│  axum API / 配置 / 日志   │
│  RAG / 缓存 / 权限控制    │
└────────────┬─────────────┘
             │ localhost HTTP
┌────────────▼─────────────┐
│     llama-server          │
│  GGUF 模型推理 / 流式输出 │
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│ models/*.gguf 本地模型文件│
└──────────────────────────┘
```

## 目录结构建议

```text
edge-llm-app/
├── Cargo.toml
├── config/
│   └── app.toml
├── models/
│   ├── qwen3-1.7b-q4_k_m.gguf
│   └── bge-small-zh.onnx
├── bin/
│   └── llama-server
├── data/
│   ├── docs/
│   ├── vector-store/
│   └── logs/
└── src/
    ├── main.rs
    ├── config.rs
    ├── llama_process.rs
    ├── llama_client.rs
    ├── chat_api.rs
    ├── rag.rs
    └── health.rs
```

## 应用配置示例

```toml
[llama]
server_path = "bin/llama-server"
model_path = "models/qwen3-1.7b-q4_k_m.gguf"
host = "127.0.0.1"
port = 8080
ctx_size = 8192
threads = 8
gpu_layers = 0

[generation]
temperature = 0.7
top_p = 0.9
max_tokens = 1024
repeat_penalty = 1.1

[rag]
enabled = true
embedding_model = "models/bge-small-zh.onnx"
top_k = 5
```

## llama-server 启动参数

```bash
./bin/llama-server \
  -m models/qwen3-1.7b-q4_k_m.gguf \
  --host 127.0.0.1 \
  --port 8080 \
  -c 8192 \
  -t 8 \
  -ngl 0
```

常用参数：
- `-m`: GGUF 模型文件路径。
- `-c`: 上下文长度，常见为 `4096`、`8192`、`32768`。
- `-t`: CPU 推理线程数，通常设置为物理核心数附近。
- `-ngl`: GPU offload 层数，CPU 纯推理设为 `0`；Metal/CUDA 可逐步调大。
- `--host 127.0.0.1`: 只监听本机，避免边缘设备暴露推理服务。

## Rust 管理 llama-server 子进程

```rust
use anyhow::Result;
use std::process::{Child, Command, Stdio};

pub struct LlamaServer {
    child: Child,
}

impl LlamaServer {
    pub fn start(server_path: &str, model_path: &str, port: u16) -> Result<Self> {
        let child = Command::new(server_path)
            .args([
                "-m",
                model_path,
                "--host",
                "127.0.0.1",
                "--port",
                &port.to_string(),
                "-c",
                "8192",
                "-t",
                "8",
            ])
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;

        Ok(Self { child })
    }
}

impl Drop for LlamaServer {
    fn drop(&mut self) {
        let _ = self.child.kill();
    }
}
```

## Rust 调用 llama-server 聊天接口

```rust
use anyhow::Result;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::json;

#[derive(Debug, Serialize, Deserialize)]
pub struct ChatMessage {
    pub role: String,
    pub content: String,
}

pub async fn chat(messages: Vec<ChatMessage>) -> Result<String> {
    let client = Client::new();
    let resp = client
        .post("http://127.0.0.1:8080/v1/chat/completions")
        .json(&json!({
            "messages": messages,
            "temperature": 0.7,
            "top_p": 0.9,
            "max_tokens": 1024,
            "stream": false
        }))
        .send()
        .await?
        .json::<serde_json::Value>()
        .await?;

    let content = resp["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or_default()
        .to_string();

    Ok(content)
}
```

## 本地 RAG 组合建议

```text
文档导入 → 文本切分 → Embedding(ONNX/Candle) → 本地向量库
用户问题 → Embedding → TopK 召回 → 拼接上下文 → llama.cpp 生成答案
```

可选组件：
- Embedding：`bge-small-zh`、`bge-m3`、`e5-small`。
- 向量库：SQLite + sqlite-vss、Qdrant 本地版、LanceDB、sled/rocksdb 自建。
- 重排：小型 reranker 可选，边缘设备资源紧张时可先不做。

## 落地优先级

1. 先用 `llama-server` + 单个 GGUF 模型跑通本地聊天。
2. Rust 只做 HTTP client，验证提示词、上下文长度和推理速度。
3. 增加 `axum` 本地 API，统一封装 `/chat`、`/health`、`/models`。
4. 增加模型配置、模型 hash 校验、启动预热和错误恢复。
5. 增加 RAG：本地文档切分、Embedding、召回、上下文拼接。
6. 最后再做 Tauri 桌面端、系统托盘、模型下载器和自动更新。

## 设备与模型大小建议

| 设备资源 | 推荐模型 | 量化建议 | 典型用途 |
| --- | --- | --- | --- |
| 4GB 内存 | 0.5B / 1B | Q4_K_M | 简单问答、命令解释、分类 |
| 8GB 内存 | 1.5B / 3B | Q4_K_M / Q5_K_M | 本地助手、短文总结、轻量 RAG |
| 16GB 内存 | 7B / 8B | Q4_K_M | 文档问答、代码解释、复杂摘要 |
| 32GB+ 内存 | 14B / 32B | Q4_K_M / Q5_K_M | 更高质量问答、复杂推理 |

## 常见 GGUF 模型下载地址

GGUF 模型建议优先下载 `Q4_K_M` 或 `Q5_K_M` 量化版本。`Q4_K_M` 更省内存，`Q5_K_M` 质量略好但更占内存。

| 模型 | 推荐文件关键词 | 适合设备 | 下载地址 |
| --- | --- | --- | --- |
| Qwen3 0.6B GGUF | `Q4_K_M` / `Q5_K_M` | 4GB 内存、低功耗设备 | [Qwen GGUF](https://huggingface.co/Qwen) |
| Qwen3 1.7B GGUF | `Q4_K_M` / `Q5_K_M` | 8GB 内存、本地助手 | [Qwen GGUF](https://huggingface.co/Qwen) |
| Qwen3 4B GGUF | `Q4_K_M` | 12GB+ 内存、轻量 RAG | [Qwen GGUF](https://huggingface.co/Qwen) |
| Qwen2.5 1.5B Instruct GGUF | `Q4_K_M` / `Q5_K_M` | 中文问答、低资源边缘端 | [Qwen GGUF](https://huggingface.co/Qwen) |
| Qwen2.5 7B Instruct GGUF | `Q4_K_M` | 16GB 内存、中文知识库 | [Qwen GGUF](https://huggingface.co/Qwen) |
| DeepSeek-R1 Distill Qwen 1.5B GGUF | `Q4_K_M` | 轻量推理、数学/代码入门 | [DeepSeek AI](https://huggingface.co/deepseek-ai) / [Unsloth GGUF](https://huggingface.co/unsloth) |
| DeepSeek-R1 Distill Qwen 7B GGUF | `Q4_K_M` | 本地推理、复杂问答 | [DeepSeek AI](https://huggingface.co/deepseek-ai) / [Unsloth GGUF](https://huggingface.co/unsloth) |
| Llama 3.2 1B Instruct GGUF | `Q4_K_M` | 英文轻量助手 | [Meta Llama](https://www.llama.com/) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Llama 3.2 3B Instruct GGUF | `Q4_K_M` | 英文本地聊天、摘要 | [Meta Llama](https://www.llama.com/) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Llama 3.1 8B Instruct GGUF | `Q4_K_M` | 英文文档问答、代码解释 | [Meta Llama](https://www.llama.com/) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Mistral 7B Instruct GGUF | `Q4_K_M` | 英文问答、摘要、Agent | [Mistral AI](https://huggingface.co/mistralai) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Phi-3.5 Mini Instruct GGUF | `Q4_K_M` | 小模型推理、代码和英文任务 | [Microsoft](https://huggingface.co/microsoft) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Gemma 2 2B IT GGUF | `Q4_K_M` / `Q5_K_M` | 低资源本地助手 | [Google](https://huggingface.co/google) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Gemma 2 9B IT GGUF | `Q4_K_M` | 16GB+ 内存、本地通用问答 | [Google](https://huggingface.co/google) / [bartowski GGUF](https://huggingface.co/bartowski) |
| Yi 6B Chat GGUF | `Q4_K_M` | 中英文问答、知识库助手 | [01-ai](https://huggingface.co/01-ai) / [GGUF 搜索](https://huggingface.co/models?search=Yi%20GGUF) |
| MiniCPM 2B / 4B GGUF | `Q4_K_M` | 轻量中文助手、端侧应用 | [OpenBMB](https://huggingface.co/openbmb) / [GGUF 搜索](https://huggingface.co/models?search=MiniCPM%20GGUF) |

## 下载方式示例

```bash
# 使用 huggingface-cli 下载指定仓库到本地目录。
huggingface-cli download Qwen/Qwen3-1.7B-GGUF \
  --local-dir models/qwen3-1.7b \
  --local-dir-use-symlinks False
```

```bash
# 如果使用 Ollama，可先拉取模型，再通过 Ollama 运行。
ollama pull qwen3:1.7b
ollama run qwen3:1.7b
```

## 下载注意事项

- Hugging Face 上的 GGUF 仓库命名会变化，找不到精确仓库时可在模型页搜索 `GGUF`、`Q4_K_M`。
- Llama、Gemma 等模型可能需要接受模型 license 后才能下载。
- 第三方 GGUF 量化仓库常见维护者包括 `bartowski`、`unsloth`、`lmstudio-community`，下载前需确认来源可信和 license 兼容。
- 边缘设备建议保留模型文件 hash，启动时做完整性校验。

## 常见问题

- **模型加载慢**：启动时预热，或在桌面应用启动后后台加载。
- **内存不足**：换更小模型或更低量化，如从 Q5 换到 Q4。
- **回答太慢**：减少上下文长度，降低输出 token，调整线程数或启用 GPU offload。
- **中文效果不好**：优先选 Qwen、DeepSeek Distill、Yi 等中文能力较强模型。
- **RAG 答案幻觉**：限制只基于检索上下文回答，并展示引用片段。
