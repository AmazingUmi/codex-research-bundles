# `paper2026-ray_reuse` 使用 Research-Writing Bundle 指南

更新日期：2026-08-30  
适用项目：`/Users/luyiyang/Database/paper2026-ray_reuse`  
推荐主模式：`hybrid`（审计已有稿件 + 补齐证据和缺失模块 + 合并后整稿 QA）

## 1. 结论先行

这个项目不应从“继续润色 `main.tex`”开始，而应按下面的顺序推进：

```text
凭据安全与范围冻结
  → 建立 foundation 五文件
  → 将现有主张分成已证实、合理推断、假设、无证据四类
  → 补文献证据与数值验证
  → 先写 Results，再回写 Methods / Discussion / Introduction
  → 最后重写 Abstract、Highlights 和 Conclusion
  → researchwrite paper 挡位四门 QA
  → Nature reviewer 模拟审稿
```

Research-Writing Bundle 不是一个会自动完成整篇论文的单一工具。它是三层能力的组合：

1. ARS-Codex 负责任务编排和阶段检查点；
2. Nature Skills 负责论文、文献、引用、图、审稿等学术成品；
3. K-Dense Skills 负责 MATLAB、统计、单位、不确定度和科学证据审计。

本项目的总控技能应为 `$researchwrite`。它的安装目录虽然叫 `nature-proposal-writer`，显式调用名仍然是 `$researchwrite`。

## 2. 当前项目基线

### 2.1 已有资产

- `main.tex`：Elsevier CAS 单栏英文主稿，已有 Abstract、Introduction、Background、Methodology、Numerical Simulations、Discussion、Conclusion。
- `refer_doc/outline.md`：中文论证主线，适合作为修改文章走向的控制层。
- `refer_doc/outline_notes.md`：已经记录了许多关键边界问题，例如固定射线集合、吸收模型、反射模型、动态射线变量、加速比和失效条件。
- 两份 ray-methods 总结：可作为理论来源索引，但不能自动当作可引用的一手文献。
- `refer_code/`：包含 OOB/Bellhop 相关输入、输出、MATLAB 文件和图片，是当前数值证据的主要来源。
- 当前 LaTeX 日志没有致命错误，仅有空锚点警告；说明主稿目前可编译，但这不等于科学内容已通过验证。

### 2.2 目前最重要的风险

| 风险 | 当前表现 | 处理原则 |
|---|---|---|
| 凭据泄露 | Notion 凭据已明文进入受 Git 跟踪的文件和历史 | 立即轮换；从仓库移除；以后用环境变量、系统凭据存储或已授权 connector |
| 论证与正文不同步 | `outline.md` 与 `main.tex` 的标题、章节 5 命名和若干主张不一致 | 先在 argument map 定稿，再同步两份文件 |
| 结果证据不足 | Numerical Simulations 目前是文字断言，没有正式图、表、误差指标或运行时间表 | 在扩写结论前先完成验证矩阵和可审查产物 |
| 引用不足 | 主稿仅有少量教材/手册级来源，许多事实性主张无直接文献支持 | 先建 evidence table，再定向检索；禁止边写边随意补引 |
| 主张过强 | “verify”“speedup”“measured data”等口径强于当前仓库可见证据 | 未验证前降级为 hypothesis / expected / future validation |
| 模型边界不清 | 水体吸收与海底吸收混用；ray fan、eigenray、Gaussian beam 的边界尚未锁定 | 写入 canon 和术语表；每个公式说明适用条件与单位 |
| 工作树非干净 | 当前存在用户已有的 `scripts/test.py` 删除 | 不回滚、不覆盖；后续每轮先看 `git status` |

特别注意：从当前文件删除已经提交的凭据不能消除 Git 历史中的泄露；必须先轮换凭据。是否改写 Git 历史应作为单独、显式确认的操作。

## 3. 一次性准备

### 3.1 验证 bundle

在 bundle 仓库中运行：

```bash
cd /Users/luyiyang/ai-skills/codex-research-bundles/research-writing
./verify.sh
```

2026-08-30 的实际结果是 53 PASS、1 WARN、0 FAIL。唯一警告为 GitHub CLI 尚未登录：

- 当前已安装 Skills/Plugin 可以直接使用；
- 只有执行 `install.sh` 或 `update.sh` 前才需要 `gh auth login`；
- 平时写论文不需要重复安装或更新。

### 3.2 从论文仓库根目录开始新任务

