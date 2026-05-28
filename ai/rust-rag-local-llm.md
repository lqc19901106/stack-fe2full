# Rust + RAG 本地大模型技术方案

本文整理使用 Rust 构建本地 RAG（Retrieval-Augmented Generation，检索增强生成）大模型应用的详细方案。目标是：文档、向量、模型和推理服务都运行在本地，不依赖云端推理，适合企业知识库、设备手册问答、工业/电网/矿山/医疗内网终端、离线桌面助手和边缘网关。

## 一、目标与适用场景

### 1.1 目标

- 文档数据本地存储，不上传云端。
- Embedding、向量检索、Prompt 拼接、LLM 生成都由本地服务完成。
- Rust 负责高可靠服务封装、文件处理、任务调度、索引管理、API 暴露和部署。
- LLM 可选择 `llama.cpp + GGUF`，Embedding 可选择 ONNX Runtime、Candle 或外部本地服务。
- 支持后续效果调优、性能调优、评测闭环和模型替换。

### 1.2 适用场景

- **企业知识库问答**：规章制度、FAQ、项目文档、运维手册。
- **工业设备问答**：设备说明书、故障码、维修记录、巡检规范。
- **边缘离线终端**：工厂、矿山、园区、电网、车载、专用工控机。
- **本地文档助手**：PDF、Markdown、Word、HTML、日志文件问答。
- **高隐私场景**：医疗、金融、政企、研发资料、代码仓库。

## 二、总体架构

```text
┌──────────────────────────────┐
│      Tauri / Web / CLI        │
│  聊天界面 / 文档导入 / 管理台 │
└───────────────┬──────────────┘
                │ HTTP / Command
┌───────────────▼──────────────┐
│          Rust RAG 服务        │
│ axum API / 任务队列 / 配置管理│
└───────┬──────────────┬───────┘
        │              │
        │              │
┌───────▼───────┐  ┌───▼────────────────┐
│ 文档处理管线   │  │ 查询处理管线         │
│ parse/chunk   │  │ embed/search/rerank │
└───────┬───────┘  └───┬────────────────┘
        │              │
┌───────▼──────────────▼───────┐
│       本地向量库 / 元数据存储 │
│ SQLite/Qdrant/LanceDB/文件索引│
└───────────────┬──────────────┘
                │ context
┌───────────────▼──────────────┐
│      本地 LLM 推理服务        │
│ llama.cpp / Candle / Ollama   │
└──────────────────────────────┘
```

## 三、技术选型

### 3.1 推荐组合

| 模块 | 推荐方案 | 说明 |
| --- | --- | --- |
| Rust Web 服务 | `axum` | 本地 HTTP API，适合桌面端和边缘服务 |
| 异步运行时 | `tokio` | 文件处理、索引任务、模型请求并发 |
| 文档解析 | `pdf-extract`、`pulldown-cmark`、`scraper`、自定义 parser | 根据文件类型扩展 |
| 文本切分 | Rust 自定义 chunker | 控制 chunk size、overlap、标题路径 |
| Embedding | ONNX Runtime `ort` / Candle / 本地 embedding server | 推荐先用 ONNX，稳定好部署 |
| 向量库 | SQLite + sqlite-vss / Qdrant / LanceDB | 小规模优先 SQLite，大规模可用 Qdrant |
| LLM | `llama.cpp + GGUF` | 本地大模型最成熟的路线 |
| 配置 | `toml` + `serde` | 管理模型路径、RAG 参数和生成参数 |
| 日志 | `tracing` | 记录检索、生成、耗时和错误 |

### 3.2 何时选择哪种向量库

| 向量库 | 适合场景 | 优点 | 注意点 |
| --- | --- | --- | --- |
| SQLite + sqlite-vss | 单机、小型知识库、桌面应用 | 轻量、易分发、一个文件保存 | 高并发和超大规模能力有限 |
| Qdrant 本地版 | 中大型知识库、边缘服务器 | 检索能力强、过滤条件成熟 | 需要额外进程或嵌入部署 |
| LanceDB | 文档/多模态数据、本地分析 | 与文件系统结合好 | Rust 生态需评估成熟度 |
| 自建 sled/rocksdb | 强控制、自定义索引 | 可按业务优化 | 开发成本高 |

