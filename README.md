# Codex Research Skill Bundles

这是一套声明式、可重复部署的 Codex 科研环境定义。它保存来源、Skill/Plugin 名称、安装/更新/验证命令与非敏感说明，不是 `~/.codex` 的镜像。

- **Research-Writing** = Research Planning + Literature + Analysis + Paper Production
- **Research-Engineering** = Scientific Computing + Algorithm Development + Validation + Performance

两套环境不追求完全一致，也不自动同步设备状态。代码、实验结果、数据说明、figure 与 paper 等项目成果应进入各自的 Git 仓库；不要同步 `~/.codex`、插件缓存或认证文件。

## 安全边界

本 Bundle 不包含、也不会打包 OAuth、token、`auth.json`、session、credentials、cache、logs、history、account information、GitHub token 或任何 Codex authentication data。脚本不会删除 Skill，不会复制整个 `~/.codex`，不会修改认证信息，也不会自动安装 Python optional dependencies。

脚本只可能写入以下受控位置：

- Nature 源码：`~/ai-skills/nature-skills`
- Research-Writing 的 Codex Skills：当前项目的 `.agents/skills`，由 Nature 官方同步脚本或 `gh skill install --scope project --agent codex` 管理
- Research-Engineering 的 K-Dense Skills：当前项目的 `.agents/skills`，由 `gh skill install --scope project --agent codex` 管理
- 两套 Bundle 均可用 `CODEX_SKILLS_DIR` 覆盖 Skill 安装、更新和验证位置，或用 `CODEX_PROJECT_ROOT` 覆盖项目根目录
- ARS：由 Codex Plugin Marketplace 命令管理

## 推荐调用边界

| 层级 | 首选职责 | 不应承担的默认职责 |
|---|---|---|
| ARS | workflow / research orchestration；跨阶段规划、检查点、研究到论文流水线 | 代替每个专用产物 Skill 的细粒度实现 |
| Nature | academic deliverables；文献、论文、引用、审稿、回复、proposal、图表与 PPT | 通用数值库/API 的底层实现指导 |
| K-Dense | scientific methods / numerical tools；数学、统计、单位、不确定度、计算与库级方法 | 端到端论文生产流程总控 |
| Project-specific `AGENTS.md` / Skills | 项目工程规则；语言、构建、测试、benchmark、CI、目录与交付约束 | 跨项目全局偏好或账号配置 |

当功能重叠时，不删除任何 Skill，采用以下优先级：**ARS 定流程 → Nature 产学术成品 → K-Dense 完成数值、统计与方法实现 → 项目规则约束工程落地**。

## Bundle 对照

| 能力/组件 | Research-Writing | Research-Engineering |
|---|---:|---:|
| ARS-Codex | 默认安装 | 可选 `--with-ars` |
| Nature Skills | 全部 20 个（含 `nature-shared`） | 默认不安装 |
| MATLAB / SymPy | 默认 | 默认 |
| Statistical analysis / uncertainty | 默认 | 默认 |
| Scientific critical thinking / visualization | 默认 | 默认 |
| Experimental design | 默认 | 不包含 |
| GPU / multi-objective optimization / ML / DL / statsmodels | 不默认 | 推荐扩展 `--with-extensions` |
| 论文写作、引用、审稿、response、PPT | 默认 | 不默认 |

`experimental-design` 经内容审阅后只放入 Writing：其主体是数据采集前的随机化、区组、重复、传统 DOE、交叉/重复测量与试验单位设计。它确实包含 response surface、Latin hypercube 与计算机模型采样，但不是以 benchmark、ablation、regression/CI validation 为主体。

## 明显重叠与推荐优先级

