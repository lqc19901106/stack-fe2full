# Candle + Rust 本地 LLM 应用方案

本文整理使用 Candle 和 Rust 构建本地 LLM 应用的方案。Candle 是 Hugging Face 推出的 Rust 机器学习框架，适合在 Rust 应用内直接加载 `safetensors` 权重、Tokenizer 和模型配置，构建本地聊天、Embedding、RAG、文本分类和边缘端推理能力。

与 `llama.cpp + GGUF` 相比，Candle 更适合希望保持 Rust 原生工程结构、直接使用 Hugging Face 模型文件、同时管理 LLM 与 Embedding 模型的项目；如果目标是最快跑通量化大模型，GGUF 路线通常更简单。

## 适合场景

- **Rust 原生应用**：不希望额外维护 `llama-server` 子进程。
- **Embedding / RAG**：本地加载 BGE、E5、MiniLM 等向量模型。
- **小语言模型推理**：运行 Qwen、Phi、Llama、Mistral、Gemma 等小参数模型。
- **边缘端服务**：在工控机、网关、桌面端或嵌入式 Linux 上提供本地推理 API。
- **模型可控场景**：需要精细控制 tokenizer、采样、缓存、batch、设备后端和推理流程。

## Candle 与 llama.cpp 对比

| 维度 | Candle + Rust | llama.cpp + GGUF |
| --- | --- | --- |
| 工程形态 | Rust 原生库，嵌入应用内部 | 独立推理引擎，可走 CLI/HTTP/FFI |
| 模型格式 | `safetensors`、`tokenizer.json`、`config.json` | `.gguf` |
| 上手速度 | 需要写模型加载和推理逻辑 | 量化模型生态成熟，上手更快 |
| Rust 集成 | 最自然 | HTTP/子进程最简单，FFI 较复杂 |
| Embedding | 很适合 | 不是主要优势 |
| LLM 量化生态 | 相对弱 | 很强 |
| 适合产品 | Rust 原生推理服务、Embedding/RAG、可控推理管线 | 本地聊天助手、端侧大模型、快速验证 |

## 推荐架构

```text
┌─────────────────────────────┐
│  Tauri / Web / CLI / Edge    │
└──────────────┬──────────────┘
               │ HTTP / Command
┌──────────────▼──────────────┐
│        Rust 应用服务         │
│ axum API / 配置 / 日志 / RAG │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│      Candle 推理模块         │
│ LLM / Embedding / Classifier │
└──────────────┬──────────────┘
               │
┌──────────────▼──────────────┐
│ models/* safetensors/tokenizer│
└─────────────────────────────┘
```

## 目录结构建议

```text
candle-local-llm/
├── Cargo.toml
├── config/
│   └── app.toml
├── models/
│   ├── llm/
│   │   ├── config.json
│   │   ├── tokenizer.json
│   │   └── model.safetensors
│   └── embedding/
│       ├── config.json
│       ├── tokenizer.json
│       └── model.safetensors
├── data/
│   ├── docs/
│   ├── vector-store/
│   └── logs/
└── src/
    ├── main.rs
    ├── config.rs
    ├── device.rs
    ├── tokenizer.rs
    ├── llm.rs
    ├── embedding.rs
    ├── sampler.rs
    ├── rag.rs
    └── api.rs
```

## 核心依赖

```toml
[dependencies]
anyhow = "1"
tokenizers = "0.20"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
toml = "0.8"
tokio = { version = "1", features = ["full"] }
axum = "0.7"

candle-core = "0.8"
candle-nn = "0.8"
candle-transformers = "0.8"
```

如果需要 CUDA、Metal 等加速，需要按 Candle 官方文档启用对应 feature 和系统依赖。

## 应用配置示例

```toml
[model]
llm_dir = "models/llm"
embedding_dir = "models/embedding"
device = "cpu" # cpu / cuda / metal
dtype = "f16"

[generation]
max_tokens = 512
temperature = 0.7
top_p = 0.9
repeat_penalty = 1.1

[rag]
enabled = true
chunk_size = 800
chunk_overlap = 120
top_k = 5
```

## 模型文件准备