## 四、目录结构

```text
rust-rag-local-llm/
├── Cargo.toml
├── config/
│   └── app.toml
├── models/
│   ├── llm/
│   │   └── qwen3-4b-q4_k_m.gguf
│   └── embedding/
│       └── bge-small-zh.onnx
├── data/
│   ├── docs/
│   ├── index/
│   ├── vector-store/
│   └── logs/
└── src/
    ├── main.rs
    ├── config.rs
    ├── api.rs
    ├── document/
    │   ├── mod.rs
    │   ├── loader.rs
    │   ├── parser.rs
    │   └── chunker.rs
    ├── embedding/
    │   ├── mod.rs
    │   └── onnx_embedder.rs
    ├── vector_store/
    │   ├── mod.rs
    │   ├── sqlite_store.rs
    │   └── qdrant_store.rs
    ├── retrieval/
    │   ├── mod.rs
    │   ├── search.rs
    │   └── rerank.rs
    ├── llm/
    │   ├── mod.rs
    │   └── llama_client.rs
    ├── prompt.rs
    ├── rag_pipeline.rs
    └── eval.rs
```

## 五、配置设计

```toml
[server]
host = "127.0.0.1"
port = 3000

[document]
data_dir = "data/docs"
chunk_size = 800
chunk_overlap = 120
min_chunk_chars = 80
include_title_path = true

[embedding]
provider = "onnx"
model_path = "models/embedding/bge-small-zh.onnx"
dimension = 512
normalize = true
query_prefix = ""
passage_prefix = ""

[vector_store]
provider = "sqlite"
path = "data/vector-store/rag.db"

[llm]
provider = "llama_cpp"
endpoint = "http://127.0.0.1:8080/v1/chat/completions"
model = "qwen3-4b-q4_k_m"

[retrieval]
top_k = 5
candidate_k = 20
score_threshold = 0.25
rerank_enabled = false

[generation]
temperature = 0.2
top_p = 0.9
max_tokens = 1024
repeat_penalty = 1.1
```

