# Skill Adapter 分享文案

下列文案已随源码公开，可直接分享。尚未代发到站外平台。

## 中文

做了一个 Skill Adapter，用来修整已有的 Agent Skill。它会核对 OpenAI 的 Skill 文档，检查当前环境的工具是否够用，再根据实际失败记录修改流程。

我关心的是改完以后有没有把原任务改丢：缺少求解器就明确标注未求解；改描述就保留已有依赖和调用设置；修一个案例，也检查相近任务。

附带只读结构检查脚本、中英文说明和合成案例。独立项目，没有官方认证，也还没有通用成功率数据。欢迎带着具体失败案例来试。

[源码与安装](https://github.com/walterkken/agent-skills/tree/main/agents/skill-adapter)

## English

I built Skill Adapter to update existing agent skills against current OpenAI guidance, available tools, and concrete task failures.

The focus is preserving the original job: a missing solver stays an explicit blocker; a metadata edit keeps unrelated policy and dependencies; a behavioral fix gets checked against a nearby case.

Includes a read-only Python structure audit, bilingual docs, and synthetic evaluation cases. Independent project, no official certification or measured general success-rate claim. Reproducible failure reports are welcome.

[Source and installation](https://github.com/walterkken/agent-skills/tree/main/agents/skill-adapter)
