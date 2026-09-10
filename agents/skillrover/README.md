# SkillRover · 寻技

**找到合适的 Skill，接着把活做完。**

[English](README.en.md) · [技能源码](../../skills/skillrover/SKILL.md) · [Agent 入口](SYSTEM_PROMPT.md)

手头有个任务，现成的 Skill 一搜一大把。名字都差不多，装完才发现缺依赖，或者根本解决不了眼前的问题。

SkillRover 负责这一段选择工作：看清任务，检查已有技能，必要时搜索别人的实现，读过源码后再决定用哪个。选好以后，继续原任务。

## 怎么用

安装后，可以直接说：

> 用寻技帮我处理这份长 PDF。先找合适的 Skill，说明为什么选它，再继续转换。

也可以只让它选：

> 用 SkillRover 比较这三个 Skill，只给推荐，先别安装。

它随任务运行，搜索、文件访问和执行能力由所在的助手提供。支持技能自动选择的宿主可在选型或能力不足时调用它；更确定的入口是显式使用 `$skillrover`。这是一个可安装的 Agent Skill，包内没有常驻服务或独立模型。

## 它怎么选

| 看什么 | 实际要弄清的问题 |
| --- | --- |
| 任务是否匹配 | 能不能交出这次要的结果？ |
| 当前能否运行 | 缺什么依赖、账号或工具？ |
| 实现是否可信 | 是否读过真正的 `SKILL.md` 和相关脚本？ |
| 使用限制 | 是否需要外发文件，许可证是否允许预期用途？ |
| 引入成本 | 比已有办法多了什么，又解决了什么？ |

它会区分“说明里写了”“实现里有”“实际跑过”。缺少证据就保留未知。星标数可以帮忙发现项目，不能替代这些判断。

通常选一个主要 Skill。另一个确实能补上缺口时再加；现有工具已经够用，也可以直接用现有工具。只要求推荐时，工作到推荐为止。

## 一个例子

任务：把一份很长的中文扫描 PDF 转成可逐页出题的资料，文件不能外发。

SkillRover 会先查本地 PDF 能力，再搜索支持中文 OCR、分批处理和页码保留的实现。需要把文件上传到网站的方案不符合这个任务；只支持提取现有文字的方案还缺 OCR。对可用方案，会检查脚本是否真的逐页处理，并保留尚未测试的规模限制。

这个例子说明判断过程，不代表已经完成过该文件的转换或性能测试。

## 安装

已有 [Skills CLI](https://github.com/vercel-labs/skills) 使用环境时，可以安装这个单独的 Skill：

```sh
npx skills add walterkken/agent-skills --skill skillrover
```

也可以使用本仓库的 Python 安装脚本。先克隆仓库，再预览复制目标：

```sh
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills skillrover --target /path/to/your/skills --dry-run
```

把 `/path/to/your/skills` 换成宿主的技能目录，确认目标后去掉 `--dry-run`。脚本会复制完整技能包，遇到同名目录会停止。托管应用应使用它自己的技能导入方式。

如果宿主只接受 Agent 提示词，从 [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) 开始，并让它能读取完整的 `skills/skillrover/` 目录。不要只复制一个入口，漏掉引用文件。

## 在日常工作中启用

如果想在项目遇到选型问题时主动使用它，可以把下面这句加入该项目的工作约定：

> 遇到需要专业流程、多个 Skill 难以取舍，或现有能力不足的任务时，先用 SkillRover 查找并选择合适的 Skill，再继续工作。已有方案够用的常规任务直接处理。

是否自动加载仍由宿主决定。SkillRover 不会自行改写全局指令，也不会因为读到第三方 Skill 的安装命令就执行它。

## 文件与验证

- `skills/skillrover/`：完整技能包，含选择规则、搜索入口和许可证。
- `agents/skillrover/SYSTEM_PROMPT.md`：可供宿主读取的 Agent 入口。
- [验证用例](evals.md)：可以复跑的行为检查，包含只推荐、禁止外发和依赖缺失等情形。

SkillRover 的新增文件使用 [MIT 许可证](../../skills/skillrover/LICENSE)。第三方技能保留各自的许可证；此许可不覆盖仓库中其他组件。
