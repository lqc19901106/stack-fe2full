# Rust Edge AI：构建本地运行的模型应用

本文整理使用 Rust 构建 Edge AI 本地模型应用的方案，重点是：模型放在本地、不依赖云端推理、应用可在桌面端、边缘设备、工控机、网关或嵌入式 Linux 环境运行。

## 适合场景
- **隐私敏感场景**: 本地知识库、企业文档问答、医疗/工业数据分析。
- **低延迟场景**: 摄像头检测、语音指令、设备异常识别、边缘网关告警。
- **弱网或离线场景**: 工厂、矿山、车载、机器人、专用终端。
- **成本可控场景**: 批量设备部署，避免长期调用云端 API。
- **系统集成场景**: Rust 后端、Tauri 桌面应用、嵌入式服务、CLI 工具。

## Rust 本地模型运行技术路线

### 方案一：使用 ONNX Runtime 加载本地 ONNX 模型
适合传统机器学习、CV、NLP 小模型、分类模型、检测模型和时间序列模型。

**优点**
- 生态成熟，跨平台能力强。
- 支持 CPU、CUDA、TensorRT、DirectML、CoreML 等执行后端。
- 很多 PyTorch、TensorFlow、Scikit-learn 模型都可以导出为 ONNX。
- Rust 可通过 `ort` crate 调用。

**适合模型**
- 图像分类模型：ResNet、MobileNet、EfficientNet。
- 目标检测模型：YOLOv5/YOLOv8 ONNX。
- 文本分类模型：BERT、MiniLM ONNX。
- 时间序列模型：负荷预测、设备异常检测。

**核心依赖**
```toml
[dependencies]
ort = "2"
ndarray = "0.16"
anyhow = "1"
image = "0.25"
```

**本地加载流程**
1. 准备本地模型文件，例如 `models/model.onnx`。
2. 初始化 ONNX Runtime 环境。
3. 读取输入数据并预处理为张量。
4. 调用模型推理。
5. 对输出结果做后处理。

**示例代码**
```rust
use anyhow::Result;
use ndarray::Array;
use ort::{session::Session, value::Tensor};

fn main() -> Result<()> {
    let model_path = "models/model.onnx";

    let mut session = Session::builder()?
        .commit_from_file(model_path)?;

    // 示例输入：1 x 3 x 224 x 224
    let input = Array::zeros((1, 3, 224, 224)).into_dyn();
    let input_tensor = Tensor::from_array(input)?;

    let outputs = session.run(ort::inputs!["input" => input_tensor]?)?;
    println!("model outputs: {:?}", outputs);

    Ok(())
}
```

## 方案二：使用 Candle 加载本地 Transformer / LLM 模型
Candle 是 Hugging Face 推出的 Rust 机器学习框架，适合在 Rust 中运行本地大模型、小语言模型、Embedding 模型和部分多模态模型。

**优点**
- Rust 原生，部署时依赖相对清晰。
- 适合本地 LLM、Embedding、文本生成和语义检索。
- 可以加载 Hugging Face 模型权重。
- 支持 CPU、CUDA、Metal 等后端。

**适合模型**
- 本地小语言模型：Qwen、Llama、Mistral、Phi、Gemma。
- Embedding 模型：bge-small、bge-base、e5-small、MiniLM。
- 文本分类、文本生成、RAG 检索。

**核心依赖**
```toml
[dependencies]
candle-core = "0.8"
candle-nn = "0.8"
candle-transformers = "0.8"
tokenizers = "0.20"
anyhow = "1"
```

**本地加载流程**
1. 下载模型权重到本地，例如 `models/qwen/`。
2. 准备 `config.json`、`tokenizer.json`、`model.safetensors` 等文件。
3. 使用 `tokenizers` 做文本编码。
4. 使用 Candle 加载权重并执行推理。
5. 对 token 输出进行解码。

