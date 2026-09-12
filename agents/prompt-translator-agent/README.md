# Prompt Translator Agent · 提示词翻译官

**把日常表达转成简洁、可执行的专业指令。**

“再自然一点”“简洁大气”“其他不变”容易让助手理解偏。提示词翻译官将这些话落实为操作、修改范围和验收条件，适用于修图、PPT、写作、代码等任务。

[Skill 源码](../../skills/prompt-translator-agent/SKILL.md) · [English](#english) · [MIT](../../skills/prompt-translator-agent/LICENSE)

## 怎么用

```text
用提示词翻译官：把蓝色曲线和上面的 u 去掉，其他不变。
```

通常只给两行：

> **专业说法：** 局部移除、背景修复。
> **可执行指令：** 只移除蓝色曲线及其对应的 u，恢复遮挡处的背景；保留坐标轴、其他曲线、标注及画幅。

只想要提示词，加“只给一句指令”；想直接完成，加“翻译后直接做”。在支持命名调用的环境中，也可以使用 `$prompt-translator-agent`。

## 它会帮你明确什么

| 日常表达 | 结合上下文转为 |
| --- | --- |
| 合成人像再自然一点 | 光照、色温与颗粒匹配，修正边缘接缝，保留身份与表情 |
| PPT 简洁大气 | 对齐、字号层级与间距，减少冗余装饰，保留信息关系 |
| 这段论文写专业点 | 术语统一、论证收紧，保留事实、数据和结论强度 |
| 程序快一点，结果别变 | 定位耗时瓶颈，保持输出与错误行为，用同一负载比较 |

术语要能指导操作。它不会把“美白 50%”擅自当成某个软件的固定滑杆值，也不会把“自然”一律解释成磨皮。缺少会改变结果的关键信息时，只问一个短问题；已经说清楚的任务，无须额外读一段翻译。

收到执行要求后，它会继续完成任务，并检查实际结果；仅要求提示词时，就只给提示词。提示词能减少表达歧义，工具的能力和输出质量仍需实际检查。

## 安装

在本地使用本仓库安装器，先查看计划，再安装：

```bash
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills prompt-translator-agent --target "$HOME/.codex/skills" --dry-run
python scripts/install.py --skills prompt-translator-agent --target "$HOME/.codex/skills"
```

同名目录已存在时，安装器会停止。ChatGPT 用户可通过所在环境支持的 Skills 安装入口导入 [技能目录](../../skills/prompt-translator-agent)，或让具备安装能力的助手安装此目录。这里提供的是可安装 Skill 和 Agent 指令；不包含后台常驻程序。

## English

**Prompt Translator Agent turns everyday requests into concise professional instructions.**

Use it for vague edit requests, prompt refinement, or corrections after an assistant misses your intent. It identifies the target, operation, preservation constraints, and observable success condition. Output is normally two short lines: useful terminology and a ready-to-use instruction.

Example: “Make this composite portrait look more natural” becomes “Match the face to the scene's lighting direction, color temperature, and grain; blend visible seams while preserving identity, expression, pose, and composition.”

Ask “just the prompt” to get one instruction. Ask it to execute as well to continue the actual task. Material ambiguity gets one short question; low-impact assumptions are conservative. It does not invent editing percentages, research results, or tool capabilities.

Install the `skills/prompt-translator-agent` directory using the commands above or your host's supported Skills installation flow. The canonical agent instructions live in [SKILL.md](../../skills/prompt-translator-agent/SKILL.md); this page is the usage guide.

Search terms: prompt translator, prompt refinement, prompt engineering, natural language to professional instructions, image editing prompts, AI agent, Codex skill, 提示词翻译, 需求翻译, 专业术语。
