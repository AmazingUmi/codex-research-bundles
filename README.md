# Codex Research Skill Bundles

English | [中文](README.zh.md)

Set up Codex with research skills and plugins in one step. This repo only records *what* to install, *where from*, and *how to check it*. **It contains no accounts, tokens, or anything from `~/.codex`.**

## Two bundles

| | Research-Writing | Research-Engineering |
|---|---|---|
| For | Planning, literature, analysis, writing papers | Numerical computing, algorithms, validation, performance |
| Nature Skills (literature, writing, citations, review, figures, slides) | ✅ all 20 | — |
| K-Dense core (MATLAB, SymPy, statistics, uncertainty, visualization, critical thinking) | ✅ | ✅ |
| `experimental-design` | ✅ | — |
| ARS research-workflow plugin | ✅ | optional `--with-ars` |
| GPU / optimization / ML / DL / statsmodels | — | optional `--with-extensions` |

## Quick start

> **Requirement:** this project needs the [GitHub CLI](https://cli.github.com/) (`gh`) installed and logged in. Run `gh auth login` before any install or update; the scripts stop and remind you if you aren't logged in.

```bash
# Writing
cd research-writing
./verify.sh      # read-only check, changes nothing
./install.sh     # install
./update.sh      # update

# Engineering
cd research-engineering
./install.sh                               # core
./install.sh --with-extensions --with-ars  # plus extensions and ARS
```

Start a new Codex conversation afterwards so it picks up the new skills.

## Where things go

- Skills install into the current project's `.agents/skills`
  - Override with `CODEX_SKILLS_DIR`, or set the project root with `CODEX_PROJECT_ROOT`
- Nature source is cloned to `~/ai-skills/nature-skills`; override with `NATURE_SKILLS_SOURCE`

Example: `CODEX_SKILLS_DIR=~/my-skills NATURE_SKILLS_SOURCE=~/src/nature ./install.sh`
- ARS is installed through the Codex plugin marketplace

The scripts never delete skills, touch credentials, or install optional Python dependencies.

## Which one to use when they overlap

1. **ARS** runs the workflow: research planning, checkpoints, research-to-paper pipeline
2. **Nature** produces academic deliverables: literature, manuscripts, citations, reviews and responses, publication-ready figures
3. **K-Dense** handles methods: math, statistics, units and uncertainty, numerical computing
4. **Your project's `AGENTS.md`** sets engineering rules: build, tests, CI

## Sources

| Component | Source | Updated with |
|---|---|---|
| Nature | `nature-skills` repo, `main` | `git pull --ff-only` + its sync script |
| K-Dense | [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | `gh skill` (only listed skills, never `--force`) |
| ARS | [Imbad0202/academic-research-skills-codex](https://github.com/Imbad0202/academic-research-skills-codex) | Codex plugin marketplace |

## No `gh skill`?

Install manually with `npx skills` (the scripts won't do this for you):

```bash
npx skills add K-Dense-AI/scientific-agent-skills --skill <slug> --global --agent codex --yes
```

This installs globally to `~/.agents/skills`; check with `npx skills list --global --agent codex`.
