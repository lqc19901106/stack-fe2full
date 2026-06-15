# 时间序列分析、预测原理与 Rust + 大模型使用示例

本文整理时间序列分析与预测的基本原理、常见建模路线，以及如何用 Rust 构建时间序列预测服务，并结合本地大模型完成异常解释、预测报告、RAG 查询和 Agent 工具编排。

核心观点：

```text
时间序列模型：负责数值预测、趋势判断、异常检测
大模型：负责解释结果、生成报告、理解业务语义、编排工具
```

不要直接把大模型当成唯一的预测模型。对于严肃的业务预测，推荐“统计/机器学习/深度学习模型 + 大模型解释层”的组合。

## 一、什么是时间序列

时间序列是一组按时间顺序排列的数据点。

常见例子：
- 电商每日订单量。
- 服务器每分钟 CPU 使用率。
- 工厂设备每秒温度、压力、振动。
- 股票价格、成交量。
- 电池 SOC、SOH、电压、电流。
- 矿山设备产量、能耗、故障率。

形式：

```text
(t1, y1), (t2, y2), (t3, y3), ...
```

其中：
- `t` 是时间。
- `y` 是观测值。
- 如果有多个观测变量，就是多变量时间序列。

## 二、时间序列分析的目标

时间序列分析不只是预测未来，还包括：

| 任务 | 说明 | 示例 |
| --- | --- | --- |
| 趋势分析 | 判断长期上升/下降 | 销量是否持续增长 |
| 季节性分析 | 发现周期规律 | 周末流量更高 |
| 异常检测 | 发现突变、离群点 | 设备温度突然升高 |
| 缺失修复 | 对缺失时间点插值 | 传感器掉线补值 |
| 预测 | 预测未来值 | 预测未来 7 天订单量 |
| 归因解释 | 分析变化原因 | 节假日、活动、天气影响 |
| 决策支持 | 基于预测做动作 | 备货、扩容、维修 |

## 三、时间序列的组成

一个时间序列通常可以拆成：

```text
观测值 = 趋势 Trend + 季节性 Seasonality + 周期 Cyclic + 噪声 Noise + 异常 Anomaly
```

### 3.1 趋势

趋势表示长期方向。

例如：

```text
用户数长期增长
设备振动幅度长期升高
电池健康度缓慢下降
```

### 3.2 季节性

季节性表示固定周期模式。

例如：
- 每天早晚高峰。
- 每周工作日和周末差异。
- 每月初/月末结算波动。
- 每年节假日促销峰值。

### 3.3 噪声

噪声是无法解释或暂时不建模的随机波动。

模型不应该过度拟合噪声，否则短期验证集可能好看，但上线泛化很差。

### 3.4 异常

异常是明显偏离正常规律的数据点。

常见异常：
- 单点尖峰。
- 持续偏高/偏低。
- 突然阶跃。
- 趋势斜率变化。
- 周期规律消失。

## 四、时间序列预测的基本原理

预测的核心假设：

```text
未来与过去不是完全相同，但过去的模式对未来有参考价值。
```

常见方法分三类：

### 4.1 统计模型

适合数据量不大、可解释性要求高的场景。

| 模型 | 适合场景 |
| --- | --- |
| Moving Average | 平滑短期波动 |
| Exponential Smoothing | 短期趋势预测 |
| AR | 当前值依赖过去值 |
| MA | 当前值依赖历史误差 |
| ARIMA | 非季节单变量预测 |
| SARIMA | 带季节性的单变量预测 |

优点：
- 可解释。
- 对小数据友好。
- 工程简单。

缺点：
- 对复杂非线性、多变量关系支持弱。
- 特征扩展能力有限。

### 4.2 机器学习模型

把时间序列转成监督学习问题：

```text
用过去窗口特征预测未来值

y[t] = f(y[t-1], y[t-2], rolling_mean, weekday, holiday, ...)
```

常用模型：
- 线性回归。
- 随机森林。
- Gradient Boosting。
- XGBoost / LightGBM。
- SVR。