**适合应用**
- 本地聊天助手。
- 本地文档总结。
- 本地知识库问答。
- 工业设备说明书问答。
- 边缘端语义搜索。

**独立方案文档**
- [Candle + Rust 本地 LLM 应用方案](./candle-rust-local-llm.md)

## 方案三：使用 llama.cpp / GGUF 运行本地大模型
如果目标是快速运行本地 LLM，尤其是量化模型，`llama.cpp` + GGUF 是非常实用的路线。Rust 可以通过 FFI、命令行子进程、HTTP server 或相关 crate 集成。

**优点**
- GGUF 模型生态成熟，量化模型多。
- CPU 也能运行较小模型。
- 支持 Metal、CUDA、Vulkan 等加速。
- 很适合边缘设备和本地桌面应用。

**适合模型**
- Qwen2.5 / Qwen3 GGUF。
- Llama GGUF。
- Mistral GGUF。
- Phi GGUF。
- Gemma GGUF。

**集成方式**
- **子进程方式**: Rust 启动 `llama-cli` 或 `llama-server`，通过 stdin/stdout 或 HTTP 通信。
- **HTTP 方式**: 单独运行 `llama-server`，Rust 应用请求本地接口。
- **FFI 方式**: 直接链接 `llama.cpp`，性能和控制力更好，但工程复杂度更高。

**推荐落地方式**
前期优先使用 `llama-server` 本地 HTTP 方式，验证快、调试简单；后期再考虑 FFI 深度集成。

**本地启动示例**
```bash
./llama-server \
  -m models/qwen2.5-1.5b-instruct-q4_k_m.gguf \
  --host 127.0.0.1 \
  --port 8080
```

**Rust 调用本地模型服务**
```toml
[dependencies]
reqwest = { version = "0.12", features = ["json"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
anyhow = "1"
```

```rust
use anyhow::Result;
use reqwest::Client;
use serde_json::json;

#[tokio::main]
async fn main() -> Result<()> {
    let client = Client::new();

    let response = client
        .post("http://127.0.0.1:8080/completion")
        .json(&json!({
            "prompt": "请用三句话解释什么是边缘 AI。",
            "n_predict": 128,
            "temperature": 0.7
        }))
        .send()
        .await?
        .text()
        .await?;

    println!("{response}");
    Ok(())
}
```

## 方案三补充文档

更完整的 `llama.cpp + GGUF + Rust` 本地模型应用方案已拆分到独立文档：

- [llama.cpp + GGUF + Rust 本地模型应用方案](./llama-cpp-gguf-rust.md)

## 方案四：使用 Burn 构建 Rust 原生推理应用
Burn 是 Rust 机器学习框架，适合希望 Rust 原生训练或推理的场景。

**优点**
- Rust 原生抽象。
- 支持多后端。
- 适合构建轻量模型和可控推理流程。

**适合场景**
- 自定义小模型。
- 设备端异常检测。
- 时间序列预测。
- 对 Rust 原生工程一致性要求较高的项目。

**注意**
Burn 生态仍在发展中。如果已有成熟 PyTorch 模型，通常先导出 ONNX 更稳。

## 适合本地运行的模型链接清单

以下模型优先选择开源权重、体积相对可控、生态成熟、容易通过 GGUF、ONNX、safetensors、Ollama 或 llama.cpp 在本地运行的版本。实际商用前需要检查模型 license、数据合规和部署限制。

