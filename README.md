# Agent Skills

个人 Agent 与 Skill 整理库：论文协作、学术写作、研究阅读、文档处理、知识管理与自动化。

更新于 **2026-09-10**。收录 **4 个学术 Agent 角色模板、SkillRover 选型 Agent、10 个 Skills 和 1 组共享资料**，并为系统技能和插件技能建立来源目录。作者与许可证归属见 [来源说明](THIRD_PARTY_NOTICES.md)。

**新增 [SkillRover · 寻技](agents/skillrover/README.md)**：工作中查找别人的 Skill，读过实现后选一个合适的，接着完成任务。[English](agents/skillrover/README.en.md)。

## 快速导航

| 需要做什么 | 从这里开始 |
| --- | --- |
| 搜索、比较并选择合适的 Skill | [SkillRover · 寻技](agents/skillrover/README.md) |
| 组织写作、编码、检查和审核协作 | [四角色 Agent](agents/academic/README.md) · [协作流程](agents/academic/workflow.md) |
| 查找可用技能 | [技能分类表](#技能分类) · [机器可读清单](catalog/skills.json) |
| 安装技能或迁移到另一台机器 | [安装说明](docs/INSTALL.md) |
| 复用全局论文工作约定 | [AGENTS 模板](instructions/AGENTS.template.md) |
| 查看系统与插件依赖 | [外部依赖目录](catalog/DEPENDENCIES.md) |
| 了解整理边界与后续维护 | [整理记录](docs/ORGANIZATION.md) |

## 技能分类

| 分类 | Skill | 用途 |
| --- | --- | --- |
| 技能选型 | [skillrover](skills/skillrover/SKILL.md) | 按任务搜索、核查和选择 Skill，并继续工作 |
| 学术写作 | [nature-writing](skills/nature-writing/SKILL.md) | 研究主线、论文结构与章节起草 |
| 学术写作 | [nature-polishing](skills/nature-polishing/SKILL.md) | 英文润色、中文转写与 LaTeX 排版 |
| 论文工程 | [sync-overleaf-local](skills/sync-overleaf-local/SKILL.md) | Windows / E 盘上的本地 LaTeX、Git 与 Overleaf 同步 |
| 研究阅读 | [research-evidence-auditor](skills/research-evidence-auditor/SKILL.md) | 证据核查、研究比较与引文审核 |
| 研究阅读 | [reading-notes](skills/reading-notes/SKILL.md) | 阅读笔记、研究线索与后续任务 |
| 文档处理 | [pdf-to-markdown](skills/pdf-to-markdown/SKILL.md) | PDF 提取、OCR 与 Markdown 转换 |
| 知识管理 | [notion-knowledge-capture](skills/notion-knowledge-capture/SKILL.md) | Notion 页面、知识记录与决策整理 |
| 创意工具 | [hatch-pet](skills/hatch-pet/SKILL.md) | Codex 动画宠物的生成、组装与检查 |
| 自动化 | [-21risk-automation](skills/-21risk-automation/SKILL.md) | 通过 Rube MCP 使用 21risk |

分类只用于导航；文件继续放在 `skills/<原名称>/`，保留已有相对引用。两个 `nature-*` 技能共同依赖 [`skills/_shared/`](skills/_shared/README.md)。

## 目录

```text
agent-skills/
├── agents/                 # 学术协作角色与 SkillRover
├── instructions/           # 可选全局指令模板
├── skills/                 # 10 个完整技能包及 _shared
├── catalog/                # 个人、系统与插件技能清单
├── docs/                   # 安装和维护说明
├── scripts/                # 安装与发布前检查
└── .github/workflows/      # 自动检查
```

## 开始使用

使用 Python 3.9+，先列出技能并预览安装计划：

```powershell
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/validate.py
python scripts/install.py --list
python scripts/install.py --target "$env:USERPROFILE\.codex\skills" --dry-run
```

确认计划后去掉 `--dry-run`。已有同名目录会阻止写入；本次整理没有覆盖原有安装。`sync-overleaf-local` 有独立的 E 盘路径要求，按 [安装说明](docs/INSTALL.md) 单独配置。

Agent 文件是可供助手或子代理读取的角色提示词；此库不附带自动运行多 Agent 的执行器。每个技能的 `agents/openai.yaml` 是其展示和调用配置，随技能保留。

## 来源与使用条件

保留已有许可证和作者信息，详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。系统和插件只记录依赖信息；连接器、账号授权和运行环境需要在目标机器配置。公开版本的论文示例采用结构说明与来源链接，实际稿件和实验数据不在仓库内。

技能结构背景可参考 [OpenAI 官方技能文档](https://learn.chatgpt.com/docs/build-skills)。