优点：
- 能融合外部特征。
- 工程灵活。
- 对非线性有更强表达能力。

缺点：
- 需要手工构造特征。
- 多步预测要额外设计策略。

### 4.3 深度学习模型

适合大数据、多变量、复杂模式。

常见模型：
- RNN / LSTM / GRU。
- TCN。
- Transformer。
- Informer / Autoformer / PatchTST。
- Chronos、TimesFM 等时间序列基础模型。

优点：
- 表达能力强。
- 适合复杂多变量序列。

缺点：
- 训练成本高。
- 可解释性较弱。
- 工程复杂度高。

## 五、预测任务的常见类型

### 5.1 单步预测

预测下一个时间点：

```text
输入：过去 30 天销量
输出：明天销量
```

### 5.2 多步预测

预测未来多个点：

```text
输入：过去 90 天销量
输出：未来 7 天销量
```

### 5.3 单变量预测

只用目标变量自身历史值：

```text
过去订单量 -> 未来订单量
```

### 5.4 多变量预测

同时使用多个特征：

```text
过去订单量 + 价格 + 活动 + 节假日 + 天气 -> 未来订单量
```

## 六、时间序列预测标准流程

```text
数据采集
  ↓
时间对齐与重采样
  ↓
缺失值和异常值处理
  ↓
特征工程
  ↓
时间切分训练/验证/测试
  ↓
训练预测模型
  ↓
评估误差
  ↓
生成预测结果
  ↓
大模型解释和报告
  ↓
上线监控与漂移检测
```

关键原则：
- 不要随机切分训练集和测试集。
- 不要让未来数据泄露到过去特征中。
- 预测结果必须带误差评估。
- 大模型生成的解释要引用真实指标和模型输出。

## 七、常用特征工程

### 7.1 滞后特征

```text
lag_1 = y[t-1]
lag_7 = y[t-7]
lag_30 = y[t-30]
```

适合表达“过去影响现在”。

### 7.2 滚动统计

```text
rolling_mean_7 = 过去 7 天均值
rolling_std_7 = 过去 7 天标准差
rolling_max_7 = 过去 7 天最大值
```

注意：滚动窗口不能包含当前目标值之后的数据。

### 7.3 时间特征

```text
hour
day_of_week
day_of_month
month
quarter
is_weekend
is_holiday
```

### 7.4 周期编码

对小时、星期、月份这类周期变量，推荐用 sin/cos 编码：

```text
hour_sin = sin(2π * hour / 24)
hour_cos = cos(2π * hour / 24)
```

避免模型误以为 `23` 点和 `0` 点距离很远。

## 八、评估指标

| 指标 | 公式含义 | 特点 |
| --- | --- | --- |
| MAE | 平均绝对误差 | 直观、抗异常较强 |
| RMSE | 均方根误差 | 对大误差更敏感 |
| MAPE | 平均百分比误差 | 业务可读性好，但真实值接近 0 时不稳定 |
| SMAPE | 对称百分比误差 | 比 MAPE 更稳定 |
| WAPE | 加权绝对百分比误差 | 适合销量/流量预测 |

Rust 中可以自己实现：

```rust
fn mae(y_true: &[f64], y_pred: &[f64]) -> f64 {
    y_true
        .iter()
        .zip(y_pred.iter())
        .map(|(a, p)| (a - p).abs())
        .sum::<f64>()
        / y_true.len() as f64
}

fn rmse(y_true: &[f64], y_pred: &[f64]) -> f64 {
    let mse = y_true
        .iter()
        .zip(y_pred.iter())
        .map(|(a, p)| (a - p).powi(2))
        .sum::<f64>()
        / y_true.len() as f64;
    mse.sqrt()
}
```

## 九、Rust 时间序列技术栈

