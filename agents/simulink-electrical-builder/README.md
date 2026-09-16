# Simulink Electrical Builder · 电气仿真搭建 Agent

**把 MATLAB / Simulink 官方例程当成模块来源，先确认系统结构，再组合成可复现、可检查兼容性的电气工程仿真。**

[Skill 源码](../../skills/simulink-electrical-builder/SKILL.md) · [系统提示词](SYSTEM_PROMPT.md)

## 适合做什么

- 微电网：同步机 / 燃机、风电、光伏、BESS、负载、母线、线路、变压器、故障与保护
- 电力电子：GFM / GFL、VSM、Droop、PLL、限流、虚拟阻抗、PWM / 平均值模型
- 风电：DFIG、Type-4、MPPT、桨距、变流器、并网故障
- 电机与驱动：PMSM、感应电机、逆变器、FOC
- 电力系统：潮流初始化、电磁暂态、电机暂态、弱电网、故障穿越、频率支撑
- HIL / 实时：固定步长、模块降阶、多速率接口

## 它和普通“帮我画 Simulink”不一样

这个 Agent 不会一上来就堆模块，而是按以下顺序工作：

1. **先确认用途**：你到底要研究什么物理问题。
2. **确认拓扑**：哪些设备、哪条母线、怎么连接。
3. **确定保真度**：平均值、机电暂态、EMT、开关级还是实时模型。
4. **检查 MATLAB 环境**：版本、Simscape Electrical、旧 SPS、控制工具箱等。
5. **从例程库选模块**：记录模块来自哪个 MathWorks 例程/库。
6. **做兼容性检查**：后端、频率、电压基值、pu/SI、dq 约定、采样时间、求解器等。
7. **生成模型**：输出 JSON 蓝图 + MATLAB 搭建脚本，并在有 MATLAB 执行环境时生成 `.slx`。
8. **验证**：update/compile、短时仿真、关键扰动和物理量检查。

## 用法

```text
用 Simulink Electrical Builder：
我要搭一个海上平台微电网，包含燃气轮机、风电、储能和 GFM 变流器，主要研究三相短路期间的频率、电压和电流限幅。
MATLAB 是 R2021b。
```

Agent 会先返回类似：

```text
研究用途：故障期间 EMT / 暂态稳定
建议结构：GRID/GT — BUS — WIND — BESS/GFM — LOAD — FAULT — MEASUREMENT
后端候选：R2021b 需要先检测现有 SPS / Simscape Electrical 环境
待确认：是否保留开关级 PWM，还是先使用平均值变流器
```

确认后才开始选例程和搭建。

## 例程库

当前第一版目录覆盖：

- Remote Microgrid
- Grid-Forming Converter
- DFIG Wind Power System
- Wind Turbine supervisory / MPPT / pitch
- Three-Phase PMSM Drive
- ThreePhaseExamples custom component library
- Simscape Electrical load flow
- Transformer component family
- SPS → Simscape Electrical conversion workflow

完整机器可读目录见 [`catalog/examples.json`](../../skills/simulink-electrical-builder/catalog/examples.json)。

## 兼容性原则

最重要的一条：**不要把“能找到的模块”直接拼在一起。**

Agent 会检查：

- Simscape Electrical native 与 Specialized Power Systems 是否混用
- R2026a+ 已移除 SPS 的版本问题
- 50/60 Hz、额定电压、容量和变压器变比
- SI / pu 及 pu 基值
- abc / αβ / dq 与 Park 变换符号
- RMS / 峰值
- Hz / rad/s
- 机电暂态 / EMT / phasor 域
- 连续 / 离散求解器
- 控制采样时间、PWM 频率与仿真步长
- 功率正负号、角度参考、PLL/VSM 角度来源

详见 [`catalog/compatibility.md`](../../skills/simulink-electrical-builder/catalog/compatibility.md)。

## MATLAB 侧文件

- `simee_detect_environment.m`：检测 MATLAB 版本、产品、SPS 是否存在
- `simee_validate_blueprint.m`：搭建前静态兼容性检查
- `simee_build.m`：读取 JSON 蓝图并程序化生成 Simulink 模型

生成模型使用的是 MATLAB / Simulink 的程序化接口，因此模型结构可以复现，而不是只保留一个无法追踪来源的二进制 `.slx`。

## 搜索关键词

Simulink agent, Simulink builder, electrical simulation, Simscape Electrical, microgrid Simulink, power electronics Simulink, MATLAB model generation, GFM simulation, DFIG Simulink, 电气工程仿真, Simulink 自动搭建, 微电网仿真。