Candle 通常需要以下文件：

```text
models/llm/
├── config.json
├── tokenizer.json
├── tokenizer_config.json
├── generation_config.json
└── model.safetensors
```

如果模型权重被切分，可能是：

```text
model-00001-of-00002.safetensors
model-00002-of-00002.safetensors
model.safetensors.index.json
```

常见来源：
- Hugging Face 模型仓库：`Qwen`、`microsoft`、`google`、`mistralai`、`BAAI`、`intfloat`。
- ModelScope：国内下载体验通常更稳定。

## 模型文件作用说明

Candle 加载本地模型时，最关键的是把「模型结构配置」「分词器」「权重文件」「生成参数」对应起来。不同模型仓库文件名会略有差异，但作用基本一致。

| 文件 | 是否必需 | 作用 | Candle 使用方式 |
| --- | --- | --- | --- |
| `config.json` | 必需 | 定义模型结构，例如 hidden size、层数、attention heads、vocab size、rope 参数、模型类型等 | 读取后构建对应的模型结构，如 Qwen、Llama、Phi、BERT |
| `model.safetensors` | 必需 | 模型权重文件，保存每一层的张量参数 | 通过 `safetensors` 加载到 `VarBuilder` 或权重映射中 |
| `model-00001-of-000xx.safetensors` | 大模型常见 | 分片权重，单个权重过大时拆成多个文件 | 需要结合 `model.safetensors.index.json` 逐片加载 |
| `model.safetensors.index.json` | 分片时必需 | 记录每个权重张量所在的分片文件 | 根据 index 找到权重名与文件的映射 |
| `tokenizer.json` | 必需 | 分词器核心文件，定义 token 规则、词表、BPE/SentencePiece 规则、特殊 token | 通过 `tokenizers::Tokenizer::from_file` 加载 |
| `tokenizer_config.json` | 建议保留 | 分词器附加配置，例如 chat template、padding side、truncation、特殊 token 策略 | 可用于读取 chat template 和默认分词行为 |
| `special_tokens_map.json` | 建议保留 | 定义 `bos_token`、`eos_token`、`unk_token`、`pad_token` 等特殊 token | 生成时判断停止 token、补齐 token 和起始 token |
| `generation_config.json` | 可选 | 模型推荐生成参数，例如 temperature、top_p、max_new_tokens、eos_token_id | 可作为默认采样参数，再被应用配置覆盖 |
| `config_sentence_transformers.json` | Embedding 常见 | SentenceTransformers 模型的池化、归一化等附加信息 | 用于决定 mean pooling、CLS pooling、normalize 等策略 |
| `modules.json` | Embedding 常见 | SentenceTransformers 模型模块组合说明 | 帮助还原 Transformer + Pooling + Normalize 管线 |
| `README.md` / model card | 建议阅读 | 说明模型用途、license、prompt 模板、训练语言和限制 | 用于确定是否适合商用、中文效果和 prompt 格式 |

### config.json 的重点字段

| 字段 | 说明 | 调试关注点 |
| --- | --- | --- |
| `model_type` | 模型架构类型，如 `qwen2`、`llama`、`phi3`、`bert` | Candle adapter 必须和架构匹配 |
| `vocab_size` | 词表大小 | 需与 tokenizer 输出 token id 范围一致 |
| `hidden_size` | 隐层维度 | 必须与权重 shape 匹配 |
| `num_hidden_layers` | Transformer 层数 | 加载权重时逐层对应 |
| `num_attention_heads` | 注意力头数 | 影响 attention 计算 shape |
| `num_key_value_heads` | GQA/MQA 中 KV 头数 | Llama/Qwen 等模型常见，错误会导致 shape 不匹配 |
| `rope_theta` / `max_position_embeddings` | RoPE 和上下文长度相关参数 | 长上下文模型需要重点检查 |
| `torch_dtype` | 原始训练/保存精度 | 决定加载到 `f16`、`bf16` 还是 `f32` 更合适 |

### tokenizer 相关文件的作用

Tokenizer 决定同一段文本会被切成哪些 token。如果 tokenizer 和模型权重不匹配，常见表现是输出乱码、重复、无法停止或质量极差。

