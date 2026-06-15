# AI 与 ROS2 开发结合方案

本文整理 AI 如何与 ROS2 开发结合，包括典型应用场景、系统架构、节点设计、模型部署方式、Rust 结合方式，以及相关学习资料。

核心理解：

```text
ROS2：负责机器人通信、节点调度、传感器接入、控制执行
AI：负责感知、识别、预测、异常检测、语义理解
大模型：负责自然语言交互、任务拆解、工具调用、报告生成
```

不要让大模型直接控制底盘、电机或机械臂低层动作。推荐让大模型做高层任务规划，具体执行仍交给 ROS2、Nav2、MoveIt2 和安全控制模块。

## 一、AI 与 ROS2 的关系

ROS2 是机器人系统的工程底座，提供：

- 节点通信。
- Topic、Service、Action。
- 传感器消息。
- 坐标变换。
- 参数管理。
- 生命周期管理。
- 数据记录与回放。
- 导航、建图、运动规划生态。

AI 则补充机器人智能能力：

- 图像识别。
- 语音识别。
- 目标检测。
- 点云理解。
- 异常检测。
- 预测性维护。
- 任务规划。
- 多模态交互。

典型组合：

```text
传感器数据
  ↓
ROS2 Topic
  ↓
AI 推理节点
  ↓
结构化感知结果
  ↓
导航 / 机械臂 / 决策节点
  ↓
机器人执行
```

## 二、典型结合场景

### 2.1 AI 做视觉感知

机器人摄像头、深度相机、工业相机采集图像后，由 AI 模型做检测、分割、识别。

常见任务：

| 任务 | 模型/技术 | ROS2 输出 |
| --- | --- | --- |
| 目标检测 | YOLO、RT-DETR、Detectron2 | `/detections` |
| 图像分割 | SAM、Mask R-CNN、U-Net | `/segmentation_mask` |
| 姿态估计 | MediaPipe、OpenPose | `/pose_landmarks` |
| OCR | PaddleOCR、RapidOCR | `/ocr_result` |
| 多模态理解 | Qwen-VL、LLaVA | `/scene_description` |

典型流程：

```text
/camera/image_raw
  ↓
AI Inference Node
  ↓
/detections
  ↓
导航避障 / 机械臂抓取 / 人机交互
```

### 2.2 AI 增强导航

ROS2 的 Nav2 可以完成定位、建图、路径规划和避障。AI 可以增强语义理解和复杂场景判断。

AI 可做：

- 识别门、桌子、充电桩、人、货架。
- 预测动态障碍物轨迹。
- 识别危险区域。
- 根据语音指令转成导航目标。
- 构建语义地图。

推荐分工：

```text
Nav2：负责可验证的路径规划和避障
AI：负责场景语义、目标识别、意图理解
```

示例：

```text
用户：去会议室找红色箱子
  ↓
大模型解析任务
  ↓
视觉模型识别红色箱子
  ↓
Nav2 导航到目标附近
  ↓
机器人执行靠近或抓取
```

### 2.3 AI 与机械臂操作

机械臂通常结合 MoveIt2 做运动规划。AI 可以负责目标识别、位姿估计、抓取点生成。

典型流程：

```text
RGB-D Camera
  ↓
目标检测 / 分割
  ↓
6D Pose Estimation
  ↓
Grasp Planner
  ↓
MoveIt2
  ↓
机械臂执行
```

常见任务：

- 根据语言选择目标物体。
- 识别目标位置。
- 估计物体姿态。
- 生成抓取候选点。
- 判断抓取是否成功。

### 2.4 AI 做语音与人机交互

AI 可用于：

- ASR：语音转文本。
- TTS：文本转语音。
- NLU：理解用户意图。
- LLM：多轮对话和任务拆解。

流程：

```text
麦克风
  ↓
Whisper / ASR
  ↓
大模型理解指令
  ↓
ROS2 Tool / Action
  ↓
机器人执行
  ↓
TTS 反馈
```