打开 `/Users/luyiyang/Database/paper2026-ray_reuse` 作为 Codex 工作目录。这样 Codex 才能稳定读取项目级 `AGENTS.md`、执行 LaTeX 检查，并以正确仓库作为 Git 边界。

Codex 会在任务匹配时自动选择 Skill，也可以用 `$skill-name` 显式指定。对关键阶段建议显式指定，以便得到可重复结果。官方说明见 [Skills & Plugins](https://learn.chatgpt.com/docs/skills-and-plugins.md)。

### 3.3 增加项目级 `AGENTS.md`

项目目前没有 `AGENTS.md`。建议在仓库根目录加入下面的长期规则：

```markdown
# Paper project instructions

## Source hierarchy

- `researchwrite/ray-reuse/01_research_canon.md` controls hard facts and forbidden claims.
- `researchwrite/ray-reuse/02_evidence_table.md` controls claim-to-evidence status.
- `refer_doc/outline.md` controls the paper's argument and section order.
- `main.tex` is the submission manuscript and must be synchronized only after the outline and section contract are accepted.

## Evidence rules

- Never turn a hypothesis, expected result, or plausible inference into a reported finding.
- Every quantitative claim must point to a source file, script, table, or figure.
- Do not claim speedup, localization accuracy, measured-data validation, or cross-frequency equivalence without recorded evidence.
- Preserve the conditions: fixed environment geometry, sound-speed representation, boundary handling, receiver definition, and launch-angle set.
- Distinguish ray-fan reuse, eigenray reuse, and Gaussian-beam contribution reuse.

## Writing rules

- Plan scientific logic in Chinese; write the submission manuscript in concise English.
- Keep terminology consistent: ray trajectory, ray geometry, eigenray, ray contribution, absorption, complex reflection coefficient.
- Use conservative wording until the evidence table marks a claim `evidence-backed`.
- Rewrite Abstract, Highlights, and Conclusion only after Results and Discussion are stable.

## Verification

- After editing `main.tex`, run `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
- Report compile errors, undefined references/citations, changed files, remaining scientific risks, and one next action.
- Do not overwrite or delete user files in `refer_code/`.

## Security

- Never commit tokens, API keys, session cookies, or credentials.
- Read private services through an authorized connector or runtime environment variable.
```

项目级说明的作用、发现顺序和覆盖规则见官方 [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md.md)。

## 4. 建议的 researchwrite 工作区

在论文仓库内建立：

```text
researchwrite/ray-reuse/
├── 00_scope.md
├── 01_research_canon.md
├── 02_evidence_table.md
├── 03_argument_map.md
├── 04_section_contracts.md
├── 05_style_guide.md
├── state.json
├── sources/
│   ├── user_materials/
│   ├── literature/
│   └── data/
├── drafts/
│   └── sections/
├── revision_briefs/
├── qa_logs/
└── exports/
```

不要复制 `refer_code/` 里的大文件。可以在 `sources/data/README.md` 中建立“证据索引”，记录原始文件路径、生成方式、频率、参数、代码版本和目标图表。

最小 `state.json`：

```json
{
  "project": "paper2026-ray_reuse",
  "mode": "hybrid",
  "text_type": "research_paper",
  "language": "mixed",
  "target_reader": "underwater-acoustics journal reviewers",
  "current_round": 0,
  "scores": [],
  "technical_debts": [],
  "status": "foundation"
}
```

## 5. Foundation 五文件怎样填写

### 5.1 `00_scope.md`：锁定这一次要交付什么

建议初始内容：

- Mode：`hybrid`
- Text type：English research paper
- Planning language：Chinese
- Submission language：English
- 当前目标：supervisor-facing draft，而不是 final submission
- 本轮范围：建立证据链、完成数值验证设计、重构 Results/Discussion
- 暂不承诺：实测数据验证、定位性能提升、广泛海洋环境泛化
- 目标期刊：未定，必须标为 unresolved；不要只因为使用 CAS 模板就假定具体期刊

### 5.2 `01_research_canon.md`：硬事实、边界和禁用主张

建议先写入这些条目：

**暂可接受的模型事实**

- 在理想几何声学、固定声速场和边界几何下，eikonal / trajectory 方程不显含声学频率。
- 固定发射角和数值策略时，几何轨迹具备跨频率复用的理论基础。
- 吸收和复反射系数可以显式依赖频率。

**必须保持的条件**

- 相同声速表示和插值；
- 相同环境和边界事件处理；
- 相同源/接收器定义；
- 相同发射角集合或明确定义的宽带充分采样集合；
- 相同的 arrival / eigenray 匹配规则。

**在验证前禁止写成结果的主张**

- 方法已获得显著加速；
- 声压、TL、相位或定位精度与逐频计算等价；
- 已通过实测数据验证；
- 适用于任意频段、边界模型或散射环境；
- 所有几何扩展、焦散和 Gaussian-beam 变量天然完全频率无关。

**未决问题**

- 当前公式中的 absorption 究竟是 water-column、seabed，还是两者；
- `C_m(f)` 是否包含频率相关源谱、波束权重和接收器响应；
- 复用对象是 ray fan、retained arrivals 还是 receiver-specific eigenrays；
- 参考频率如何选择；
- 高频需要更密射线时，复用集合如何保证充分性；
- OOB 输出中的 imaginary delay、amplitude、phase 的精确定义和单位。

### 5.3 `02_evidence_table.md`：本项目最关键的文件

建议用下面的种子表开始：

| Claim | 当前证据 | 初始状态 | 风险/下一步 |
|---|---|---|---|
| 固定环境下轨迹方程不显含频率 | eikonal/ray ODE + 教材 | evidence-backed（限定于模型层） | 增加正式引用并写明高频近似边界 |
| 100 Hz 与 1000 Hz 的 OOB 轨迹输出一致 | `refer_code/` 中的 ray/json 数据 | plausible-inference | 写可复现比较脚本，报告最大位置差和容差 |
| imaginary delay、幅度、相位随频率变化 | OOB 输出和现有图片 | plausible-inference | 给出逐射线/统计表和变量定义 |
| 只更新吸收与反射即可重建目标频率声场 | 当前推导 | hypothesis | 与逐频完整计算比较复声压、TL 和相位 |
| 复用方法明显更快 | 复杂度公式 | unsupported as result | 实测 wall-clock、重复次数、硬件、均值/区间 |
| 方法保持 MFP 定位精度 | 无 | unsupported | 做定位输出或从本文删除 |
| 方法已由实测数据验证 | 无 | unsupported | 从 Highlights 删除，或补实测实验 |
| 相同频率范围可使用同一 ray set | 理论条件说明 | hypothesis / conditional | 做发射角密度和参考频率敏感性分析 |

任何新主张进入正文前，必须先加入此表。状态只允许：

- `evidence-backed`
- `plausible-inference`
- `hypothesis`
- `unsupported`

### 5.4 `03_argument_map.md`：先锁论证，再锁章节

建议核心结构：

- Known：宽带声场需要多个频点；逐频射线求解会重复几何搜索。
- Tension：几何方程本身不显含频率，但实际 beam/eigenray 数值集合、吸收、反射和相位具有频率相关性。
- Research question：在什么明确条件下，参考射线集合可以跨频率复用，同时保持可量化的声场误差并降低计算成本？
- Central thesis：在固定环境、数值采样和 arrival 定义下，可以将几何追踪与频率相关贡献更新解耦；有效性必须由轨迹一致性、复声场误差和运行时间三类证据共同证明。
- Argument A：理论分解说明哪些量可复用、哪些量必须逐频更新。
- Argument B：OOB 数据证明存储几何量在指定频率和固定采样下保持一致。
- Argument C：与逐频完整求解的对照证明声压/TL/相位误差受控。
- Argument D：benchmark 证明在指定问题规模下减少计算时间。
- Counterarguments：频率相关采样、边界散射、焦散/影区、弱界面、接收器插值、ray-set mismatch。
- Final move：把方法定位为“有明确条件和误差边界的工程加速框架”，而不是无限制的物理等价声明。

### 5.5 `04_section_contracts.md`：防止边写边漂移

| Section | Purpose | Allowed claims | Forbidden claims until evidence exists |
|---|---|---|---|
| Introduction | 提出重复计算问题和研究问题 | 文献支持的应用需求、本文问题与贡献 | 已实现的 speedup、定位提升、普适性 |
| Background | 推导几何/贡献分解和适用边界 | eikonal、trajectory、absorption/reflection 依赖 | 把理想模型结论外推为所有数值实现结论 |
| Methodology | 定义存储量、更新量和算法 | 可复现算法、输入输出、复杂度 | 未定义的 `C_m(f)` 或混用吸收类型 |
| Validation / Results | 报告对照、误差、时间和敏感性 | 由脚本和图表直接支持的结果 | 只有文字没有数字的“验证成功” |
| Discussion | 解释收益、误差来源和失效场景 | 条件化解释和局限 | 重复 Results，或新增无证据结论 |
| Abstract/Highlights | 压缩最终证据链 | Results 中已经成立的结论 | future work、未完成实验或未经验证的优势 |

### 5.6 `05_style_guide.md`

建议：

- English，scientific-question-driven，整体保守；
- 首次出现定义 BARR、OOB、MFP、eigenray；
- Bellhop/BELLHOP 的拼写选一种并保持一致；
- 不用 `significant`、`robust`、`accurate`、`efficient`，除非紧跟指标或统计依据；
- 用 `under the fixed ... conditions` 明示边界；
- 区分 `shows`、`supports`、`is consistent with`、`suggests`；
- 引用使用当前 CAS/natbib author-year 风格。

## 6. 推荐的六阶段工作流

### 阶段 0：安全和范围冻结

目标：不改科学内容，先处理凭据和范围。

完成标准：

- Notion 凭据已轮换，仓库当前版本不再保存明文凭据；
- 记录 Git 历史仍含旧凭据这一事实；
- `00_scope.md` 完成；
- 保留当前 `scripts/test.py` 删除状态，不擅自恢复。

推荐提示词：

```text
请在 /Users/luyiyang/Database/paper2026-ray_reuse 中使用 $researchwrite，模式 hybrid。
本轮只做安全与范围审计，不修改 main.tex，不改写 Git 历史，不回滚现有删除。
建立 00_scope.md，列出仓库中的敏感信息、工作树状态、当前交付边界和需要我确认的高风险操作。
结束时报告文件路径、状态、剩余风险和一个下一步。
```

### 阶段 1：建立 foundation 并审计现稿

目标：把 `main.tex` 和 `outline.md` 中的每个关键主张放进 canon/evidence/argument/contract。

推荐提示词：

```text
请使用 $researchwrite 对本项目执行 hybrid foundation 初始化。
读取 main.tex、refer_doc/outline.md、outline_notes.md、两份 ray_methods 总结和 refer_code 的文件清单。
建立 01_research_canon.md、02_evidence_table.md、03_argument_map.md、04_section_contracts.md、05_style_guide.md 和 state.json。
不要向正文补写新事实；把所有结果性主张标成 evidence-backed、plausible-inference、hypothesis 或 unsupported。
特别审计 ray fan/eigenray、water-column/seabed absorption、OOB/BELLHOP、speedup 和 measured-data validation 的边界。
```

Foundation 评分需高于 7.5 才开始正式改稿。

### 阶段 2：定向文献检索与证据补齐

目标：不是搜“声线复用”这个宽泛主题，而是逐 claim 补证据。

建议检索簇：

1. ray/eikonal 方程与频率独立性的严格条件；
2. BELLHOP / Gaussian beam / dynamic ray tracing 的频率与采样依赖；
3. broadband underwater acoustic field modeling 和 MFP 计算成本；
4. eigenray/arrival reuse、interpolation、surrogate 或 broadband acceleration 的既有方法；
5. water absorption 与 seabed complex reflection coefficient 的频率模型；
6. 可比方法的误差和 benchmark 指标。

推荐组合：

- `$ars-codex:academic-research-suite`：需要把“检索→精读→证据表→写作”作为跨阶段流程时；
- `$nature-academic-search`：多源检索、去重、引用核验和 BibTeX 管理；
- `$nature-paper-card`：对关键论文做单篇深读和 claim-evidence 链；
- `$nature-reader`：需要全文中英对照和公式/图表定位时；
- `$nature-ref-verifier`：引用进入主稿前逐字段核验。

推荐提示词：

```text
请使用 $nature-academic-search，读取 researchwrite/ray-reuse/02_evidence_table.md。
只检索状态为 unsupported 或 hypothesis 且可由文献解决的 claim。
将“理论支持”“既有方法/创新性”“模型参数来源”分开，不要用综述替代关键方法的一手来源。
输出检索式、纳入/排除标准、去重后的文献表、每篇文献支持或限制的 claim、BibTeX，以及仍未解决的证据缺口。
不要直接改 main.tex。
```

### 阶段 3：数值验证与统计设计

目标：把当前文字性的“验证”变成可复现的证据包。

最低验证矩阵：

| 问题 | Baseline | Reuse | 指标 |
|---|---|---|---|
| 轨迹是否一致 | 每频完整追踪 | 参考轨迹 | 最大/均方位置差、反射点差、到达时延差 |
| 复声场是否一致 | 每频完整声场 | 复用后重建 | complex relative error、TL RMSE/最大误差、相位误差 |
| ray set 是否稳定 | 各频 eigenray/arrival 集合 | 固定集合 | arrival 数、匹配率、漏失/新增 arrival |
| 是否加速 | 逐频完整运行 | 一次追踪 + K 次修正 | wall-clock、CPU 时间、speedup、内存 |
| 是否依赖采样 | 多种 launch-angle 密度 | 相同方案 | 误差-成本曲线 |
| 是否依赖参考频率 | 多个 `f_0` | 相同目标频带 | 最坏误差、稳定性 |

运行时间至少记录：硬件、软件/代码版本、预热策略、重复次数、均值和离散性。若样本量很少，不要滥用显著性检验，优先报告原始重复、效应量和区间。

推荐组合：

- `$matlab`：审查和扩展现有 `.m` 数据读取/比较流程；
- `$uncertainty-and-units`：核对 dB/m、Np/m、Hz/kHz、travel-time 虚部等单位；
- `$statistical-analysis`：设计 benchmark 重复和报告效应量；
- `$scientific-critical-thinking`：审查“频率无关”推断中的混杂和反例；
- `$nature-figure`：结果稳定后制作投稿级图；
- `$scientific-visualization`：先设计诚实的误差/不确定度表达。

推荐提示词：

```text
请使用 $scientific-critical-thinking 审计 ray reuse 的验证设计。
输入为 02_evidence_table.md、03_argument_map.md、refer_code 文件清单和 main.tex 当前结果性主张。
识别物理假设、数值采样混杂、arrival matching 风险、可能反例和最小充分对照。
输出一份 validation protocol；不要把预期结果写成发现，不修改 main.tex。
```

### 阶段 4：按“结果优先”写作

建议顺序：

1. Results / Numerical Validation；
2. Methodology；
3. Discussion and Limitations；
4. Introduction；
5. Conclusion；
6. Abstract、Highlights、Title。

每次只处理一个 section contract。新 claim 先进入 evidence table，再进入正文。

推荐组合：

- `$nature-writing`：基于已批准的 claim/evidence/contract 起草或重构一节；
- `$nature-polishing`：科学内容稳定后压缩和润色英文；
- `$nature-citation`：仅在需要限定来源家族时使用；一般文献不要强行限定 Nature/CNS；
- `$nature-statistics`：审计 Results、Methods 和图注中的统计表述。

推荐提示词：

```text
请使用 $nature-writing 重写 Numerical Simulations and Validation。
只允许使用 01_research_canon.md 中的硬事实和 02_evidence_table.md 中 evidence-backed 的结果。
遵守 04_section_contracts.md；所有数值必须指向生成文件、图或表。
缺失证据用 [EVIDENCE NEEDED: ...] 标记，不得猜测。
先把草稿写入 researchwrite/ray-reuse/drafts/sections/results_v1.md，不要直接改 main.tex。
```

当该节达到 section score > 6.5 并经人工确认后，再同步到 `main.tex`。

### 阶段 5：整稿四门 QA

使用 `$researchwrite` 的 `paper` 挡位，顺序必须是：

1. 内容专家审查：方法论专家 + 水声/射线领域专家；
2. 英文 anti-slop / 模板化语言检查；
3. 自动验证：claim-citation、方法可复现、术语、公式、图表、交叉引用；
4. 8 维评分：问题、张力、证据、逻辑、方法、创新、风险、语言。

推荐提示词：

```text
请使用 $researchwrite 对 main.tex 运行完整 QA，paper 挡位。
按 Gate 2 内容专家 → Gate 1 英文 anti-slop → Gate 3 自动验证 → Gate 4 八维评分执行。
逐项核对 02_evidence_table.md，不允许通过润色掩盖缺失证据。
输出 qa_logs/full_paper_round_1.md 和 revision_briefs/round_1.md。
总分低于 7.0 时不要称为可交付；最多定向回退三轮。
```

评分解释：

- `< 6.0`：不可交付，重构；
- `6.0–7.0`：内部草稿；
- `7.0–8.0`：可给导师看；
- `> 8.0`：进入最终语言和格式打磨。

### 阶段 6：模拟审稿与投稿产物

在整稿分数达到 7.0 后再使用：

- `$nature-reviewer`：独立模拟 reviewer，输出 Major Concerns / Minor Comments；
- `$nature-data`：撰写 Data Availability 和数据仓储计划；
- `$nature-response`：真实返修后生成逐点回复，不提前虚构 reviewer；
- `$nature-paper2ppt`：组会或答辩汇报；
- `$nature-polishing`：最终英文压缩；
- `$nature-ref-verifier`：投稿前参考文献终审。

## 7. 哪个任务该用哪个 Skill

| 任务 | 首选 Skill | 不应让它承担的工作 |
|---|---|---|
| 整体状态机、foundation、整稿 QA | `$researchwrite` | 代替领域检索和数值实验 |
| 跨阶段研究到论文编排 | `$ars-codex:academic-research-suite` | 每个句子的细粒度润色 |
| 多源检索、BibTeX、引用核验 | `$nature-academic-search` | 把搜索摘要当成全文证据 |
| 单篇论文深读 | `$nature-paper-card` / `$nature-reader` | 自动支持论文中所有 claim |
| 分节起草和重构 | `$nature-writing` | 在证据缺失时自行发明内容 |
| 英文润色和压缩 | `$nature-polishing` | 改变 claim 强度或科学边界 |
| 引用逐条核验 | `$nature-ref-verifier` | 替代论证结构设计 |
| 方法/统计审计 | `$nature-statistics` / `$statistical-analysis` | 在无重复数据时制造显著性 |
| MATLAB 数据和算法工作 | `$matlab` | 替代论文证据台账 |
| 单位与误差 | `$uncertainty-and-units` | 把数值误差误写成统计不确定度 |
| 科学推断与反例 | `$scientific-critical-thinking` | 直接改写稿件语言 |
| 投稿级图 | `$nature-figure` | 在数据未冻结前做装饰性出图 |
| 模拟审稿 | `$nature-reviewer` | 在 foundation 不稳定时过早审稿 |

## 8. 每轮工作的标准交付格式

每次给 Codex 的任务都要求返回：

1. 修改/生成文件的绝对路径；
2. 当前阶段、轮次和分数；
3. 新增或改变的 claim 及其证据状态；
4. 已运行的验证及结果；
5. 剩余风险；
6. 只给一条最优先的下一步。

建议每轮只完成一个可审查单元，例如“foundation”“一张图”“一个 Results 小节”“一次 QA”，不要用一个提示词同时要求检索、实验、整稿重写和投稿。

## 9. Git 和文件管理建议

- 先新建工作分支，例如 `codex/ray-reuse-foundation`；
- foundation、文献证据、实验脚本/数据、正文同步分别提交；
- `main.tex` 与 `outline.md` 的同步应在同一提交中完成；
- 原始数据、生成脚本和最终图之间要能追踪；
- 不提交凭据、虚拟环境、临时日志或不必要的构建中间文件；
- 是否跟踪 `main.pdf` 由项目规则明确，不要在写作过程中反复增删；
- 任何 Git 历史改写、批量删除或外部归档都必须单独确认。

## 10. 推荐的前五个实际任务

按顺序新开或继续任务：

1. **安全与 foundation 初始化**：轮换凭据后，创建 `AGENTS.md` 和 foundation 五文件；
2. **现稿 claim 审计**：逐段映射 `main.tex` 与 `outline.md`，输出 unsupported claim 列表；
3. **文献缺口检索**：只补理论边界、创新性和模型参数来源；
4. **最小验证实验**：先做 100/1000 Hz 的轨迹差、复声场误差和运行时间；
5. **Results-first 重写**：生成可审查的图、表和 Results 草稿，再决定是否保留 speedup 与定位应用主张。

在这五步完成前，不建议继续润色 Abstract。当前 Abstract 和 Highlights 应被视为“目标版本”，不是已经被仓库证据完全支持的最终结论。

## 11. 停止规则

满足任一条件时停止润色，改为报告阻塞：

- 关键 claim 缺少数据或一手文献；
- 动态专家对同一前提存在无法诚实化解的冲突；
- 连续两轮分数提升小于 0.5；
- 已达到三轮定向修订上限；
- 当前交付目标已经达到。

停止时必须说明当前分数、剩余问题、停止原因和唯一建议的下一步。不能用更流畅的英文掩盖证据缺口。