| 重叠区域 | 涉及 Skill | 推荐选择 |
|---|---|---|
| 文献综述/深度研究 | ARS `deep-research`、`nature-academic-search`、`nature-literature-pipeline`、`nature-reader`、`nature-paper-card` | ARS 负责问题收敛与阶段编排；Nature 负责检索、全文阅读、卡片和持续管线 |
| 论文写作/润色 | ARS `academic-paper`、`nature-writing`、`nature-polishing`、`nature-proposal-writer` | ARS 负责跨章节路线与检查点；Nature 负责具体稿件/段落/Proposal 产物 |
| Reviewer / Rebuttal | ARS reviewer/revision、`nature-reviewer`、`nature-response` | ARS 负责全流程与证据门；Nature 负责独立审稿报告和逐点回复包 |
| 引用与完整性 | ARS citation gate、`nature-citation`、`nature-ref-verifier`、`nature-academic-search` | ARS 负责流程门控；Nature 负责搜引、逐条核验和引用文件 |
| 统计 | `nature-statistics`、K-Dense `statistical-analysis` | K-Dense 负责选检验、假设、效应量与计算；Nature 负责期刊稿件统计审计和表述 |
| 科研绘图 | `nature-figure`、K-Dense `scientific-visualization` | K-Dense 负责可信可视化原则与通用实现；Nature 负责投稿级多面板、导出与期刊 QA |
| 实验/研究设计 | ARS experiment planning、K-Dense `experimental-design`、`scientific-critical-thinking` | ARS 负责任务编排；`experimental-design` 负责设计矩阵；critical thinking 负责证据/偏倚审计 |
| 数学与误差 | `matlab`、`sympy`、`uncertainty-and-units` | 直接优先 K-Dense；Nature 仅在学术产物呈现阶段接手 |

## 审阅快照（2026-08-30）

- `~/.codex/skills`：历史审阅时的 27 个用户级 Skill；当前两个 Bundle 默认改为项目级 `.agents/skills`，不计入此快照。
- Nature：`~/ai-skills/nature-skills` 位于 `main`，工作树干净；官方 `--check` 对 20 个 Skill 全部返回 `MATCH`，源码 commit 为 `bd4e415c1dcaf6df4ca701f8f8492a97e4b49921`。
- K-Dense：当前 7 个已安装 Skill 的元数据均指向 `K-Dense-AI/scientific-agent-skills`、tag `v2.65.0`。Engineering 建议扩展 `optimize-for-gpu`、`pymoo`、`scikit-learn`、`pytorch-lightning`、`statsmodels` 均在上游 `skills/<slug>/SKILL.md` 中存在。
- GitHub CLI：`gh 2.98.0` 提供 preview 状态的 `gh skill`；当前机器的 `gh auth status` 失败。脚本会在任何安装/更新写入前停止并提示用户自行运行 `gh auth login`。
- ARS：本机安装 `ars-codex@ars-codex` 0.1.27；Marketplace 源为 `Imbad0202/academic-research-skills-codex`。上游当前 README 与本机 Codex CLI 均支持声明式安装命令。

## 版本与更新策略

- Nature 跟踪仓库 `main`，更新使用 `git pull --ff-only` 与仓库自带同步脚本；manifest 显式记录审阅时的完整 Skill 清单。若上游新增/删除顶层 Skill，`verify.sh` 会提示更新 manifest。
- K-Dense 使用 `gh skill install` 的上游版本解析与来源跟踪元数据。安装不使用 `--force`，不会覆盖来源不明的同名目录；更新只点名 manifest 中的 Skill。
- ARS 跟踪官方 Marketplace `main`；更新只 refresh `ars-codex` Marketplace，再按官方流程重新 add 该插件。

## 快速使用

```bash
cd research-writing
./verify.sh
./install.sh
./update.sh
```

```bash
cd research-engineering
./verify.sh
./install.sh
./install.sh --with-extensions
./install.sh --with-extensions --with-ars
```

先运行 `verify.sh` 可只读检查当前状态。`install.sh`/`update.sh` 才会写入受管组件。安装后应打开新的 Codex 对话，让新 Skill/Plugin 被重新发现。

## K-Dense 的非默认 fallback

首选 `gh skill`。如果当前 `gh` 版本不提供该命令，可手工使用 `npx skills`，但 Bundle 脚本不会自动执行 fallback：

```bash
npx skills add K-Dense-AI/scientific-agent-skills --skill <slug> --global --agent codex --yes
```

`npx skills` 可能使用 `~/.agents/skills` 的全局 canonical store/symlink 机制；使用前应通过 `npx skills list --global --agent codex` 检查实际落点。Bundle 脚本默认使用当前项目的 `.agents/skills`；如需保持自定义目录语义，可通过 `CODEX_SKILLS_DIR` 显式指定。

## 清理策略

本阶段不建议从当前 MacBook 删除任何 Skill：历史 Writing Bundle 的目标集合与现有 27 个用户级 Skill 完全一致，且 ARS/Nature/K-Dense 之间虽有功能重叠，但职责层次不同。若未来需要清理旧的用户级副本，仍建议先保存验证记录并观察一段时间；任何清理都应作为单独、显式确认的阶段执行。