### 2.5 AI 做异常检测和预测性维护

机器人运行状态本质上也是时间序列数据。

常见数据：

- `/joint_states`
- `/battery_state`
- `/imu/data`
- 电机电流。
- 电机温度。
- 关节扭矩。
- 轮速。
- 传感器在线状态。

AI 可用于：

- 异常检测。
- 故障预测。
- 电池寿命预测。
- 维护建议生成。
- 运行状态报告。

流程：

```text
/joint_states / battery_state / imu
  ↓
Feature Extractor
  ↓
Anomaly Detection Model
  ↓
/diagnostics
  ↓
大模型生成维护建议
```

## 三、AI + ROS2 系统架构

推荐架构：

```text
Sensors
  ↓
ROS2 Drivers
  ↓
Perception Topics
  ↓
AI Inference Nodes
  ↓
Semantic Topics
  ↓
Planner / Agent / Decision Node
  ↓
Nav2 / MoveIt2 / Controller
  ↓
Robot Actuators
```

更完整的智能机器人架构：

```text
用户指令
  ↓
ASR / Text Input
  ↓
LLM Agent
  ↓
任务拆解
  ↓
ROS2 Tools:
  - navigate_to
  - detect_object
  - pick_object
  - place_object
  - query_battery
  - stop_robot
  ↓
Nav2 / MoveIt2 / Perception
  ↓
执行结果
  ↓
LLM 总结反馈
```

## 四、ROS2 中 AI 节点设计

### 4.1 Topic 模式

适合持续推理任务。

例如图像检测：

```text
订阅：/camera/image_raw
发布：/detections
```

特点：

- 数据流持续。
- 延迟较低。
- 适合摄像头、雷达、状态监控。

### 4.2 Service 模式

适合请求-响应式推理。

例如：

```text
请求：识别当前图片中的物体
响应：物体列表、置信度、位置
```

特点：

- 简单直接。
- 适合一次性识别。
- 不适合长时间任务。

### 4.3 Action 模式

适合耗时任务。

例如：

```text
导航到目标点
机械臂抓取物体
生成巡检报告
```

特点：

- 支持目标、反馈、取消、结果。
- 适合机器人复杂行为。

## 五、模型部署方式

### 5.1 Python 节点直接推理

```text
rclpy 节点
  ↓
PyTorch / OpenCV / YOLO
  ↓
发布检测结果
```

优点：

- 开发快。
- AI 生态成熟。
- 适合验证和原型。

缺点：

- 性能和部署体积需要优化。
- 对实时性较高的场景可能不够。

### 5.2 ONNX Runtime 推理

```text
训练模型
  ↓
导出 ONNX
  ↓
ROS2 C++ / Rust / Python 节点加载 ONNX
  ↓
推理输出
```

适合：

- 工程部署。
- 跨语言推理。
- CPU/GPU 加速。
- 边缘设备。

### 5.3 TensorRT / OpenVINO 加速

适合工业部署：

- NVIDIA 设备：TensorRT。
- Intel 设备：OpenVINO。
- ARM/边缘设备：ONNX Runtime、TFLite、NCNN。

### 5.4 本地大模型部署

可选方案：

- `llama.cpp + GGUF`
- Ollama
- vLLM
- Candle
- ONNX Runtime GenAI

推荐在 ROS2 外部单独部署 LLM 服务：

```text
LLM Server
  ↑ HTTP/gRPC
ROS2 Agent Node
  ↓ ROS2 Topic/Service/Action
Robot System
```

这样可以避免大模型阻塞 ROS2 实时链路。

## 六、大模型在 ROS2 中的定位

大模型适合：

- 自然语言理解。
- 高层任务规划。
- 多步骤任务拆解。
- 工具调用。
- 失败原因解释。
- 巡检报告生成。
- 人机对话。

大模型不适合：

