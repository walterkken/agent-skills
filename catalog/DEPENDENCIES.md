# 外部依赖目录

这里只保存系统和插件技能的名称、版本、来源。不会把系统实现、插件缓存或授权配置复制进仓库。

## 系统技能

共 6 个，来自当前 Codex 系统技能目录。

| 名称 | 安装方式 |
| --- | --- |
| `imagegen` | 由 Codex 管理 |
| `openai-docs` | 由 Codex 管理 |
| `plugin-creator` | 由 Codex 管理 |
| `review-agent` | 由 Codex 管理 |
| `skill-creator` | 由 Codex 管理 |
| `skill-installer` | 由 Codex 管理 |

完整元数据：[system-skills.json](system-skills.json)。

## 插件缓存快照

共 19 个插件，包含 50 份技能定义。缓存存在不能证明当前启用。

| 插件 | 版本 | 技能 |
| --- | --- | --- |
| Browser | `26.901.22334` | 无 Skill 文件（工具插件） |
| codex-app-tools | `0.1.3` | 无 Skill 文件（工具插件） |
| Sites | `0.1.57` | `sites-building`, `sites-hosting` |
| unified-computer-use | `26.901.22334` | 无 Skill 文件（工具插件） |
| Visualize | `1.0.29` | `visualize` |
| Adobe | `8.0.0` | `adobe-batch-edit-photos`, `adobe-create-mockups`, `adobe-create-social-variations`, `adobe-design-from-template`, `adobe-edit-quick-cut`, `adobe-retouch-portraits` |
| Markdown by mdedit.ai | `0.1.1` | `find-mdedit-document`, `publish-mdedit-document`, `revise-mdedit-document`, `save-mdedit-document` |
| Deep Research | `0.1.14` | `deep-research` |
| GitHub | `0.1.12-5f7cd798dc99` | 无 Skill 文件（工具插件） |
| Gmail | `0.1.10` | 无 Skill 文件（工具插件） |
| Google Drive | `0.1.16` | `google-docs`, `google-drive`, `google-drive-comments`, `google-sheets`, `google-slides` |
| Notion | `0.1.8` | `notion-knowledge-capture`, `notion-meeting-intelligence`, `notion-research-documentation`, `notion-spec-to-implementation` |
| Default templates | `0.1.1` | `artifact-template-analytics-dashboard`, `artifact-template-business-review`, `artifact-template-design-report`, `artifact-template-experiment-analysis`, `artifact-template-financial-budget`, `artifact-template-investment-committee-memo`, `artifact-template-legal-memorandum`, `artifact-template-market-trends-report`, `artifact-template-minimal-letterhead`, `artifact-template-operating-calendar`, `artifact-template-operating-review`, `artifact-template-project-kickoff`, `artifact-template-project-tracker`, `artifact-template-sales-pipeline`, `artifact-template-simple-dark-mode`, `artifact-template-simple-light-mode`, `artifact-template-strategy-memorandum`, `artifact-template-system-design`, `artifact-template-team-alignment`, `artifact-template-three-statement-forecast` |
| Plugin Management | `0.1.0` | `plugin-management` |
| Documents | `26.826.12353` | `documents` |
| PDF | `26.826.12353` | `pdf` |
| Presentations | `26.826.12353` | `Presentations` |
| Spreadsheets | `26.826.12353` | `excel-live-control`, `Spreadsheets` |
| Template Creator | `26.826.12353` | `template-creator` |

完整元数据：[plugins.json](plugins.json)。

`openai-templates` 的 20 个技能为官方默认模板，manifest 标记为 Proprietary；仅记录其来源。`notion-knowledge-capture` 在个人目录和 Notion 插件中均存在，按来源保留记录，未更改任何安装状态。

各插件需要通过可用的官方分发渠道恢复；清单中的上游地址来自本机 manifest，未保证所有地址可公开访问。