| 方向 | 推荐库 | 说明 |
| --- | --- | --- |
| 时间处理 | `chrono`、`time` | 日期解析、时间窗口 |
| 数据处理 | `polars` | DataFrame、CSV、Parquet、分组聚合 |
| 数值计算 | `ndarray` | 矩阵和数组计算 |
| 机器学习 | `smartcore`、`linfa` | 传统机器学习模型 |
| 深度学习推理 | `ort`、`candle`、`tch` | ONNX / Rust 原生推理 |
| 可视化 | `plotters` | 生成折线图、误差图 |
| Web 服务 | `axum`、`actix-web` | 预测 API |
| 大模型调用 | `reqwest`、`serde` | 调用 llama.cpp/Ollama/vLLM |

推荐组合：

```text
polars + ndarray + smartcore + axum + reqwest
```

## 十、Rust 示例：用滞后特征做预测

以下示例演示“把时间序列转成监督学习问题”的核心思路。

### 10.1 示例数据

`sales.csv`：

```csv
date,value
2026-01-01,120
2026-01-02,132
2026-01-03,128
2026-01-04,150
2026-01-05,160
```

真实项目中建议至少包含：

```csv
timestamp,value,category,region,price,promotion
```

### 10.2 Cargo 依赖

```toml
[dependencies]
anyhow = "1"
chrono = { version = "0.4", features = ["serde"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
csv = "1"
smartcore = "0.3"
reqwest = { version = "0.12", features = ["json"] }
tokio = { version = "1", features = ["full"] }
```

### 10.3 构造 lag 特征

```rust
use anyhow::Result;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct Row {
    date: String,
    value: f64,
}

#[derive(Debug)]
struct Sample {
    features: Vec<f64>,
    target: f64,
}

fn build_lag_samples(values: &[f64], lag: usize) -> Vec<Sample> {
    let mut samples = Vec::new();

    for i in lag..values.len() {
        let features = (1..=lag)
            .map(|offset| values[i - offset])
            .collect::<Vec<_>>();

        samples.push(Sample {
            features,
            target: values[i],
        });
    }

    samples
}

fn load_values(path: &str) -> Result<Vec<f64>> {
    let mut rdr = csv::Reader::from_path(path)?;
    let mut values = Vec::new();

    for row in rdr.deserialize::<Row>() {
        let row = row?;
        values.push(row.value);
    }

    Ok(values)
}
```

### 10.4 训练回归模型

```rust
use anyhow::Result;
use smartcore::ensemble::random_forest_regressor::{
    RandomForestRegressor, RandomForestRegressorParameters,
};
use smartcore::linalg::basic::matrix::DenseMatrix;

fn train_forecast_model(samples: &[Sample]) -> Result<RandomForestRegressor<f64, f64, DenseMatrix<f64>, Vec<f64>>> {
    let x = samples
        .iter()
        .map(|s| s.features.clone())
        .collect::<Vec<_>>();
    let y = samples.iter().map(|s| s.target).collect::<Vec<_>>();

    let x = DenseMatrix::from_2d_vec(&x);
    let model = RandomForestRegressor::fit(
        &x,
        &y,
        RandomForestRegressorParameters::default(),
    )?;

    Ok(model)
}
```

### 10.5 预测下一步

```rust
fn predict_next(
    model: &RandomForestRegressor<f64, f64, DenseMatrix<f64>, Vec<f64>>,
    recent_values: &[f64],
    lag: usize,
) -> Result<f64> {
    let features = (1..=lag)
        .map(|offset| recent_values[recent_values.len() - offset])
        .collect::<Vec<_>>();

    let x = DenseMatrix::from_2d_vec(&vec![features]);
    let pred = model.predict(&x)?;
    Ok(pred[0])
}
```

说明：
- 这个示例用于理解核心流程。
- 工程版需要补训练/验证切分、指标评估、异常处理、模型保存。
- 多步预测可以递归预测，或直接训练多输出模型。

## 十一、Rust + 大模型的组合方式

大模型在时间序列任务里更适合做这些事：

| 能力 | 说明 |
| --- | --- |
| 预测解释 | 把模型输出转成业务可读语言 |
| 异常归因 | 结合日志、工单、事件说明可能原因 |
| 报告生成 | 生成日报、周报、风险摘要 |
| RAG 查询 | 查询设备手册、运营规则、历史案例 |
| Agent 编排 | 自动调用预测、异常检测、图表生成工具 |
| 策略建议 | 根据预测结果给出备货、扩容、检修建议 |

