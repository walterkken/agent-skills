# Skill Adapter · 技能适配器

让已有 Skill 适应规范、环境和实际使用中的问题。

你下载的 Skill 可能依赖不存在的工具，也可能触发太宽、流程过时，或者因为一次失败越改越长。Skill Adapter 先找出问题，再修改对应部分，保留原任务目标，并检查改动有没有造成退步。

[English](README.en.md) · [Skill 源码](../../skills/skill-adapter/SKILL.md) · [检查记录](VALIDATION.md) · [分享文案](SHARE.md)

## 直接使用

在支持 Skills 的助手中选择 Skill Adapter，输入：

```text
用 skill-adapter 检查并适配这个 Skill。
按当前 OpenAI 官方说明核对格式，再检查它在我的工具环境中能否完成任务。
保留原有目标，说明改了什么、为什么改、哪些检查已经完成。
```

支持命名调用的 Codex 环境也可以使用 `$skill-adapter`。

## 三类适配

| 发现的问题 | 处理方式 |
| --- | --- |
| 元数据缺失、触发描述不清 | 对照当前官方说明修改，并保留有效的可选配置 |
| 工具、系统或路径不同 | 调整可迁移部分，明确无法运行的环节 |
| 某类任务反复失败 | 根据实际输入和结果定位原因，做小范围修改并检查相近任务 |

例如，一个 Skill 要求运行 Abaqus，但当前环境没有 Abaqus：它可以保留 INP 文件生成，说明求解和 ODB 结果提取尚未执行。它不会凭空生成“求解通过”的位移数据，也不会把交付目标悄悄改成一段介绍。

“自适应”由助手在这次任务中执行。这个包没有后台常驻程序，不会自动监视历史对话，也不会在正常使用其他 Skill 时偷偷改写它们。

## 官方依据与边界

参考 [OpenAI 的 Build skills 文档](https://learn.chatgpt.com/docs/build-skills)，来源基线核对于 2026-09-11。适配时重新核对当前文档；无法联网时会注明日期和未核实项。

这是独立项目，没有 OpenAI 官方认证。格式检查通过不等于任务表现更好，也不等于所有平台都能运行。

## 安装到本地 Codex

```bash
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills skill-adapter --target "$HOME/.agents/skills" --dry-run
python scripts/install.py --skills skill-adapter --target "$HOME/.agents/skills"
```

同名目录存在时安装器会停止。其他宿主请使用其支持的 Skills 安装入口；此 GitHub 目录不是插件商店上架记录。

## 单独运行结构检查

检查脚本需要 Python 3.9+ 和 PyYAML；它只读文件，不联网、不执行目标 Skill 的代码、不自动修复。

```bash
python -m pip install PyYAML
python skills/skill-adapter/scripts/audit_skill.py /path/to/target-skill
```

输出 JSON。退出码 `0` 表示已实现的局部检查未发现错误，`1` 表示发现结构问题，`2` 表示参数或依赖不可用。输出同时列出尚未检查的项目。资源链接、行为和工具能力需要助手进一步核查。

## 反馈

遇到适配错误时，请在本仓库提交 Issue，提供删去敏感信息的最小 Skill、目标环境、预期行为和实际结果。不要上传密钥或私人聊天。欢迎提交可复现案例和小范围修复。

本组件及本目录文档使用 [MIT](../../skills/skill-adapter/LICENSE) 许可证。