需要重点检查：
- `tokenizer.json` 必须来自同一个模型仓库或官方兼容仓库。
- `eos_token_id`、`bos_token_id`、`pad_token_id` 要与生成逻辑一致。
- Chat 模型必须使用正确的 chat template，否则模型可能不会按指令回答。
- Embedding 模型要按模型说明添加 query/passsage 前缀，例如部分 E5 模型需要 `query: ...` 和 `passage: ...`。

### safetensors 权重文件的作用

`safetensors` 是安全、可快速加载的张量格式。Candle 会把权重文件中的张量名映射到模型结构中的层。

常见问题：
- **权重名不匹配**：模型 adapter 与模型架构不一致。
- **shape 不匹配**：`config.json` 与权重文件不是同一版本。
- **缺少分片**：只下载了部分 `model-000xx-of-000xx.safetensors`。
- **精度不兼容**：CPU 上使用 `f16/bf16` 可能性能或兼容性不好，可尝试 `f32`。

### Embedding 模型额外注意

Embedding 模型通常不是简单取最后一个 token，而是需要池化策略：

| 策略 | 说明 | 适合模型 |
| --- | --- | --- |
| CLS pooling | 使用 `[CLS]` token 向量 | 部分 BERT 系列 |
| Mean pooling | 对有效 token 向量求平均 | SentenceTransformers、BGE、E5 常见 |
| Last token pooling | 使用最后一个有效 token | 部分 decoder-only embedding 模型 |
| Normalize | 对向量做 L2 归一化 | 检索模型通常需要 |

如果池化策略错了，RAG 召回质量会明显下降，即使模型本身没有问题。

## 推荐模型

### LLM