### 本地 LLM / 聊天助手

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| Qwen3 | 0.6B / 1.7B / 4B / 8B | 中文问答、工具调用、轻量 Agent、本地助手 | GGUF、Ollama、llama.cpp、vLLM | [Hugging Face](https://huggingface.co/Qwen) / [Ollama](https://ollama.com/library/qwen3) |
| Qwen2.5 | 0.5B / 1.5B / 3B / 7B | 中文知识库问答、摘要、分类、边缘端对话 | GGUF、Ollama、llama.cpp | [Hugging Face](https://huggingface.co/Qwen) / [Ollama](https://ollama.com/library/qwen2.5) |
| Llama 3.2 | 1B / 3B | 英文轻量聊天、低资源设备推理 | GGUF、Ollama、llama.cpp | [Meta](https://www.llama.com/) / [Ollama](https://ollama.com/library/llama3.2) |
| Llama 3.1 | 8B | 本地桌面助手、英文问答、代码解释 | GGUF、Ollama、llama.cpp | [Meta](https://www.llama.com/) / [Ollama](https://ollama.com/library/llama3.1) |
| Mistral | 7B | 英文推理、摘要、通用助手 | GGUF、Ollama、llama.cpp | [Hugging Face](https://huggingface.co/mistralai) / [Ollama](https://ollama.com/library/mistral) |
| Phi-3 / Phi-4 | Mini / Small | 低资源设备、英文推理、代码和轻量任务 | GGUF、ONNX、Ollama | [Hugging Face](https://huggingface.co/microsoft) / [Ollama](https://ollama.com/library/phi3) |
| Gemma 2 / Gemma 3 | 2B / 9B | 本地通用问答、摘要、轻量应用 | GGUF、Ollama、llama.cpp | [Hugging Face](https://huggingface.co/google) / [Ollama](https://ollama.com/library/gemma2) |
| DeepSeek-R1 Distill | 1.5B / 7B / 8B | 本地推理、数学、代码、复杂任务拆解 | GGUF、Ollama、llama.cpp | [Hugging Face](https://huggingface.co/deepseek-ai) / [Ollama](https://ollama.com/library/deepseek-r1) |
| Yi | 6B / 9B | 中英文通用问答、本地知识库 | GGUF、llama.cpp | [Hugging Face](https://huggingface.co/01-ai) |

**选择建议**：
- 8GB 内存以内：优先 `0.5B`、`1.5B`、`3B` 的 Q4/Q5 量化模型。
- 16GB 内存：可尝试 `7B/8B` Q4 量化模型。
- 中文场景：优先 Qwen 系列、DeepSeek Distill、Yi。
- 英文和代码场景：可选 Llama、Mistral、Phi、Gemma。

### 常见 GGUF 模型下载地址

常见 GGUF 模型下载地址已拆分到独立文档：

- [llama.cpp + GGUF + Rust 本地模型应用方案](./llama-cpp-gguf-rust.md#常见-gguf-模型下载地址)

### Embedding / 向量检索模型

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| BGE-M3 | 多语言通用 | 中英文混合检索、长文档向量化、RAG | sentence-transformers、ONNX、Candle | [Hugging Face](https://huggingface.co/BAAI/bge-m3) |
| BGE Small/Base ZH | small-zh / base-zh | 中文知识库、企业文档检索 | ONNX、safetensors | [BAAI](https://huggingface.co/BAAI) |
| BGE Small/Base EN | small-en / base-en | 英文文档检索、语义搜索 | ONNX、safetensors | [BAAI](https://huggingface.co/BAAI) |
| E5 | small / base / multilingual | 多语言检索、问答召回 | ONNX、safetensors | [intfloat](https://huggingface.co/intfloat) |
| GTE | small / base / multilingual | 轻量语义检索、文本聚类 | ONNX、safetensors | [Alibaba-NLP](https://huggingface.co/Alibaba-NLP) |
| all-MiniLM | L6-v2 | 英文轻量检索、低资源设备 | ONNX、safetensors | [Sentence Transformers](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2) |

### Rerank / 重排序模型

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| BGE Reranker | bge-reranker-base / large | RAG 召回后重排，提高答案相关性 | ONNX、safetensors | [BAAI](https://huggingface.co/BAAI) |
| Jina Reranker | jina-reranker-v2-base-multilingual | 多语言重排序、中文/英文混合检索 | ONNX、safetensors | [Jina AI](https://huggingface.co/jinaai) |

### 视觉模型 / 图像识别与检测

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| YOLOv8 / YOLO11 | n / s | 目标检测、工业缺陷、摄像头告警 | ONNX、TensorRT、OpenVINO | [Ultralytics](https://github.com/ultralytics/ultralytics) |
| YOLOv5 | n / s | 轻量目标检测、边缘设备兼容 | ONNX、TensorRT | [GitHub](https://github.com/ultralytics/yolov5) |
| MobileNetV3 | small / large | 图像分类、低资源设备视觉识别 | ONNX、TFLite | [Torchvision](https://pytorch.org/vision/stable/models/mobilenetv3.html) |
| EfficientNet Lite | lite0 / lite1 | 图像分类、移动端/边缘端 | ONNX、TFLite | [TensorFlow Hub](https://tfhub.dev/s?module-type=image-classification&q=efficientnet) |
| MobileSAM | mobile_sam | 轻量图像分割、标注辅助 | ONNX、PyTorch | [GitHub](https://github.com/ChaoningZhang/MobileSAM) |
| Segment Anything | ViT-B | 通用图像分割，桌面端或 GPU 边缘设备 | ONNX、PyTorch | [GitHub](https://github.com/facebookresearch/segment-anything) |
| CLIP | ViT-B/32 | 图文匹配、零样本分类、图片检索 | ONNX、safetensors | [OpenAI CLIP](https://github.com/openai/CLIP) / [Hugging Face](https://huggingface.co/openai) |

### OCR / 文档识别模型

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| PaddleOCR | PP-OCRv4 / PP-OCRv5 | 中文 OCR、票据、表格、工业标牌识别 | ONNX、Paddle Inference | [GitHub](https://github.com/PaddlePaddle/PaddleOCR) |
| RapidOCR | PP-OCR ONNX | 轻量 OCR、本地文档识别 | ONNX Runtime | [GitHub](https://github.com/RapidAI/RapidOCR) |
| EasyOCR | 多语言 | 快速 OCR 原型、多语言文字识别 | PyTorch、可转 ONNX | [GitHub](https://github.com/JaidedAI/EasyOCR) |

### 语音模型 / ASR 与 TTS

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| Whisper | tiny / base / small | 本地语音识别、会议转写、语音指令 | whisper.cpp、ONNX | [OpenAI Whisper](https://github.com/openai/whisper) / [whisper.cpp](https://github.com/ggerganov/whisper.cpp) |
| Faster Whisper | tiny / base / small | 更快的 Whisper 推理、GPU/CPU 转写 | CTranslate2 | [GitHub](https://github.com/SYSTRAN/faster-whisper) |
| SenseVoice | Small | 中英文语音识别、情感/事件识别 | ONNX、PyTorch | [FunAudioLLM](https://github.com/FunAudioLLM/SenseVoice) |
| Piper | voice models | 本地 TTS、离线语音播报 | ONNX Runtime | [GitHub](https://github.com/rhasspy/piper) |

### 多模态 / 视觉语言模型

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| Qwen2.5-VL | 3B / 7B | 图片问答、文档理解、截图分析 | Transformers、vLLM、部分 GGUF 生态 | [Hugging Face](https://huggingface.co/Qwen) |
| LLaVA | 1.5 / 1.6 | 本地图片问答、视觉助手 | llama.cpp、Transformers | [GitHub](https://github.com/haotian-liu/LLaVA) |
| MiniCPM-V | 2.6 / 4.0 | 轻量多模态、移动端视觉问答 | Transformers、GGUF 生态 | [Hugging Face](https://huggingface.co/openbmb) |
| Florence-2 | base / large | 视觉检测、OCR、图像描述、多任务视觉 | ONNX、Transformers | [Hugging Face](https://huggingface.co/microsoft/Florence-2-base) |

### 时间序列 / 异常检测模型

| 模型 | 推荐版本 | 适合场景 | 本地运行方式 | 链接 |
| --- | --- | --- | --- | --- |
| Chronos | tiny / mini / small | 负荷预测、设备指标预测、边缘时间序列预测 | Transformers、ONNX 可选 | [Hugging Face](https://huggingface.co/amazon/chronos-t5-small) |
| TimesFM | 1.0 / 2.0 | 通用时间序列预测、能耗/产线趋势预测 | JAX/Python，部署前可封装服务 | [GitHub](https://github.com/google-research/timesfm) |
| Anomalib | PatchCore / FastFlow | 工业视觉异常检测、缺陷检测 | ONNX、OpenVINO | [GitHub](https://github.com/open-edge-platform/anomalib) |

### 模型下载与检索入口

| 平台 | 适合内容 | 链接 |
| --- | --- | --- |
| Hugging Face Models | safetensors、ONNX、Embedding、多模态模型 | [Hugging Face](https://huggingface.co/models) |
| ModelScope | 中文模型、国内下载体验更好 | [ModelScope](https://modelscope.cn/models) |
| ONNX Model Zoo | ONNX 示例模型 | [ONNX Model Zoo](https://github.com/onnx/models) |
| Ultralytics | YOLO 检测模型 | [Ultralytics](https://github.com/ultralytics/ultralytics) |
| OpenVINO Model Zoo | Intel 设备优化模型 | [OpenVINO Model Zoo](https://github.com/openvinotoolkit/open_model_zoo) |

## 模型格式选择

| 模型格式 | 适合场景 | Rust 加载方案 |
| --- | --- | --- |
| `.onnx` | CV、NLP 小模型、传统深度学习模型 | `ort` |
| `.safetensors` | Transformer、Embedding、本地 LLM | `candle` |
| `.gguf` | 量化大语言模型、本地聊天助手 | `llama.cpp` 集成 |
| `.tflite` | 移动端、嵌入式轻量模型 | TFLite 绑定或 C API |
| `.pt` / `.pth` | PyTorch 原始权重 | 建议先转 ONNX 或 safetensors |

## 推荐架构

```text
edge-ai-app/
├── Cargo.toml
├── models/
│   ├── model.onnx
│   ├── embedding/
│   └── llm/
├── src/
│   ├── main.rs
│   ├── config.rs
│   ├── model_loader.rs
│   ├── inference.rs
│   ├── preprocess.rs
│   ├── postprocess.rs
│   └── api.rs
└── data/
    ├── input/
    └── output/
```

## 本地模型应用核心模块
- **模型管理**: 模型路径、版本、校验、热更新。
- **输入预处理**: 图片缩放、归一化、文本分词、特征构造。
- **推理执行**: ONNX Runtime、Candle、llama.cpp 或本地 HTTP。
- **输出后处理**: 分类标签、检测框、文本解码、置信度过滤。
- **本地 API**: 使用 `axum` 或 `tauri` 暴露能力。
- **配置管理**: 模型路径、推理参数、设备后端、线程数。
- **日志与监控**: 推理耗时、错误日志、模型版本、资源占用。

## Rust Web API 封装方案

如果要把本地模型能力提供给前端、桌面端或其他本地服务，可以使用 `axum` 封装 HTTP API。

```toml
[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
anyhow = "1"
```

```rust
use axum::{routing::post, Json, Router};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

#[derive(Deserialize)]
struct PredictRequest {
    text: String,
}

#[derive(Serialize)]
struct PredictResponse {
    result: String,
}

async fn predict(Json(req): Json<PredictRequest>) -> Json<PredictResponse> {
    // 这里调用本地模型推理逻辑。
    Json(PredictResponse {
        result: format!("local model output for: {}", req.text),
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/predict", post(predict));
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## Tauri 桌面端方案

如果要做本地 AI 桌面应用，可以用：
- **前端**: React / Vue / Svelte。
- **桌面壳**: Tauri。
- **后端推理**: Rust 调用 ONNX Runtime、Candle 或本地 llama.cpp。
- **模型目录**: 放在应用数据目录，首次启动检查模型是否存在。

典型应用：
- 本地知识库助手。
- 本地 PDF 总结工具。
- 本地图片识别工具。
- 工业设备诊断客户端。
- 智能电网/智能指挥离线辅助终端。

## 模型加载注意事项
- **模型路径**: 不要硬编码绝对路径，使用配置文件或应用数据目录。
- **模型体积**: 边缘设备优先使用量化模型，例如 INT8、Q4、Q5。
- **启动速度**: 大模型加载慢，可以设计模型预热和懒加载。
- **内存占用**: 根据设备内存选择模型大小，避免 OOM。
- **线程设置**: CPU 推理时合理设置线程数，避免抢占业务线程。
- **硬件加速**: macOS 可考虑 Metal，NVIDIA 设备可考虑 CUDA/TensorRT。
- **模型校验**: 启动时校验模型文件 hash，避免文件损坏。
- **版本管理**: 模型版本和应用版本分开管理，方便灰度和回滚。

## 性能优化方向
- **量化**: FP32 -> FP16 -> INT8 -> GGUF Q4/Q5。
- **蒸馏**: 用小模型替代大模型，降低边缘端负载。
- **批处理**: 多请求合并推理，提高吞吐。
- **缓存**: 对 Embedding、常见问答、配置数据做本地缓存。
- **流式输出**: LLM 场景下提升用户体验。
- **异步队列**: 推理任务进入队列，避免阻塞主线程。
- **模型裁剪**: 对特定任务保留必要结构。

## 推荐选型

### 图像识别、检测、分类
优先选择：
- PyTorch 训练模型。
- 导出 ONNX。
- Rust 使用 `ort` 加载。

### 文本分类、Embedding、RAG
优先选择：
- Hugging Face 模型。
- 使用 `safetensors` 或 ONNX。
- Rust 使用 `candle` 或 `ort`。
- 更完整的 Rust RAG 本地方案见：[Rust + RAG 本地大模型技术方案](./rust-rag-local-llm.md)。

### 本地聊天助手
优先选择：
- GGUF 量化模型。
- `llama.cpp` 本地运行。
- Rust 通过 HTTP 或 FFI 集成。
- 如果需要多步骤任务、工具调用、Skills 和 MCP，可参考：[Rust + Agent 本地大模型开发方案](./rust-agent-local-llm.md)。

### 工业/电网/指挥类边缘应用
优先组合：
- ONNX 小模型做预测和异常检测。
- 本地 LLM 做知识库问答和辅助研判。
- Rust 服务负责设备接入、规则引擎、推理调度和本地 API。

## 最小可行产品路线
1. 先用 Python 训练或下载一个可用模型。
2. 将模型转换为 ONNX、GGUF 或 safetensors。
3. 用 Rust 写一个 CLI 程序加载本地模型完成单次推理。
4. 增加 `axum` HTTP API，提供 `/predict` 或 `/chat`。
5. 增加配置文件，支持模型路径、设备后端、推理参数。
6. 增加日志、错误处理和推理耗时统计。
7. 最后再封装成 Tauri 桌面应用或边缘设备服务。

## 总结
- **ONNX Runtime + Rust**: 最适合传统 AI 模型和工业级推理落地。
- **Candle + Rust**: 适合 Rust 原生 Transformer、Embedding 和部分 LLM 应用。
- **llama.cpp + GGUF + Rust**: 最适合快速构建本地大模型应用。
- **Axum/Tauri**: 适合把本地模型能力封装成服务或桌面端产品。

实际项目中可以混合使用：预测、检测、异常识别用 ONNX；知识库问答和辅助研判用本地 LLM；Rust 负责统一调度、接口封装、配置管理和边缘部署。