- 低层电机控制。
- 高频闭环控制。
- 实时避障唯一决策。
- 安全关键动作的直接执行。

推荐安全边界：

```text
LLM 只能提出计划和调用受控工具
安全控制器负责最终动作许可
紧急停止逻辑独立于 LLM
```

## 七、ROS2 Agent 工具设计

把 ROS2 能力封装成工具，让大模型调用。

示例工具：

```text
navigate_to(location)
detect_object(object_name)
pick_object(object_id)
place_object(location)
query_robot_state()
query_battery()
stop_robot()
speak(text)
generate_inspection_report()
```

工具调用流程：

```text
用户：去仓库 A 找一个红色箱子并拿回来
  ↓
LLM 生成计划
  ↓
调用 navigate_to("warehouse_a")
  ↓
调用 detect_object("red box")
  ↓
调用 pick_object(object_id)
  ↓
调用 navigate_to("home")
  ↓
调用 place_object("table")
```

## 八、Rust 与 ROS2 结合

Rust 适合做：

- 高性能边缘推理服务。
- 类型安全的机器人业务逻辑。
- 本地 LLM HTTP 客户端。
- ONNX Runtime 推理节点。
- 状态监控与异常检测。
- Agent 工具服务。

常用库：

| 方向 | Rust 库 |
| --- | --- |
| ROS2 客户端 | `r2r`、`ros2-rust` |
| ONNX 推理 | `ort` |
| Rust 原生推理 | `candle` |
| HTTP 调用 LLM | `reqwest` |
| 序列化 | `serde`、`serde_json` |
| 异步运行时 | `tokio` |
| Web 服务 | `axum` |
| 图像处理 | `image`、OpenCV bindings |

推荐组合：

```text
r2r + tokio + ort + reqwest + serde
```

### 8.1 Rust 节点示例：订阅状态并调用大模型

示例只展示思路：

```rust
use anyhow::Result;
use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
struct RobotStateSummary {
    battery_percent: f32,
    motor_temperature: f32,
    error_codes: Vec<String>,
}

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

async fn explain_robot_state(summary: &RobotStateSummary) -> Result<String> {
    let client = Client::new();
    let data = serde_json::to_string_pretty(summary)?;

    let prompt = format!(
        r#"你是机器人运维助手。请根据以下机器人状态生成诊断说明和处理建议。

要求：
1. 只基于输入数据分析。
2. 如果证据不足，明确说明需要进一步检查。
3. 不要直接下达危险动作。

机器人状态：
{}"#,
        data
    );

    let req = ChatRequest {
        model: "local-model".to_string(),
        temperature: 0.2,
        messages: vec![
            ChatMessage {
                role: "system".to_string(),
                content: "你是严谨的 ROS2 机器人运维分析助手。".to_string(),
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

### 8.2 Rust + ROS2 + ONNX 推理流程

```text
Camera Topic
  ↓
Rust ROS2 Node
  ↓
ort 加载 ONNX 模型
  ↓
推理得到检测框
  ↓
发布 Detection Topic
```

适合在边缘设备上部署轻量模型。

## 九、数据采集与训练闭环

ROS2 的重要优势是可以用 `rosbag2` 记录数据。

闭环流程：

```text
机器人运行
  ↓
rosbag2 记录图像、雷达、状态、控制指令
  ↓
离线标注与清洗
  ↓
Python 训练 AI 模型
  ↓
导出 ONNX / TensorRT
  ↓
ROS2 节点部署
  ↓
上线继续采集失败案例
```

常见数据集：

- 摄像头图像。
- 深度图。
- 点云。
- IMU。
- 关节状态。
- 导航路径。
- 人工接管记录。
- 故障日志。

## 十、安全设计

AI + ROS2 系统必须把安全放在架构层。

### 10.1 大模型权限边界

大模型只允许调用白名单工具：

```text
允许：
- query_robot_state
- detect_object
- navigate_to 已知安全点
- generate_report

