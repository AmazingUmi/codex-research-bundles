# Research-Engineering Bundle

定位：Mac mini 上的科研开发 + 数值计算 + 算法实现环境。

## 默认 core

- `matlab`
- `sympy`
- `scientific-critical-thinking`
- `scientific-visualization`
- `statistical-analysis`
- `uncertainty-and-units`

默认不安装 Nature、论文写作、引用、审稿、response 或 PPT Skill，也不安装 ARS。

## 推荐 extensions

以下 slug 已在 `K-Dense-AI/scientific-agent-skills/skills/<slug>/SKILL.md` 中核实存在，并写入 manifest：

- `optimize-for-gpu`
- `pymoo`
- `scikit-learn`
- `pytorch-lightning`
- `statsmodels`

它们通过 `--with-extensions` 安装，不默认启用，以保持核心环境小而清晰：

```bash
./install.sh --with-extensions
```

特别注意：`optimize-for-gpu` 的实际内容面向 NVIDIA CUDA/RAPIDS，Apple Silicon Mac mini 无法在本机执行该 CUDA 路径。该 Skill 适合指导远程 Linux/NVIDIA、集群或 CI runner 上的优化；若所有计算都只在 Mac mini 本机运行，可不安装此扩展。`pytorch-lightning` 的具体 Apple MPS 支持仍应按项目版本与模型逐项验证。

## experimental-design 的归属

未加入 Engineering。内容审阅显示它主要处理数据采集前的随机化、区组、重复、试验单位、传统 factorial/fractional factorial、crossover 与 plate/batch 布局。虽然含 response-surface、Latin hypercube 和计算机模型采样，但不是 benchmark、ablation、regression/CI validation 的专用工程 Skill，因此只保留在 Research-Writing。

计算实验的 benchmark、ablation、regression、validation、CI 与 C++/Python 工程规范应由项目自己的 `AGENTS.md`、测试框架、benchmark harness 和项目级 Skills 定义。

## 安装

Research-Engineering 默认将 K-Dense Skill 安装到宿主项目的 `.agents/skills`，使用 `gh skill install --scope project --agent codex`。当本 Bundle 位于 `<host>/.agents/codex-research-bundles` 时，会从 Bundle 路径自动推导宿主项目根 `<host>`，安装命令在该根目录执行。`install.sh`、`update.sh` 和 `verify.sh` 使用同一目录语义；可用 `CODEX_PROJECT_ROOT` 覆盖项目根目录，或用 `CODEX_SKILLS_DIR` 直接指定安装、更新和验证目录。

```bash
./verify.sh
./install.sh
./verify.sh
```

安装 core + extensions：

```bash
./install.sh --with-extensions
```

如确实需要 Research workflow 总控，可显式加入 ARS：

```bash
./install.sh --with-ars
./install.sh --with-extensions --with-ars
```

脚本会检查 `gh` 是否存在、打印版本、确认 `gh skill` 可用并执行 `gh auth status`。未登录时只提示自行运行 `gh auth login`，不会自动处理凭据。

## 更新

```bash
./update.sh
./update.sh --with-extensions
./update.sh --with-extensions --with-ars
```

更新只点名相应 profile 的 manifest Skill；不会使用 `--all`，不会触碰 Nature，也不会默认更新 ARS。缺失或来源不明的同名 Skill 会被跳过并警告，不会强制覆盖。

## 验证

```bash
./verify.sh
```

core 缺失记为 `FAIL`；recommended extension 或可选 ARS 缺失记为 `WARN`。验证不启动 Codex 交互会话，最终打印 `PASS` / `WARN` / `FAIL` 计数。

## Python 与工具链

Skill 安装只安装说明、references 和随附脚本，不等于安装 Python/CUDA/ML 库。Bundle 不自动安装任何运行时依赖。每个科研项目应在自己的 `uv.lock`/`pyproject.toml`、Conda 环境、MATLAB Project、CMake preset 或容器中固定依赖；GPU 环境尤其应在目标 NVIDIA 主机上按 CUDA/driver 组合创建。

## 非默认 npx fallback

只有在 `gh skill` 不可用时才考虑手工 fallback：

```bash
npx skills add K-Dense-AI/scientific-agent-skills \
  --skill <slug> --global --agent codex --yes
```

Bundle 脚本不会自动执行该命令，也不会安装整个 collection。
