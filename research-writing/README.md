# Research-Writing Bundle

定位：MacBook 上的科研分析 + 论文撰写环境。

## 默认内容

- ARS-Codex：`ars-codex@ars-codex`
- Nature：仓库中的完整顶层 Skill 集合
  - `nature-academic-search`
  - `nature-citation`
  - `nature-data`
  - `nature-downloader`
  - `nature-experiment-log`
  - `nature-figure`
  - `nature-image2ppt`
  - `nature-literature-pipeline`
  - `nature-paper-card`
  - `nature-paper-to-patent`
  - `nature-paper2ppt`
  - `nature-polishing`
  - `nature-proposal-writer`
  - `nature-reader`
  - `nature-ref-verifier`
  - `nature-response`
  - `nature-reviewer`
  - `nature-shared`
  - `nature-statistics`
  - `nature-writing`
- K-Dense：`matlab`、`sympy`、`experimental-design`、`statistical-analysis`、`uncertainty-and-units`、`scientific-critical-thinking`、`scientific-visualization`

功能重叠不做删减。默认调用顺序为：ARS 编排流程，Nature 产出论文/文献/引用/审稿/PPT 等学术成品，K-Dense 负责数值、统计和方法论。

## 安装

```bash
./verify.sh
./install.sh
./verify.sh
```

`install.sh` 先检查 `gh`、版本、`gh skill`、`gh auth status` 和 Codex Plugin CLI，再执行任何写入。当前机器若仍显示 GitHub token 无效，请自行运行：

```bash
gh auth login
```

脚本不会自动登录、读取 token 内容或修改凭据。

Research-Writing 默认将 K-Dense 与 Nature Skill 安装到宿主项目的 `.agents/skills`，使用 project scope。当本 Bundle 位于 `<host>/.agents/codex-research-bundles` 时，会从 Bundle 路径自动推导宿主项目根 `<host>`，安装命令在该根目录执行。`install.sh`、`update.sh` 和 `verify.sh` 使用同一目录语义；可用 `CODEX_PROJECT_ROOT` 覆盖项目根目录，或用 `CODEX_SKILLS_DIR` 直接指定 K-Dense 与 Nature Skill 的安装、更新和验证位置。

Nature 安装严格使用已验证流程：缺少源码时 clone 到 `~/ai-skills/nature-skills`；随后执行 `scripts/update-codex-skills.sh --pull` 与 `--check`。脚本不使用 `--prune`。

ARS 使用官方 Codex-native Marketplace：

```bash
codex plugin marketplace add Imbad0202/academic-research-skills-codex --ref main
codex plugin add ars-codex@ars-codex
```

## 更新与验证

```bash
./update.sh
./verify.sh
```

`update.sh` 仅更新：Nature 官方脚本管理的目录、manifest 点名的 7 个 K-Dense Skill、ARS-Codex Marketplace/Plugin。不会调用 `gh skill update --all`，也不会更新其他 Codex Skill。

`verify.sh` 不启动交互式 Codex 会话，检查：

- 每个 manifest Skill 的 `SKILL.md`
- Nature 源码 origin、完整清单以及源码/安装副本 `MATCH`
- K-Dense Skill 的上游来源元数据
- ARS Marketplace origin 与插件可检测状态
- `gh skill` 可用性与登录就绪状态
- 最终 `PASS` / `WARN` / `FAIL` 计数

## Nature optional dependencies

Bundle 不安装任何 Python 依赖。推荐用 `uv` 为每个重型 Skill 建立独立环境，避免污染系统 Python。以下命令只是手工示例，不会由脚本执行。

### nature-figure

```bash
uv venv ~/ai-skills/venvs/nature-figure
uv pip install --python ~/ai-skills/venvs/nature-figure/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-figure/requirements.txt
```

该 requirements 当前用于自动渲染/碰撞 QA（PyMuPDF）。

### nature-image2ppt

```bash
uv venv ~/ai-skills/venvs/nature-image2ppt --python 3.11
uv pip install --python ~/ai-skills/venvs/nature-image2ppt/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-image2ppt/requirements.txt
```

如工作流调用外部模型，凭据应在运行时由用户单独配置，绝不能写入 Bundle。

### nature-paper-to-patent

```bash
uv venv ~/ai-skills/venvs/nature-paper-to-patent
uv pip install --python ~/ai-skills/venvs/nature-paper-to-patent/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-paper-to-patent/requirements.txt
```

CNIPA 检索为进一步可选项：

```bash
uv pip install --python ~/ai-skills/venvs/nature-paper-to-patent/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-paper-to-patent/scripts/disclosure/requirements-cnipa.txt
~/ai-skills/venvs/nature-paper-to-patent/bin/python -m playwright install chromium
```

### nature-academic-search

```bash
uv venv ~/ai-skills/venvs/nature-academic-search
uv pip install --python ~/ai-skills/venvs/nature-academic-search/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-academic-search/mcp-server/requirements.txt
```

MCP 注册、`PUBMED_EMAIL` 与可选 Elsevier/Scopus 凭据必须在单独的本机配置阶段完成；Bundle 不修改 `~/.codex` 配置。

### nature-downloader

```bash
uv venv ~/ai-skills/venvs/nature-downloader
uv pip install --python ~/ai-skills/venvs/nature-downloader/bin/python \
  -r ~/ai-skills/nature-skills/skills/nature-downloader/requirements.txt
```

其机构访问、浏览器登录或 publisher API 凭据同样不进入 Bundle。

## 非目标

本 Bundle 不同步设备、不复制插件缓存、不保存认证、不安装所有可选 Python 包，也不删除已有 Skill。项目产物通过 Git 项目仓库同步。
