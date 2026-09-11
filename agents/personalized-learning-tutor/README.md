# Personalized Learning Tutor · 知识翻译师

把新知识讲进学习者已经理解的语言里。

它从可用对话中辨认你熟悉的词汇、经验、概念和推理方式，用这些解释陌生知识，再逐步接上正式术语。遇到理解偏差就调整讲法，而不是把同一段话重复一遍。

[English](README.en.md) · [Skill](../../skills/personalized-learning-tutor/SKILL.md) · [Agent 提示词](SYSTEM_PROMPT.md)

## 怎么用

安装后直接描述你要学的内容，以及已经熟悉的东西：

```text
用 $personalized-learning-tutor 帮我理解导数。我熟悉骑车的路程和用时，
不熟悉微积分。导数是不是总路程除以总时间？不要先考我。
```

它应先指出这算的是平均速率，再用越来越短的时间段解释某一时刻的变化率，最后连接到导数的定义。类比需要说明边界：位置的导数是有方向的速度，累计路程的变化率则是速率。

也可以直接要求正式推导：

```text
我懂电路节点方程。用它帮我理解图的拉普拉斯矩阵，
先对应各个量，再给出数学定义和一个小例子。
```

## 它怎样判断该怎么讲

- 看你实际表达和应用过什么，不把粘贴的论文当成你的知识水平。
- 区分明确偏好、已经展示的理解和暂时猜测；当前要求优先于旧印象。
- 保留概念的条件、因果关系、单位和公式含义，说明类比在哪里失效。
- 需要时用一个相近问题检查能否应用；你不想被提问，就给出完整示例。
- 随着理解加深，减少对类比的依赖，回到学科本身的语言。

这里的“语言系统”指词汇、概念和表达习惯，不是人格分类。Skill 只使用当前可见或经过授权且能访问的上下文；不会自动获得所有历史聊天，也不默认保存个人画像。

## 安装

在仓库根目录运行，替换目标路径：

```bash
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills personalized-learning-tutor --target /path/to/your/skills --dry-run
python scripts/install.py --skills personalized-learning-tutor --target /path/to/your/skills
```

目标应是你的助手所使用的 Skills 目录。同名目录已经存在时，安装器会停止。也可以让支持读取文件的 Agent 加载 [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md)，并保留其中引用的 Skill 文件。

这是教学行为说明，需要支持 Skill 或文件提示词的助手执行；仓库没有独立聊天服务，也没有自动收集历史输入的程序。

## 检查与许可

[示例与验收标准](../../skills/personalized-learning-tutor/references/examples.md)覆盖概念误解、引用材料、偏好变化和不提问等情况。这些是合成案例和检查标准，不是学习效果实验。

本组件及本目录文档使用 [MIT](../../skills/personalized-learning-tutor/LICENSE) 许可证。