## 六、核心数据结构

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentMeta {
    pub doc_id: String,
    pub title: String,
    pub source_path: String,
    pub file_type: String,
    pub updated_at: i64,
    pub content_hash: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextChunk {
    pub chunk_id: String,
    pub doc_id: String,
    pub title_path: Vec<String>,
    pub text: String,
    pub start_offset: usize,
    pub end_offset: usize,
    pub metadata: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchResult {
    pub chunk_id: String,
    pub doc_id: String,
    pub title: String,
    pub text: String,
    pub score: f32,
    pub source_path: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RagAnswer {
    pub answer: String,
    pub sources: Vec<SearchResult>,
    pub trace_id: String,
}
```

## 七、文档导入与索引流程

### 7.1 流程

```text
选择/上传文档
  ↓
读取文件内容
  ↓
按类型解析：PDF / Markdown / TXT / HTML / DOCX
  ↓
清洗文本：去页眉页脚、去重复空白、保留标题
  ↓
分块：chunk_size + overlap + 标题路径
  ↓
Embedding：每个 chunk 生成向量
  ↓
写入向量库和元数据表
  ↓
返回索引结果
```

### 7.2 文档切分策略

推荐优先采用「结构感知切分」：

- Markdown：按标题层级切分，保留标题路径。
- PDF：按页解析后合并短段落，再按语义长度切分。
- HTML：按 `h1/h2/h3/p/li/table` 提取文本。
- 日志：按时间窗口、错误块、堆栈块切分。
- 表格：表头和每行内容一起保留，避免丢失字段含义。

### 7.3 Chunk 设计

```rust
pub struct ChunkOptions {
    pub chunk_size: usize,
    pub chunk_overlap: usize,
    pub min_chunk_chars: usize,
    pub include_title_path: bool,
}
```

建议：
- 通用文档：`chunk_size = 600~1000`，`overlap = 80~150`。
- 设备手册：按章节、故障码、操作步骤切分。
- 法规制度：按条款切分，保留条款编号。
- 表格密集文档：不要按固定字数切断表格。

## 八、Embedding 模块

### 8.1 接口设计

```rust
use anyhow::Result;

pub trait Embedder: Send + Sync {
    fn embed_query(&self, text: &str) -> Result<Vec<f32>>;
    fn embed_documents(&self, texts: &[String]) -> Result<Vec<Vec<f32>>>;
    fn dimension(&self) -> usize;
}
```

### 8.2 Embedding 注意事项

- 查询和文档必须使用同一个模型。
- 入库和查询必须使用同一种 normalize 策略。
- E5 类模型通常需要 `query:` 和 `passage:` 前缀。
- BGE 类模型需要查看模型卡说明，确认是否需要 instruction。
- 向量维度要与向量库 schema 一致。

### 8.3 ONNX Embedding 推荐

Rust 侧优先使用 ONNX Runtime 执行 Embedding，部署稳定、模型转换方便。

```text
文本 → tokenizer → input_ids / attention_mask
ONNX forward
last_hidden_state
mean pooling
L2 normalize
写入向量库
```

## 九、向量存储设计

### 9.1 元数据表

```sql
CREATE TABLE documents (
  doc_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  source_path TEXT NOT NULL,
  file_type TEXT NOT NULL,
  content_hash TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE chunks (
  chunk_id TEXT PRIMARY KEY,
  doc_id TEXT NOT NULL,
  title_path TEXT,
  text TEXT NOT NULL,
  source_path TEXT NOT NULL,
  start_offset INTEGER,
  end_offset INTEGER,
  metadata TEXT,
  FOREIGN KEY(doc_id) REFERENCES documents(doc_id)
);
```

向量可放在 sqlite-vss、Qdrant 或独立二进制索引中，`chunk_id` 作为关联键。

### 9.2 检索接口

```rust
use anyhow::Result;

pub trait VectorStore: Send + Sync {
    fn upsert(&self, chunk: &TextChunk, embedding: &[f32]) -> Result<()>;
    fn search(&self, embedding: &[f32], top_k: usize) -> Result<Vec<SearchResult>>;
    fn delete_by_doc(&self, doc_id: &str) -> Result<()>;
}
```

## 十、查询与生成流程

### 10.1 查询流程

```text
用户问题
  ↓
query rewrite（可选）
  ↓
Embedding
  ↓
向量召回 top_k / candidate_k
  ↓
过滤与重排
  ↓
构造 Prompt
  ↓
本地 LLM 生成
  ↓
返回答案 + 引用来源
```

### 10.2 Prompt 模板

```text
你是一个本地知识库问答助手。请只根据给定资料回答问题。
如果资料中没有答案，请回答“资料中未提到”，不要编造。

【资料片段】
{context}

【用户问题】
{question}

【回答要求】
1. 先给结论，再给依据。
2. 必须引用资料片段编号。
3. 不要输出资料中不存在的信息。
```

### 10.3 上下文拼接格式

```text
[片段 1]
来源：设备维护手册.md > 第三章 > 温度报警
内容：……

[片段 2]
来源：巡检规范.md > 冷却系统
内容：……
```

## 十一、LLM 接入方案

### 11.1 llama.cpp 本地接口

推荐先使用 `llama-server` 暴露 OpenAI 兼容接口，Rust 通过 `reqwest` 调用。

```rust
use anyhow::Result;
use reqwest::Client;
use serde_json::json;

pub async fn generate_answer(endpoint: &str, prompt: &str) -> Result<String> {
    let client = Client::new();
    let resp = client
        .post(endpoint)
        .json(&json!({
            "messages": [
                { "role": "user", "content": prompt }
            ],
            "temperature": 0.2,
            "top_p": 0.9,
            "max_tokens": 1024,
            "stream": false
        }))
        .send()
        .await?
        .json::<serde_json::Value>()
        .await?;

    Ok(resp["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or_default()
        .to_string())
}
```

### 11.2 Candle 本地接口

如果希望 Rust 原生加载小 LLM，可以接入 Candle adapter。建议先把 Candle 用在 Embedding，再逐步迁移生成模型。

## 十二、API 设计

### 12.1 文档索引

```http
POST /api/docs/index
Content-Type: application/json

{
  "path": "data/docs/device-manual.md",
  "force": false
}
```

### 12.2 问答

```http
POST /api/rag/chat
Content-Type: application/json

{
  "question": "E101 温度报警如何处理？",
  "top_k": 5,
  "stream": false
}
```

响应：

```json
{
  "answer": "应先停机并检查冷却系统……",
  "sources": [
    {
      "doc_id": "doc_001",
      "title": "设备维护手册",
      "chunk_id": "chunk_001",
      "score": 0.82,
      "source_path": "data/docs/device-manual.md"
    }
  ],
  "trace_id": "rag_20260528_001"
}
```

### 12.3 健康检查

```http
GET /api/health
```

返回内容包括：
- embedding 模型是否加载。
- 向量库是否可访问。
- LLM 服务是否可访问。
- 当前索引文档数和 chunk 数。

## 十三、后续调优策略

调优分为四类：检索调优、生成调优、数据调优和系统调优。建议建立固定评测集，每次只改一个变量。

### 13.1 检索效果调优

| 问题 | 可能原因 | 调优策略 |
| --- | --- | --- |
| 找不到相关片段 | chunk 太大/太小，Embedding 不适配 | 调整 chunk，换 Embedding，增加标题路径 |
| 召回片段相关但排序靠后 | 只用向量相似度不够 | 增加 reranker，或加入关键词混合检索 |
| 答案缺关键步骤 | chunk 被切断 | 增大 overlap，按标题/条款切分 |
| 专业术语召回差 | 同义词、缩写、术语不一致 | 增加术语表、query rewrite、关键词补召回 |
| 表格问答差 | 表格结构丢失 | 表头随每行保留，表格转 Markdown |

建议参数：

```toml
[retrieval]
candidate_k = 20
top_k = 5
score_threshold = 0.25
rerank_enabled = true
```

### 13.2 生成效果调优

| 问题 | 调优策略 |
| --- | --- |
| 幻觉严重 | Prompt 强制仅根据资料回答，降低 temperature，展示引用 |
| 回答太短 | 增加 max_tokens，要求分步骤回答 |
| 回答太散 | 要求“先结论后依据”，限制输出结构 |
| 重复输出 | 增加 repeat_penalty，设置 stop token |
| 不按格式输出 | 给 JSON schema 或示例，解析失败自动修复 |

推荐参数：

```toml
[generation.qa]
temperature = 0.2
top_p = 0.9
max_tokens = 1024
repeat_penalty = 1.1

[generation.summary]
temperature = 0.4
top_p = 0.9
max_tokens = 1500
repeat_penalty = 1.05
```

### 13.3 数据质量调优

- 去掉页眉、页脚、版权声明、目录噪声。
- 对扫描 PDF 先 OCR，再人工抽样检查识别质量。
- 保留章节标题、编号、表格表头和图片说明。
- 对过期文档做版本标记，避免新旧规程冲突。
- 对同义词和缩写维护术语表，例如设备名、告警码、部件编号。
- 为关键文档加 metadata，如部门、版本、适用设备、更新时间。

### 13.4 Query Rewrite

用户问题常常太短或缺少业务上下文，可以先做查询改写：

```text
原始问题：E101 怎么办？
改写问题：设备故障码 E101 温度报警的处理步骤是什么？
```

实现方式：
- 简单规则：识别故障码、设备编号、关键词扩展。
- 本地小模型：用 LLM 将短问题改写成完整检索 query。
- 多 query：生成 2~3 个不同问法分别检索，再合并结果。

### 13.5 混合检索

纯向量检索对编号、代码、型号、故障码不一定稳定。建议加入关键词检索：

```text
最终候选 = 向量召回 TopK + BM25/关键词召回 TopK + 规则命中
再统一重排
```

适合混合检索的字段：
- 故障码：`E101`、`P0301`
- 设备型号：`AB-2000`
- 物料号、规程编号、章节编号
- 人名、地名、项目编号

### 13.6 Rerank 调优

如果资源允许，可增加本地 reranker：
- `bge-reranker-base`
- `jina-reranker-v2-base-multilingual`

流程：

```text
向量召回 candidate_k=20
  ↓
reranker 对 question + chunk 打分
  ↓
取 top_k=5 进入 prompt
```

边缘设备资源紧张时，可先用规则重排：
- 标题包含 query 关键词加分。
- chunk 中包含故障码/型号精确匹配加分。
- 新版本文档优先。
- 同一文档相邻 chunk 可合并。

### 13.7 评测集建设

最小评测集建议 50 条：

```json
[
  {
    "id": "faq_001",
    "question": "E101 温度报警如何处理？",
    "expected_doc": "设备维护手册.md",
    "expected_keywords": ["停机", "冷却系统", "维护人员"],
    "must_not_include": ["继续运行"]
  }
]
```

评测指标：
- `Recall@K`：正确片段是否被召回。
- `Answer Accuracy`：答案是否正确。
- `Citation Accuracy`：引用是否真实支持答案。
- `Hallucination Rate`：资料外编造比例。
- `Latency P95`：95 分位响应耗时。
- `Token Usage`：上下文和输出 token 数。

### 13.8 调优记录模板

```markdown
## RAG 调优记录

- 日期：
- 数据集版本：
- Embedding 模型：
- LLM 模型：
- chunk_size / overlap：
- top_k / candidate_k：
- reranker：
- prompt 版本：
- generation 参数：
- Recall@K：
- 答案正确率：
- 幻觉率：
- P95 延迟：
- 结论：
```

## 十四、性能与部署调优

### 14.1 索引性能

- 文档导入使用后台任务队列。
- Embedding 支持 batch。
- 大文档分批写入向量库。
- 对文档 hash 做缓存，未变化则跳过重建索引。
- 索引过程记录进度，支持暂停和重建。

### 14.2 查询性能

- 缓存常见问题的 query embedding。
- 缓存高频问答结果。
- 控制 prompt 中上下文长度，避免塞入过多 chunk。
- LLM 服务启动时预热。
- 边缘设备限制并发，避免多个生成任务同时抢内存。

### 14.3 部署建议

- 桌面应用：Tauri + Rust RAG 服务 + 本地模型目录。
- 边缘网关：systemd 管理 Rust 服务和 llama-server。
- 工控机：固定模型版本，关闭外网访问，记录审计日志。
- 内网服务器：Qdrant + llama.cpp + Rust API，可供多客户端访问。

## 十五、MVP 路线

1. 本地 Markdown/TXT 文档导入。
2. 文本清洗和固定长度 chunk。
3. ONNX Embedding 生成向量。
4. SQLite 或 Qdrant 本地向量检索。
5. llama.cpp 本地 LLM 生成答案。
6. 返回答案和引用来源。
7. 增加评测集，开始调 chunk、top_k、prompt。
8. 增加 PDF/OCR、reranker、混合检索和 Tauri UI。

## 十六、风险与注意事项

- 不要把模型回答直接作为控制指令执行，必须有人或规则确认。
- 本地模型也可能幻觉，RAG 必须展示引用来源。
- 文档版本冲突会导致答案过期，需要索引版本管理。
- 第三方模型 license 要单独检查，尤其是商用场景。
- 对敏感文档要做本地权限控制、访问日志和加密存储。
