# 安装与迁移

## 环境

- 仓库检查和安装脚本：Python 3.9+，仅使用标准库。
- 各 Skill 的额外依赖仍以其 `SKILL.md` 为准：例如 PDF 的 `uv`/OCR、Notion 连接器、Rube MCP、图像工具及本地 LaTeX。
- 本库来自 Codex 的个人技能目录；在其他支持 `SKILL.md` 的工具中使用时，须核对对应工具和路径。

## 普通技能

安装器要求显式指定目标目录。默认选择 8 个普通技能，自动带上 Nature 技能的 `_shared`；不自动安装 Windows 专用的 `sync-overleaf-local`。

```powershell
python scripts/install.py --target "$env:USERPROFILE\.codex\skills" --dry-run
python scripts/install.py --target "$env:USERPROFILE\.codex\skills"
```

只安装指定技能：

```powershell
python scripts/install.py --target "$env:USERPROFILE\.codex\skills" --skills nature-writing nature-polishing
python scripts/install.py --target "$env:USERPROFILE\.codex\skills" --skills=-21risk-automation
```

同名目标存在时，在开始复制前停止；不会删除、合并或覆盖已有技能。相同的 `_shared` 可复用。更新已有安装时，先在本机备份，再人工比较并替换需要更新的文件。请勿将备份、凭据或机器配置提交到仓库。

## sync-overleaf-local

这个技能保留原有 Windows / `E:\Overleaf` 工作约定，脚本中的路径没有统一参数化。仅改变一处文档路径不足以迁移到其他盘符。

新安装时，将真实文件放入 `E:\Overleaf\skills`，再让 Codex 个人技能目录引用该位置：

```powershell
python scripts/install.py --target 'E:\Overleaf\skills' --skills sync-overleaf-local --dry-run
python scripts/install.py --target 'E:\Overleaf\skills' --skills sync-overleaf-local
New-Item -ItemType Junction -Path "$env:USERPROFILE\.codex\skills\sync-overleaf-local" -Target 'E:\Overleaf\skills\sync-overleaf-local'
```

这些步骤用于尚未安装的机器。已有真实目录或 junction 时保留现有配置，先比较版本。这个技能只提供文件和脚本；它不会随安装自动连接 Overleaf 或上传论文。

## Agent 与全局指令

从 [`agents/academic/README.md`](../agents/academic/README.md) 填写项目上下文，再把所需角色提示词交给对应助手或子代理。角色文件不依赖特定 Agent 启动器。

[`instructions/AGENTS.template.md`](../instructions/AGENTS.template.md) 是可选模板；使用前与现有全局或项目 `AGENTS.md` 比较，合并适合自己的规则。安装器不会改写全局指令。

## 系统与插件

从 Codex 对应的系统功能、插件市场或连接器入口恢复 [外部依赖目录](../catalog/DEPENDENCIES.md) 中需要的能力。清单记录缓存快照，不能保证插件当前启用、公开可下载或无需授权。`openai-templates` 是官方默认专有模板，没有复制其正文和资产。

个人目录与 Notion 插件都含 `notion-knowledge-capture`。若同时安装，请核对调用名称，避免重复触发；本次整理未更改本机启用状态。
