# Codex Research Skill Bundles

[English](README.md) | 中文

一键给 Codex 装好科研用的 Skill 和插件。这个仓库只保存“装什么、从哪装、怎么检查”，**不含任何账号、token 或 `~/.codex` 里的内容**。

## 两套环境

| | Research-Writing（写论文） | Research-Engineering（做计算） |
|---|---|---|
| 用途 | 规划研究、读文献、分析、写论文 | 数值计算、算法开发、验证、性能 |
| Nature Skills（文献、写作、引用、审稿、图表、PPT） | ✅ 全部 20 个 | — |
| K-Dense 基础（MATLAB、SymPy、统计、不确定度、可视化、批判性思维） | ✅ | ✅ |
| 实验设计 `experimental-design` | ✅ | — |
| ARS 研究流程插件 | ✅ | 可选 `--with-ars` |
| GPU / 优化 / ML / DL / statsmodels | — | 可选 `--with-extensions` |

## 快速开始

> **前提：** 本项目需要安装并登录 [GitHub CLI](https://cli.github.com/)（`gh`）。安装或更新前请先运行 `gh auth login`；没登录时脚本会停下来提醒你。

```bash
# 写论文
cd research-writing
./verify.sh      # 只读检查，不改任何东西
./install.sh     # 安装
./update.sh      # 更新

# 做计算
cd research-engineering
./install.sh                               # 基础
./install.sh --with-extensions --with-ars  # 加扩展和 ARS
```

装完后新开一个 Codex 对话，新 Skill 才会生效。

## 装到哪里

- Skill 默认装进当前项目的 `.agents/skills`
  - 改目录：设置 `CODEX_SKILLS_DIR`；改项目根目录：设置 `CODEX_PROJECT_ROOT`
- Nature 源码克隆到 `~/ai-skills/nature-skills`，可用 `NATURE_SKILLS_SOURCE` 改位置

例如：`CODEX_SKILLS_DIR=~/my-skills NATURE_SKILLS_SOURCE=~/src/nature ./install.sh`
- ARS 通过 Codex 插件市场安装

脚本不会删除 Skill、不会改认证信息、不会自动装 Python 可选依赖。

## 功能重叠时用谁

三套 Skill 有重叠，按层分工：

1. **ARS** 管流程：研究规划、阶段检查点、从研究到论文
2. **Nature** 出学术成品：文献、稿件、引用、审稿回复、投稿级图表
3. **K-Dense** 做方法：数学、统计、单位与误差、数值计算
4. **项目自己的 `AGENTS.md`** 管工程规则：构建、测试、CI

## 版本来源

| 组件 | 来源 | 更新方式 |
|---|---|---|
| Nature | `nature-skills` 仓库 `main` | `git pull --ff-only` + 官方同步脚本 |
| K-Dense | [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | `gh skill`（只更新清单里的 Skill，不用 `--force`） |
| ARS | [Imbad0202/academic-research-skills-codex](https://github.com/Imbad0202/academic-research-skills-codex) | Codex 插件市场 |

## 没有 `gh skill` 怎么办

可以手动用 `npx skills`（脚本不会自动这样做）：

```bash
npx skills add K-Dense-AI/scientific-agent-skills --skill <slug> --global --agent codex --yes
```

注意它会装到全局 `~/.agents/skills`，可用 `npx skills list --global --agent codex` 确认位置。