不建议直接让大模型裸预测：

```text
请根据这 100 个数字预测下一个值
```

原因：
- 数值稳定性差。
- 可复现性弱。
- 误差难以评估。
- 不适合高频、严肃预测。

推荐：

```text
Rust 预测模型输出结构化结果
  ↓
大模型读取结构化结果
  ↓
生成解释、报告、建议
```

## 十二、示例：Rust 调用本地大模型生成预测报告

假设本地已经启动 `llama-server`：

```bash
./llama-server -m models/qwen2.5-7b-instruct-q4_k_m.gguf --host 127.0.0.1 --port 8080
```

Rust 调用 OpenAI 兼容接口：

```rust
use anyhow::Result;
use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
struct ChatRequest {
    model: String,
    messages: Vec<ChatMessage>,
    temperature: f32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct ChatMessage {
    role: String,
    content: String,
}

#[derive(Debug, Deserialize)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Debug, Deserialize)]
struct Choice {
    message: ChatMessage,
}

#[derive(Debug, Serialize)]
struct ForecastSummary {
    metric_name: String,
    history_window: String,
    forecast_horizon: String,
    current_value: f64,
    predicted_value: f64,
    mae: f64,
    rmse: f64,
    anomaly_score: Option<f64>,
}

async fn generate_forecast_report(summary: &ForecastSummary) -> Result<String> {
    let client = Client::new();
    let summary_json = serde_json::to_string_pretty(summary)?;

    let prompt = format!(
        r#"你是时间序列分析助手。请根据以下结构化预测结果生成中文分析报告。

要求：
1. 说明当前趋势。
2. 解释预测值与当前值的差异。
3. 根据 MAE/RMSE 判断预测可信度。
4. 如果 anomaly_score 存在，说明异常风险。
5. 给出业务建议。
6. 不要编造输入中没有的数据。

预测结果：
{}"#,
        summary_json
    );

    let req = ChatRequest {
        model: "local-model".to_string(),
        temperature: 0.2,
        messages: vec![
            ChatMessage {
                role: "system".to_string(),
                content: "你是严谨的时间序列分析助手，只基于输入数据进行解释。".to_string(),
            },
            ChatMessage {
                role: "user".to_string(),
                content: prompt,
            },
        ],
    };

    let resp = client
        .post("http://127.0.0.1:8080/v1/chat/completions")
        .json(&req)
        .send()
        .await?
        .json::<ChatResponse>()
        .await?;

    Ok(resp
        .choices
        .first()
        .map(|c| c.message.content.clone())
        .unwrap_or_default())
}
```

调用示例：

```rust
#[tokio::main]
async fn main() -> Result<()> {
    let summary = ForecastSummary {
        metric_name: "订单量".to_string(),
        history_window: "最近 90 天".to_string(),
        forecast_horizon: "未来 1 天".to_string(),
        current_value: 1280.0,
        predicted_value: 1450.0,
        mae: 86.5,
        rmse: 112.3,
        anomaly_score: Some(0.72),
    };

    let report = generate_forecast_report(&summary).await?;
    println!("{}", report);
    Ok(())
}
```

## 十三、示例：大模型辅助异常解释

### 13.1 Rust 侧异常结果结构

```rust
use serde::Serialize;

#[derive(Debug, Serialize)]
struct AnomalyEvent {
    metric: String,
    timestamp: String,
    value: f64,
    expected: f64,
    deviation: f64,
    severity: String,
    recent_context: Vec<f64>,
    related_events: Vec<String>,
}
```

### 13.2 Prompt 模板

```text
你是工业设备异常分析助手。

输入包含：
- 当前指标值
- 预测期望值
- 偏差
- 最近上下文
- 相关事件

请输出：
1. 异常等级判断
2. 可能原因
3. 需要补充排查的数据
4. 建议处理动作
5. 是否需要人工确认

限制：
- 不要把猜测说成事实。
- 如果证据不足，明确写“需要进一步确认”。
```