| 模型 | 推荐版本 | 适合场景 | 链接 |
| --- | --- | --- | --- |
| Qwen2.5 | 0.5B / 1.5B / 3B | 中文问答、摘要、轻量 RAG | [Hugging Face](https://huggingface.co/Qwen) |
| Qwen3 | 0.6B / 1.7B / 4B | 中文助手、工具调用、轻量推理 | [Hugging Face](https://huggingface.co/Qwen) |
| Phi-3 / Phi-4 | Mini / Small | 英文推理、代码、小模型应用 | [Hugging Face](https://huggingface.co/microsoft) |
| Gemma | 2B / 3B | 通用问答、低资源设备 | [Hugging Face](https://huggingface.co/google) |
| Mistral | 7B | 英文问答、摘要、Agent | [Hugging Face](https://huggingface.co/mistralai) |

### Embedding

| 模型 | 推荐版本 | 适合场景 | 链接 |
| --- | --- | --- | --- |
| BGE-M3 | multilingual | 中英文混合检索、长文档 RAG | [BAAI/bge-m3](https://huggingface.co/BAAI/bge-m3) |
| BGE Small ZH | small-zh | 中文知识库、轻量检索 | [BAAI](https://huggingface.co/BAAI) |
| E5 Small/Base | multilingual / small | 多语言检索、问答召回 | [intfloat](https://huggingface.co/intfloat) |
| all-MiniLM | L6-v2 | 英文轻量检索 | [Sentence Transformers](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2) |

## 设备选择

```rust
use anyhow::Result;
use candle_core::Device;

pub fn resolve_device(device: &str) -> Result<Device> {
    match device {
        "cpu" => Ok(Device::Cpu),
        #[cfg(feature = "cuda")]
        "cuda" => Ok(Device::new_cuda(0)?),
        #[cfg(feature = "metal")]
        "metal" => Ok(Device::new_metal(0)?),
        _ => Ok(Device::Cpu),
    }
}
```

## Tokenizer 加载

```rust
use anyhow::Result;
use tokenizers::Tokenizer;

pub fn load_tokenizer(path: &str) -> Result<Tokenizer> {
    let tokenizer = Tokenizer::from_file(path)
        .map_err(|err| anyhow::anyhow!("load tokenizer failed: {err}"))?;
    Ok(tokenizer)
}
```

## LLM 推理流程

完整模型加载代码会因模型架构不同而不同。实际项目中建议为每类模型单独封装 adapter，例如 `QwenAdapter`、`LlamaAdapter`、`PhiAdapter`。通用推理流程如下：

```text
加载 config.json
加载 tokenizer.json
加载 safetensors 权重
根据模型类型构建 Candle 模型结构
prompt → tokenizer.encode → input_ids tensor
循环 forward → logits → sampler → next_token
next_token → tokenizer.decode → 输出文本
```

### 简化接口设计

```rust
use anyhow::Result;

pub struct GenerateOptions {
    pub max_tokens: usize,
    pub temperature: f64,
    pub top_p: f64,
}

pub trait LocalLlm {
    fn generate(&mut self, prompt: &str, options: GenerateOptions) -> Result<String>;
}
```

### 采样器设计

```rust
pub struct SamplerConfig {
    pub temperature: f64,
    pub top_p: f64,
    pub repeat_penalty: f32,
}

pub struct TokenSampler {
    config: SamplerConfig,
}

impl TokenSampler {
    pub fn new(config: SamplerConfig) -> Self {
        Self { config }
    }

    pub fn sample_next_token(&mut self, logits: &[f32]) -> usize {
        // 实际实现可加入 temperature、top-p、top-k、repeat penalty。
        logits
            .iter()
            .enumerate()
            .max_by(|a, b| a.1.total_cmp(b.1))
            .map(|(idx, _)| idx)
            .unwrap_or(0)
    }
}
```

## Embedding 推理流程

Embedding 是 Candle 更适合落地的场景之一，常用于本地 RAG。

```text
文本 → tokenizer → input_ids / attention_mask
模型 forward → token embeddings
mean pooling / CLS pooling
normalize → 向量
写入本地向量库
```

建议封装接口：

```rust
use anyhow::Result;

pub trait Embedder {
    fn embed(&self, text: &str) -> Result<Vec<f32>>;
    fn embed_batch(&self, texts: &[String]) -> Result<Vec<Vec<f32>>>;
}
```

## 本地 RAG 方案

```text
文档导入
  ↓
文本清洗 / 分块 / 去重
  ↓
Candle Embedding 模型生成向量
  ↓
写入本地向量库
  ↓
用户提问 → 向量召回 TopK
  ↓
拼接上下文 Prompt
  ↓
Candle LLM 或 llama.cpp 生成答案
```

本地向量库可选：
- SQLite + sqlite-vss
- Qdrant 本地版
- LanceDB
- sled / rocksdb 自建向量索引

## Axum API 封装

```rust
use axum::{routing::post, Json, Router};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

#[derive(Deserialize)]
pub struct ChatRequest {
    pub prompt: String,
}

#[derive(Serialize)]
pub struct ChatResponse {
    pub answer: String,
}

async fn chat(Json(req): Json<ChatRequest>) -> Json<ChatResponse> {
    // 实际项目中从 AppState 中取 Candle 模型实例。
    Json(ChatResponse {
        answer: format!("local candle answer for: {}", req.prompt),
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/chat", post(chat));
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## 与 Tauri 集成

典型组合：
- 前端：React / Vue / Svelte。
- 后端：Tauri command 调用 Rust 推理模块。
- 模型目录：放在应用数据目录，例如 `AppData/models` 或 `~/Library/Application Support/app/models`。
- 首次启动：检查模型是否存在，不存在则提示下载或导入。
- 推理任务：放入异步队列，避免阻塞 UI。

## 模型效果调优

模型效果调优优先从「任务定义 → 模型选择 → Prompt → 解码参数 → RAG 召回 → 评测集」这个顺序排查。不要一开始就改代码或换硬件，很多效果问题来自 prompt 格式、tokenizer、上下文组织和采样参数。

### 1. 先明确任务类型

| 任务 | 优先调优目标 | 常见指标 |
| --- | --- | --- |
| 本地聊天 | 回答相关性、稳定性、语言风格 | 人工评分、拒答率、重复率 |
| 文档问答 / RAG | 事实准确、引用正确、少幻觉 | 命中率、答案正确率、引用覆盖率 |
| 摘要 | 保留关键信息、少编造 | ROUGE 可选、人工核查、遗漏率 |
| 分类 / 抽取 | 格式稳定、字段准确 | Accuracy、F1、JSON 解析成功率 |
| Embedding 检索 | 召回相关文档 | Recall@K、MRR、nDCG |

### 2. 模型选择调优

- 中文场景优先选择中文能力强的模型，例如 Qwen、DeepSeek Distill、Yi。
- 英文、代码、推理场景可尝试 Phi、Mistral、Llama、Gemma。
- 小模型适合固定任务和短上下文，大模型更适合复杂指令和长文档总结。
- 如果 Candle 原生 LLM 效果或速度不理想，可以保留 Candle 做 Embedding，LLM 生成接 `llama.cpp + GGUF`。
- Embedding 模型要和语料语言一致：中文知识库优先 `bge-small-zh`、`bge-m3`，英文可选 `e5`、`MiniLM`。

### 3. Prompt 调优

本地小模型对 prompt 格式更敏感，建议固定模板。

```text
你是一个本地离线助手。请只根据给定上下文回答问题。
如果上下文中没有答案，请回答“资料中未提到”，不要编造。

【上下文】
{context}

【问题】
{question}

【回答要求】
1. 用中文回答。
2. 先给结论，再给依据。
3. 如果使用了上下文，请列出引用片段编号。
```

调优建议：
- **明确角色**：例如“设备维修助手”“文档问答助手”“工业告警分析助手”。
- **明确边界**：要求不知道就说不知道，减少幻觉。
- **明确输出格式**：需要 JSON 就给 schema 示例。
- **减少无关上下文**：小模型上下文里噪声越多，效果越差。
- **使用 few-shot**：对分类、抽取、格式化任务，给 2~3 个示例通常很有效。

### 4. Chat template 调优

Chat 模型通常不是直接把用户问题拼成纯文本，而是需要特定模板，如 system/user/assistant 角色格式。模板不对会导致模型不听指令、重复输出或输出奇怪标记。

建议：
- 优先读取 `tokenizer_config.json` 中的 `chat_template`。
- 如果没有 chat template，参考模型卡里的官方 prompt 格式。
- 不同模型不要混用模板，例如 Qwen、Llama、Mistral、Gemma 的模板不同。
- 多轮对话需要控制历史长度，只保留最近轮次和必要摘要。

### 5. 生成参数调优

| 参数 | 影响 | 建议范围 |
| --- | --- | --- |
| `temperature` | 越高越发散，越低越稳定 | 严肃问答 `0.1~0.4`，创作 `0.7~1.0` |
| `top_p` | 控制候选 token 累积概率 | 常用 `0.8~0.95` |
| `top_k` | 限制候选 token 数量 | 常用 `20~50` |
| `max_tokens` | 最大输出长度 | 问答 `256~1024`，摘要可更高 |
| `repeat_penalty` | 抑制重复 | 常用 `1.05~1.2` |
| `stop_tokens` | 控制停止位置 | 必须包含模型对应 EOS token |

推荐配置：

```toml
[generation.qa]
temperature = 0.2
top_p = 0.9
max_tokens = 512
repeat_penalty = 1.1

[generation.summary]
temperature = 0.4
top_p = 0.9
max_tokens = 1024
repeat_penalty = 1.05

[generation.creative]
temperature = 0.8
top_p = 0.95
max_tokens = 1024
repeat_penalty = 1.05
```

### 6. RAG 效果调优

RAG 的效果通常不是 LLM 单独决定的，更多取决于切分、召回和上下文组织。

| 环节 | 问题表现 | 调优方法 |
| --- | --- | --- |
| 文档切分 | 答案缺上下文、引用断裂 | 增大 `chunk_size`，加入标题路径 |
| overlap | 跨段信息丢失 | 设置 `chunk_overlap = 80~200` |
| Embedding | 召回不相关 | 换模型、增加 query 前缀、归一化向量 |
| TopK | 上下文过少或噪声过多 | 常用 `top_k = 3~8` |
| 重排 | 召回有相关文档但排序靠后 | 加 reranker 或规则重排 |
| Prompt 拼接 | 模型忽略上下文 | 给片段编号，要求引用编号 |

推荐 chunk 配置：

```toml
[rag]
chunk_size = 600
chunk_overlap = 120
top_k = 5
include_title_path = true
include_source = true
```

Embedding 调优重点：
- BGE/E5 等模型要按说明添加 query/passsage 前缀。
- 向量入库和查询时必须使用同一个模型、同一种 pooling、同一种 normalize 策略。
- 文档结构强的场景，把标题、章节、表格说明拼入 chunk。
- 对专业文档，维护术语表或同义词扩展能显著提升召回。

### 7. 输出格式调优

对于抽取、分类、结构化任务，建议让模型输出严格 JSON，并在应用侧校验。

```text
请只输出 JSON，不要输出 Markdown。
格式如下：
{
  "risk_level": "low|medium|high",
  "reason": "原因",
  "actions": ["建议动作"]
}
```

应用侧处理：
- JSON 解析失败时自动重试一次，并带上错误信息要求修复。
- 对枚举字段做白名单校验。
- 对数字、日期、单位做后处理校验。
- 不要把模型输出直接作为控制指令执行。

### 8. 构建评测集

建议为每个本地模型应用准备一个小型评测集，先 30~100 条即可。

```json
[
  {
    "id": "qa_001",
    "question": "设备 E101 温度报警时应如何处理？",
    "expected_keywords": ["停机", "检查冷却系统", "通知维护"],
    "source_doc": "设备维护手册.md"
  }
]
```

评测维度：
- **正确性**：答案是否符合资料。
- **完整性**：是否遗漏关键步骤。
- **忠实性**：是否编造资料外内容。
- **格式稳定性**：是否符合 JSON/Markdown/表格要求。
- **延迟**：首 token 和总生成耗时。
- **资源占用**：内存、CPU/GPU、模型加载时间。

### 9. 调优闭环

```text
收集失败样例
  ↓
归因：模型 / prompt / 检索 / 参数 / 数据
  ↓
只改一个变量
  ↓
跑固定评测集
  ↓
记录指标和配置版本
  ↓
推广到默认配置
```

建议每次记录：
- 模型名、版本、权重 hash。
- tokenizer 版本。
- prompt 模板版本。
- generation 参数。
- RAG chunk、top_k、embedding 模型。
- 评测结果和人工备注。

## 性能优化

- **模型大小**：优先小模型和 Embedding 模型，LLM 大模型优先考虑 GGUF。
- **精度选择**：优先 `f16` / `bf16`，CPU 场景需要评估实际支持。
- **KV Cache**：LLM 多轮对话需要缓存上下文，避免每轮全量重算。
- **Batch**：Embedding 支持 batch 推理，提高文档导入速度。
- **流式输出**：文本生成时逐 token 返回，提升用户体验。
- **异步队列**：推理任务进入队列，避免多个请求抢占内存。
- **预热**：应用启动后执行一次短 prompt，降低首次请求延迟。

## 适合优先落地的 MVP

1. 先实现 Candle Embedding 模型加载。
2. 完成本地文档切分和向量化。
3. 用本地向量库实现 TopK 召回。
4. LLM 生成阶段先接 `llama.cpp`，确保效果和速度。
5. 后续再将小 LLM 迁移到 Candle 原生推理。

这个路径更稳：Candle 先负责 Embedding 和 Rust 原生推理基础设施，LLM 先用 GGUF 跑通产品闭环。

## 常见问题

- **为什么 Candle LLM 不如 llama.cpp 简单？**  
  因为不同模型架构的加载、缓存、采样和权重命名差异较大，Candle 需要更多模型适配代码。

- **什么时候优先选 Candle？**  
  当你需要 Rust 原生集成、Embedding、本地模型管线、可控推理逻辑时。

- **什么时候优先选 llama.cpp？**  
  当你主要目标是本地聊天、快速部署量化 LLM、支持更多 GGUF 模型时。

- **Candle 是否适合边缘设备？**  
  适合，但优先用于小模型、Embedding、分类、检索和轻量生成。大模型建议先评估内存和速度。
