# 来源与许可证

这是个人安装集合的整理副本，不表示所有内容均由仓库维护者原创。保留原文件中的作者、来源和许可证；没有为整个集合赋予统一开源许可证。

| 内容 | 本地来源证据 | 处理方式 |
| --- | --- | --- |
| `personalized-learning-tutor` 与 `agents/personalized-learning-tutor/` | 本仓库新增的个性化教学 Skill 与 Agent，维护者 walterkken | 新增内容按 `skills/personalized-learning-tutor/LICENSE` 的 MIT 条款使用；不改变其他组件许可 |
| `skillrover` 与 `agents/skillrover/` | 本仓库新增的 Skill 搜索与选择 Agent，维护者 walterkken | 新增内容按 `skills/skillrover/LICENSE` 的 MIT 条款使用；不改变其他组件许可 |
| `hatch-pet` | 包内 `LICENSE.txt` 为 Apache-2.0；未核实独立上游地址 | 保留许可证与技能包 |
| `notion-knowledge-capture` | 包内 `LICENSE.txt` 为 MIT，Notion Labs | 保留许可证；插件同名版本单列依赖 |
| `pdf-to-markdown` | README 指向 [paulmaunders/claude-skill-pdf-to-markdown](https://github.com/paulmaunders/claude-skill-pdf-to-markdown)，包内 AGPL-3.0 | 保留许可证与源码；将个人 uv 路径改为环境变量示例 |
| `reading-notes` | `metadata.json` 标明 JP Caparas；本地未附独立 LICENSE | 保留作者元数据，不推定额外许可 |
| `-21risk-automation` | 技能指向 [Composio 21risk 工具目录](https://composio.dev/toolkits/_21risk)；未附独立 LICENSE | 保留现有说明与依赖，不推定额外许可 |
| `nature-writing`、`nature-polishing`、`_shared` | 本地定制的学术指导；内含论文来源、Academic Phrasebank 和 Peng Sida 写作资料链接 | 保留来源；公开示例采用结构分析与填写骨架 |
| `research-evidence-auditor`、`sync-overleaf-local` | 本地定制技能，未附独立 LICENSE | 保留内容及工作约定，不赋予新许可证 |
| Agent 角色与全局指令模板 | 从本地已有配置整理 | 移除具体论文身份和实际实验任务，保留角色与流程 |
| 系统与插件技能 | 本机系统目录和插件 manifest | 仅记录名称、版本和来源，不复制系统或插件实现 |

`skills/pdf-to-markdown/test-files/*.pdf` 是上游生成脚本配套的合成测试文档，不是个人研究论文。

公开仓库的可见性不替代各组件的许可证。需要再分发未附许可证的组件时，应先确认其上游条件。