需要确认：
- pick_object
- place_object
- enter_restricted_area

禁止：
- disable_safety
- override_emergency_stop
- direct_motor_control
```

### 10.2 动作确认

高风险动作需要人工确认：

- 机械臂靠近人。
- 机器人进入危险区域。
- 搬运易碎/危险物品。
- 修改导航地图。
- 停用传感器。

### 10.3 独立安全链路

紧急停止、碰撞检测、安全区域限制不能依赖 LLM。

```text
LLM Agent
  ↓
安全策略检查
  ↓
ROS2 Action
  ↓
底层安全控制器
```

## 十一、推荐项目实战

### 项目 1：YOLO + ROS2 目标检测节点

目标：

- 订阅 `/camera/image_raw`。
- 调用 YOLO/ONNX 模型。
- 发布 `/detections`。
- 在 RViz 中显示检测结果。

学习点：

- ROS2 Topic。
- 图像消息。
- OpenCV。
- ONNX Runtime。
- AI 推理节点部署。

### 项目 2：LLM + ROS2 语音导航助手

目标：

- 用户语音输入：“去厨房”。
- Whisper 转文字。
- 大模型解析目标。
- 调用 Nav2 Action。
- TTS 回复执行状态。

学习点：

- ROS2 Action。
- Nav2。
- ASR/TTS。
- LLM 工具调用。
- 安全确认。

### 项目 3：机械臂智能抓取

目标：

- 摄像头识别目标物体。
- 估计物体位置。
- MoveIt2 规划机械臂路径。
- 执行抓取。

学习点：

- MoveIt2。
- TF 坐标变换。
- RGB-D 数据。
- Grasp Planning。

### 项目 4：机器人异常检测与运维报告

目标：

- 订阅电池、电机温度、关节状态。
- 检测异常。
- 调用本地大模型生成中文运维报告。

学习点：

- 时间序列异常检测。
- ROS2 diagnostics。
- 大模型报告生成。
- 状态监控。

## 十二、学习路线

### 阶段 1：ROS2 基础

需要掌握：

- ROS2 节点。
- Topic / Service / Action。
- 参数。
- Launch。
- TF2。
- rosbag2。
- RViz。

目标：

```text
能写一个节点，订阅传感器数据，处理后发布结果。
```

### 阶段 2：机器人核心能力

需要掌握：

- Nav2。
- SLAM Toolbox。
- MoveIt2。
- robot_state_publisher。
- URDF / xacro。
- Gazebo / Ignition 仿真。

目标：

```text
能让机器人在仿真中完成导航或机械臂规划。
```

### 阶段 3：AI 感知

需要掌握：

- OpenCV。
- YOLO。
- ONNX Runtime。
- TensorRT / OpenVINO。
- 图像消息转换。
- 检测结果消息设计。

目标：

```text
能把视觉模型封装成 ROS2 推理节点。
```

### 阶段 4：大模型和 Agent

需要掌握：

- llama.cpp / Ollama。
- Tool Calling。
- RAG。
- Agent 权限控制。
- ROS2 Service / Action 工具封装。

目标：

```text
能让大模型根据自然语言调用受控 ROS2 工具。
```

### 阶段 5：工程化部署

需要掌握：

- Docker。
- 边缘设备部署。
- 模型量化。
- 性能监控。
- 日志与审计。
- 安全策略。

目标：

```text
能构建可持续运行的 AI + ROS2 机器人系统。
```

## 十三、学习资料

### 13.1 ROS2 官方资料

- ROS2 Documentation: <https://docs.ros.org/>
- ROS2 Tutorials: <https://docs.ros.org/en/rolling/Tutorials.html>
- ROS2 Concepts: <https://docs.ros.org/en/rolling/Concepts.html>
- ROS2 CLI Tools: <https://docs.ros.org/en/rolling/Tutorials/Beginner-CLI-Tools.html>
- ROS2 Client Libraries: <https://docs.ros.org/en/rolling/Concepts/Basic/About-Client-Libraries.html>

### 13.2 Nav2 导航

- Nav2 Documentation: <https://docs.nav2.org/>
- Nav2 Getting Started: <https://docs.nav2.org/getting_started/index.html>
- Nav2 Tutorials: <https://docs.nav2.org/tutorials/index.html>

### 13.3 MoveIt2 机械臂

- MoveIt Documentation: <https://moveit.picknik.ai/>
- MoveIt2 Tutorials: <https://moveit.picknik.ai/main/doc/tutorials/tutorials.html>
- MoveIt2 GitHub: <https://github.com/moveit/moveit2>

### 13.4 仿真与机器人描述

- Gazebo Documentation: <https://gazebosim.org/docs>
- URDF Tutorial: <https://docs.ros.org/en/rolling/Tutorials/Intermediate/URDF/URDF-Main.html>
- TF2 Tutorials: <https://docs.ros.org/en/rolling/Tutorials/Intermediate/Tf2/Tf2-Main.html>

### 13.5 AI 感知与模型部署

- OpenCV Documentation: <https://docs.opencv.org/>
- Ultralytics YOLO Docs: <https://docs.ultralytics.com/>
- ONNX Runtime Documentation: <https://onnxruntime.ai/docs/>
- TensorRT Documentation: <https://docs.nvidia.com/deeplearning/tensorrt/>
- OpenVINO Documentation: <https://docs.openvino.ai/>

### 13.6 大模型与本地部署

- llama.cpp: <https://github.com/ggml-org/llama.cpp>
- Ollama: <https://ollama.com/>
- vLLM: <https://docs.vllm.ai/>
- Hugging Face Models: <https://huggingface.co/models>
- Model Context Protocol: <https://modelcontextprotocol.io/>

### 13.7 Rust 与 ROS2

- `r2r`: <https://github.com/sequenceplanner/r2r>
- `ros2_rust`: <https://github.com/ros2-rust/ros2_rust>
- `ort` Rust ONNX Runtime: <https://github.com/pykeio/ort>
- Candle: <https://github.com/huggingface/candle>
- Tokio: <https://tokio.rs/>
- Axum: <https://github.com/tokio-rs/axum>

### 13.8 推荐课程和实践

- The Construct ROS2 Courses: <https://www.theconstruct.ai/>
- Articulated Robotics ROS2 Tutorials: <https://articulatedrobotics.xyz/>
- Robotics Back-End ROS2 Tutorials: <https://roboticsbackend.com/category/ros2/>
- Nav2 Tutorials: <https://docs.nav2.org/tutorials/index.html>
- MoveIt2 Tutorials: <https://moveit.picknik.ai/main/doc/tutorials/tutorials.html>

## 十四、推荐阅读顺序

如果从零开始，建议：

1. ROS2 官方 Beginner Tutorials。
2. 写 Topic / Service / Action 示例。
3. 学 TF2、URDF、RViz。
4. 跑通 Nav2 或 MoveIt2。
5. 用 rosbag2 采集传感器数据。
6. 用 YOLO/ONNX 做一个推理节点。
7. 用 llama.cpp/Ollama 做一个 LLM 服务。
8. 把 ROS2 Action 封装成大模型工具。
9. 增加权限控制和人工确认。
10. 做一个完整机器人 Agent Demo。

## 十五、总结

AI 与 ROS2 结合的本质是：

```text
ROS2 提供机器人系统工程能力
AI 提供感知、预测、理解能力
大模型提供自然语言交互和任务规划能力
```

推荐架构是：

```text
ROS2 基础能力
  +
AI 感知节点
  +
Nav2 / MoveIt2 执行系统
  +
LLM Agent 高层编排
  +
安全策略和人工确认
```

这样既能利用 AI 提升智能化，又能保留机器人系统需要的确定性、实时性和安全边界。