### 13.3 大模型输出示例

```text
异常等级：中高

当前温度值高于预测期望值，偏差达到 18.5%，且最近窗口呈连续上升趋势。

可能原因：
1. 冷却系统效率下降。
2. 设备负载增加。
3. 温度传感器漂移。

建议：
1. 检查最近 30 分钟负载曲线。
2. 对比同类设备温度变化。
3. 检查冷却风扇和冷却液状态。
4. 如果温度继续上升，触发人工巡检。
```

## 十四、Rust + RAG + 时间序列

如果预测结果需要结合业务文档解释，可以加入 RAG。

例如：

```text
预测模型发现设备温度异常
  ↓
RAG 检索设备手册、故障码、历史工单
  ↓
大模型综合预测结果和检索内容
  ↓
生成诊断报告和处理建议
```

RAG 检索输入可以包含：

```json
{
  "metric": "compressor_temperature",
  "anomaly_type": "continuous_rise",
  "equipment_type": "air_compressor",
  "error_code": "E101"
}
```

大模型最终看到的是：

```text
结构化预测结果
+ 检索到的设备手册片段
+ 历史相似案例
+ 当前上下文
```

这比单纯让大模型猜原因可靠得多。

## 十五、Rust + Agent + 时间序列

Agent 可以把预测模型包装成工具，让大模型决定何时调用。

### 15.1 工具设计

```rust
#[derive(Debug, serde::Deserialize)]
struct ForecastToolInput {
    metric: String,
    horizon: usize,
    window: usize,
}

#[derive(Debug, serde::Serialize)]
struct ForecastToolOutput {
    metric: String,
    predictions: Vec<f64>,
    mae: Option<f64>,
    rmse: Option<f64>,
    confidence: String,
}
```

### 15.2 Agent 工具列表

```text
forecast_metric(metric, horizon, window)
detect_anomaly(metric, start_time, end_time)
query_events(metric, start_time, end_time)
search_docs(query)
generate_chart(metric, start_time, end_time)
create_report(report_type, data)
```

### 15.3 Agent 工作流

```text
用户：分析过去 7 天订单量，并预测明天是否需要扩容
  ↓
Agent 调用 forecast_metric
  ↓
Agent 调用 detect_anomaly
  ↓
Agent 调用 query_events 查询活动/故障/促销
  ↓
Agent 调用 search_docs 查询扩容规则
  ↓
Agent 生成预测说明和建议
```

## 十六、时间序列基础模型与 Rust

近年来有一些时间序列基础模型：
- Chronos。
- TimesFM。
- PatchTST。
- Lag-Llama。
- Moirai。

在 Rust 中使用这类模型有三种路线：

### 16.1 Python 训练/推理服务 + Rust 调用

```text
Python 时间序列模型服务
  ↓ HTTP/gRPC
Rust 业务服务
```

优点：
- 生态成熟。
- 模型支持完整。

缺点：
- 多语言部署。
- 延迟和运维复杂度增加。

### 16.2 导出 ONNX + Rust `ort` 推理

```text
Python 训练模型
  ↓
导出 ONNX
  ↓
Rust ort 加载模型
  ↓
本地推理
```

适合：
- 边缘部署。
- 低延迟预测服务。
- 训练和推理分离。

### 16.3 Candle / tch Rust 原生推理

适合：
- 自定义模型结构。
- Rust 原生部署。
- 小模型和特定模型适配。

成本：
- 模型适配工作更多。
- 生态不如 Python 完整。

## 十七、工程架构建议

推荐目录结构：

```text
time-series-ai/
  Cargo.toml
  config/
    app.toml
  data/
    sales.csv
  src/
    main.rs
    data/
      mod.rs
      loader.rs
      resample.rs
    features/
      mod.rs
      lag.rs
      rolling.rs
      calendar.rs
    models/
      mod.rs
      baseline.rs
      regression.rs
      forecast.rs
    metrics/
      mod.rs
      error.rs
    llm/
      mod.rs
      client.rs
      prompts.rs
    api/
      mod.rs
      routes.rs
    report/
      mod.rs
      generator.rs
```

