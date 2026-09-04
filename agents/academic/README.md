# 论文协作 Agent 模板

这组公开模板从已有的四角色论文协作配置中提炼，保留职责划分、实验交接、检查与内审闭环。原始论文、具体研究命题、实验参数、实际诊断、数据、代码和未发表结果没有收入本目录。

这里的 Agent 是可交给助手或子代理的角色提示词。它们不包含运行器，也不会自行启动多个进程；`skills/<skill>/agents/openai.yaml` 则是 Skill 的展示与调用元数据，不能当作同类 Agent 定义。

## 使用前填写项目上下文

| 变量 | 含义 |
| --- | --- |
| `PROJECT_ROOT` | 经用户指定的项目工作目录 |
| `MANUSCRIPT_PATH` | 当前稿件路径；默认相对路径 `manuscript/manuscript_working.md`，已有 LaTeX 项目使用其现有入口 |
| `SOURCE_MANUSCRIPT` | 原始稿件路径，仅用于读取；由用户提供 |
| `CODE_ROOT` | 实验代码目录，由用户提供 |
| `TARGET_JOURNAL` | 目标期刊；未指定时采用通用期刊投稿标准 |
| `RESEARCH_QUESTION` | 作者确认的研究问题 |
| `CLAIM_EVIDENCE_MAP` | 主张、证据、限制与对应实验的映射 |
| `PROJECT_CONSTRAINTS` | 数据权限、算力、预算、截止日期和已确认的方法边界 |

不要把空白变量当作已经确定的事实。启动时先读取作者提供的材料；缺少信息时明确记录假设，不编造研究结果。

## 四个角色

| 角色 | 提示词 | 主要产物 |
| --- | --- | --- |
| 写论文 Agent | [writer_agent.md](writer_agent.md) | 研究主线、实验请求、修改稿 |
| 编码 Agent | [coder_agent.md](coder_agent.md) | 可复现实验、数据表、图片、运行日志 |
| 检查论文 Agent | [checker_agent.md](checker_agent.md) | 一致性检查、证据缺口与问题清单 |
| 审核 Agent | [reviewer_agent.md](reviewer_agent.md) | 内审决策、必须修改项与下一轮通过条件 |

建议工作目录：

```text
PROJECT_ROOT/
├── manuscript/
├── experiments/
├── review/
│   ├── checks/
│   └── decisions/
└── logs/
    ├── project_status.md
    └── revision_log.md
```

路径均相对于 `PROJECT_ROOT`。优先保留现有项目的目录和文件格式；不要为了套用模板移动原始研究文件。完整交接规则见 [workflow.md](workflow.md)。

## 使用范围

适用于科学论文的写作、实验复现、一致性检查与投稿前内审。Energy 可作为能源方向项目的 `TARGET_JOURNAL` 示例；其他领域应替换为对应期刊要求，角色模板不预设具体研究命题。

内审结论只表示内部准备程度，不代表期刊接收保证。投稿、上传、发送邮件或公开研究材料，需要用户明确授权。