### 17.1 核心模块

| 模块 | 职责 |
| --- | --- |
| `data` | 数据读取、时间对齐、缺失处理 |
| `features` | lag、rolling、calendar 特征 |
| `models` | 预测模型训练与推理 |
| `metrics` | MAE、RMSE、MAPE |
| `llm` | 调用本地大模型 |
| `api` | 对外提供预测接口 |
| `report` | 生成分析报告 |

## 十八、API 设计示例

### 18.1 预测请求

```json
{
  "metric": "orders",
  "horizon": 7,
  "window": 90,
  "include_report": true
}
```

### 18.2 预测响应

```json
{
  "metric": "orders",
  "horizon": 7,
  "predictions": [1420, 1388, 1512, 1490, 1601, 1703, 1688],
  "metrics": {
    "mae": 86.5,
    "rmse": 112.3
  },
  "trend": "up",
  "risk_level": "medium",
  "report": "未来 7 天订单量整体呈上升趋势，其中第 6 天预测值较高，建议提前评估库存和服务容量。"
}
```

## 十九、常见坑

### 19.1 数据泄露

错误做法：

```text
用全量数据计算 rolling_mean，再切训练/测试
```

正确做法：

```text
先按时间切分，再在每个时间点只使用过去窗口计算特征
```

### 19.2 随机切分

时间序列不能像普通表格数据一样随机切分。

推荐：

```text
训练集：过去 70%
验证集：中间 15%
测试集：最近 15%
```

### 19.3 大模型幻觉

大模型报告必须绑定结构化输入。

Prompt 中要明确：

```text
不要编造未提供的数据。
如果证据不足，明确说明需要进一步确认。
```

### 19.4 只做预测不做监控

上线后需要监控：
- MAE / RMSE 漂移。
- 数据分布变化。
- 异常率变化。
- 预测偏差方向。
- 模型版本效果。

## 二十、推荐落地路线

### 20.1 MVP 阶段

```text
CSV 数据
  ↓
Rust 构造 lag/rolling 特征
  ↓
smartcore 训练回归模型
  ↓
输出预测结果和 MAE/RMSE
  ↓
调用本地 llama.cpp 生成中文报告
```

### 20.2 工程化阶段

```text
数据库/消息队列
  ↓
定时训练与模型版本管理
  ↓
预测 API
  ↓
异常检测 API
  ↓
RAG 结合业务文档
  ↓
Agent 自动分析和生成报告
```

### 20.3 高阶阶段

```text
深度时间序列模型
  ↓
ONNX 导出
  ↓
Rust ort 推理
  ↓
多指标联合预测
  ↓
LLM 解释 + RAG 证据 + Agent 工具执行
```

## 二十一、面试/方案答法

如果被问“Rust 如何做时间序列预测并结合大模型”，可以这样答：

```text
我会把系统拆成两层。

第一层是数值预测层，用 Rust 读取和清洗时间序列数据，构造 lag、rolling、calendar 等特征，再用统计模型或机器学习模型做预测，并用 MAE、RMSE 等指标评估。

第二层是大模型解释层。预测模型输出结构化结果后，大模型只负责解释趋势、异常原因、业务影响和处理建议。如果需要结合设备手册或历史案例，会用 RAG 检索证据；如果需要自动化操作，会把预测、异常检测、查日志、生成图表封装成 Agent 工具。

这样既保证数值预测可评估，又能利用大模型提升可读性和决策支持能力。
```

## 二十二、总结

Rust 适合做时间序列预测系统的工程底座：
- 性能好。
- 类型安全。
- 适合部署服务和边缘端。
- 可与本地大模型、RAG、Agent 结合。

大模型适合做解释和决策辅助，不应该替代全部预测算法。

推荐实践：

```text
传统/机器学习预测模型
  +
Rust 高性能服务
  +
本地大模型报告生成
  +
RAG 业务证据
  +
Agent 工具编排
```
