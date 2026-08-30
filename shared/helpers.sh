#!/usr/bin/env bash

# Shared, non-destructive helpers for the Codex Research Skill Bundles.
# This file intentionally contains no credentials, account data, or copied
# Codex configuration.

status_info() {
  printf '==> %s\n' "$*"
}

status_ok() {
  printf '    OK: %s\n' "$*"
}

status_warn() {
  printf '    WARN: %s\n' "$*" >&2
}

die() {
  printf '    FAIL: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required but was not found in PATH"
}

canonical_repo_url() {
  local value="$1"
  value="${value%.git}"
  case "$value" in
    git@github.com:*) value="https://github.com/${value#git@github.com:}" ;;
    ssh://git@github.com/*) value="https://github.com/${value#ssh://git@github.com/}" ;;
    http://*|https://*|ssh://*|/*|./*|../*) ;;
    */*) value="https://github.com/$value" ;;
  esac
  printf '%s\n' "$value"
}

assert_manifest() {
  local manifest="$1"
  [ -f "$manifest" ] || die "manifest not found: $manifest"
  if ! awk -F '|' '
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    NF != 5 { bad=1; print "malformed manifest line " NR ": " $0 > "/dev/stderr" }
    END { exit bad }
  ' "$manifest"; then
    die "manifest validation failed: $manifest"
  fi
}

codex_skills_dir() {
  printf '%s\n' "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
}

preflight_gh_skill() {
  need_cmd gh
  status_info "GitHub CLI: $(gh --version | awk 'NR==1 { print; exit }')"
  gh skill --help >/dev/null 2>&1 || die "this gh build does not provide 'gh skill'; update GitHub CLI"
  if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI is not authenticated. Run 'gh auth login' yourself, then rerun this script; no credentials were changed."
  fi
  status_ok "gh skill is available and gh auth status succeeded"
}

skill_declares_name() {
  local skill_file="$1"
  local slug="$2"
  if grep -Eq "^[[:space:]]*name:[[:space:]]*[\"']?${slug}[\"']?[[:space:]]*$" "$skill_file"; then
    return 0
  fi
  # Nature keeps this directory slug for packaging compatibility while the
  # public trigger remains researchwrite.
  if [ "$slug" = "nature-proposal-writer" ]; then
    grep -Eq "^[[:space:]]*name:[[:space:]]*[\"']?researchwrite[\"']?[[:space:]]*$" "$skill_file"
    return
  fi
  return 1
}

skill_matches_repo() {
  local skill_file="$1"
  local repo="$2"
  grep -Fq "github.com/$repo" "$skill_file"
}

install_kdense_skill() {
  local repo="$1"
  local slug="$2"
  local skills_dir
  local skill_file
  skills_dir="$(codex_skills_dir)"
  skill_file="$skills_dir/$slug/SKILL.md"

  if [ -f "$skill_file" ]; then
    if skill_declares_name "$skill_file" "$slug" && skill_matches_repo "$skill_file" "$repo"; then
      status_ok "K-Dense $slug already installed from $repo; unchanged"
      return 0
    fi
    status_warn "existing $skills_dir/$slug is not attributable to $repo; leaving it untouched"
    return 0
  fi

  status_info "Installing K-Dense skill: $slug"
  if ! gh skill install "$repo" "$slug" --agent codex --scope user; then
    die "K-Dense install failed for $slug"
  fi
  [ -f "$skill_file" ] || die "K-Dense reported success but $skill_file is missing"
  status_ok "installed K-Dense $slug at user/global Codex scope"
}

update_kdense_skill() {
  local repo="$1"
  local slug="$2"
  local skills_dir
  local skill_file
  skills_dir="$(codex_skills_dir)"
  skill_file="$skills_dir/$slug/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    status_warn "K-Dense $slug is not installed; update skipped (run install.sh to add it)"
    return 0
  fi
  if ! skill_matches_repo "$skill_file" "$repo"; then
    status_warn "K-Dense $slug has a different or unknown source; update skipped"
    return 0
  fi

  status_info "Updating K-Dense skill: $slug"
  if ! gh skill update --dir "$skills_dir" "$slug"; then
    die "K-Dense update failed for $slug"
  fi
  status_ok "updated or confirmed current: $slug"
}

assert_git_checkout_source() {
  local checkout="$1"
  local expected_repo="$2"
  local actual
  local expected

  [ -d "$checkout/.git" ] || die "$checkout exists but is not a Git checkout"
  actual="$(git -C "$checkout" remote get-url origin 2>/dev/null || true)"
  [ -n "$actual" ] || die "$checkout has no origin remote"
  actual="$(canonical_repo_url "$actual")"
  expected="$(canonical_repo_url "$expected_repo")"
  [ "$actual" = "$expected" ] || die "$checkout origin is $actual, expected $expected; leaving it untouched"
}

install_nature_all() {
  local repo_url="$1"
  local repo_ref="$2"
  local checkout="$3"
  local sync_script

  need_cmd git
  need_cmd rsync
  if [ ! -e "$checkout" ]; then
    status_info "Cloning Nature Skills into $checkout"
    mkdir -p "$(dirname "$checkout")"
    git clone --branch "$repo_ref" "$repo_url" "$checkout" || die "Nature Skills clone failed"
  else
    assert_git_checkout_source "$checkout" "$repo_url"
    status_ok "Nature Skills checkout already exists with the expected origin"
  fi

  sync_script="$checkout/scripts/update-codex-skills.sh"
  [ -x "$sync_script" ] || die "Nature sync script is missing or not executable: $sync_script"
  status_info "Updating and synchronizing all Nature Skills with the official repository script"
  "$sync_script" --pull || die "Nature Skills synchronization failed"
  "$sync_script" --check || die "Nature source/install match check failed"
  status_ok "Nature Skills synchronized and matched"
}

update_nature_all() {
  local repo_url="$1"
  local checkout="$2"
  local sync_script

  need_cmd git
  need_cmd rsync
  [ -e "$checkout" ] || die "Nature checkout is missing: $checkout (run install.sh first)"
  assert_git_checkout_source "$checkout" "$repo_url"
  sync_script="$checkout/scripts/update-codex-skills.sh"
  [ -x "$sync_script" ] || die "Nature sync script is missing or not executable: $sync_script"

  status_info "Pulling Nature Skills with fast-forward-only policy"
  git -C "$checkout" pull --ff-only || die "Nature Skills git pull failed"
  status_info "Synchronizing only Nature-managed skill directories"
  "$sync_script" || die "Nature Skills synchronization failed"
  "$sync_script" --check || die "Nature source/install match check failed"
  status_ok "Nature Skills updated and matched"
}

preflight_codex_plugin() {
  need_cmd codex
  status_info "Codex CLI: $(codex --version 2>/dev/null | awk 'NR==1 { print; exit }')"
  codex plugin --help >/dev/null 2>&1 || die "this Codex CLI does not provide plugin management commands"
  status_ok "Codex plugin CLI is available"
}

ars_marketplace_root() {
  codex plugin marketplace list 2>/dev/null |
    awk '$1 == "ars-codex" { root=$2 } END { if (root) print root }'
}

ars_plugin_installed() {
  codex plugin list 2>/dev/null |
    awk '$1 == "ars-codex@ars-codex" && $2 ~ /^installed/ { found=1 } END { exit !found }'
}

assert_ars_marketplace_source() {
  local expected_repo="$1"
  local root
  local actual
  local expected
  root="$(ars_marketplace_root)"
  [ -n "$root" ] || return 1
  [ -d "$root/.git" ] || die "ARS marketplace exists at $root but its Git source cannot be verified"
  actual="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
  [ -n "$actual" ] || die "ARS marketplace at $root has no origin remote"
  actual="$(canonical_repo_url "$actual")"
  expected="$(canonical_repo_url "$expected_repo")"
  [ "$actual" = "$expected" ] || die "ARS marketplace origin is $actual, expected $expected; leaving it untouched"
}

install_ars_plugin() {
  local repo="$1"
  local repo_ref="$2"

  if assert_ars_marketplace_source "$repo"; then
    status_ok "ARS marketplace already configured from the expected repository"
  else
    status_info "Adding the official ARS-Codex marketplace"
    codex plugin marketplace add "$repo" --ref "$repo_ref" || die "ARS marketplace add failed"
    assert_ars_marketplace_source "$repo" || die "ARS marketplace was added but is not detectable"
  fi

  if ars_plugin_installed; then
    status_ok "ARS-Codex plugin already installed and enabled; unchanged"
    return 0
  fi
  status_info "Installing ARS-Codex plugin from its configured marketplace"
  codex plugin add ars-codex@ars-codex || die "ARS-Codex plugin install failed"
  ars_plugin_installed || die "ARS-Codex plugin is not detectable after installation"
  status_ok "ARS-Codex plugin installed"
}

update_ars_plugin() {
  local repo="$1"
  if ! assert_ars_marketplace_source "$repo"; then
    status_warn "ARS marketplace is not configured; update skipped (run install.sh to add it)"
    return 0
  fi
  if ! ars_plugin_installed; then
    status_warn "ARS-Codex plugin is not installed; update skipped (run install.sh to add it)"
    return 0
  fi
  status_info "Refreshing only the ARS-Codex marketplace"
  codex plugin marketplace upgrade ars-codex || die "ARS marketplace upgrade failed"
  status_info "Re-adding ARS-Codex as required by its official update procedure"
  codex plugin add ars-codex@ars-codex || die "ARS-Codex plugin refresh failed"
  ars_plugin_installed || die "ARS-Codex plugin is not detectable after refresh"
  status_ok "ARS-Codex updated or confirmed current"
}

verify_reset() {
  VERIFY_PASS=0
  VERIFY_WARN=0
  VERIFY_FAIL=0
}

verify_pass() {
  VERIFY_PASS=$((VERIFY_PASS + 1))
  printf 'PASS  %s\n' "$*"
}

verify_warn() {
  VERIFY_WARN=$((VERIFY_WARN + 1))
  printf 'WARN  %s\n' "$*"
}

verify_fail() {
  VERIFY_FAIL=$((VERIFY_FAIL + 1))
  printf 'FAIL  %s\n' "$*"
}

verify_skill_file() {
  local slug="$1"
  local required="$2"
  local skill_file
  skill_file="$(codex_skills_dir)/$slug/SKILL.md"
  if [ -f "$skill_file" ] && skill_declares_name "$skill_file" "$slug"; then
    verify_pass "$slug SKILL.md exists and declares the expected name"
  elif [ "$required" = "required" ]; then
    verify_fail "$slug SKILL.md is missing or malformed at $skill_file"
  else
    verify_warn "$slug is optional/recommended and is not installed"
  fi
}

verify_kdense_skill() {
  local repo="$1"
  local slug="$2"
  local required="$3"
  local skill_file
  skill_file="$(codex_skills_dir)/$slug/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    if [ "$required" = "required" ]; then
      verify_fail "K-Dense $slug is not installed"
    else
      verify_warn "K-Dense $slug is recommended but not installed"
    fi
    return 0
  fi
  if ! skill_declares_name "$skill_file" "$slug"; then
    verify_fail "K-Dense $slug has a malformed or mismatched name"
  elif skill_matches_repo "$skill_file" "$repo"; then
    verify_pass "K-Dense $slug exists and records source $repo"
  else
    verify_fail "K-Dense $slug exists but its source is not attributable to $repo"
  fi
}

verify_gh_readiness() {
  if ! command -v gh >/dev/null 2>&1; then
    verify_warn "gh is missing; K-Dense install/update cannot run"
    return 0
  fi
  if gh skill --help >/dev/null 2>&1; then
    verify_pass "gh skill command is available ($(gh --version | awk 'NR==1 { print; exit }'))"
  else
    verify_fail "gh exists but does not provide the gh skill command"
  fi
  if gh auth status >/dev/null 2>&1; then
    verify_pass "gh auth status succeeded"
  else
    verify_warn "gh authentication is not ready; run gh auth login before install/update"
  fi
}

verify_ars_plugin() {
  local required="$1"
  local repo="$2"
  local root
  local actual
  local expected
  if ! command -v codex >/dev/null 2>&1; then
    if [ "$required" = "required" ]; then
      verify_fail "codex CLI is missing, so ARS plugin cannot be detected"
    else
      verify_warn "codex CLI is missing; optional ARS plugin cannot be detected"
    fi
    return 0
  fi
  if ! codex plugin --help >/dev/null 2>&1; then
    verify_fail "codex CLI does not support plugin inspection"
    return 0
  fi
  root="$(ars_marketplace_root)"
  if [ -n "$root" ] && [ -d "$root/.git" ]; then
    actual="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
    actual="$(canonical_repo_url "$actual")"
    expected="$(canonical_repo_url "$repo")"
    if [ "$actual" = "$expected" ]; then
      verify_pass "ARS marketplace source matches $repo"
    else
      verify_fail "ARS marketplace source is '$actual', expected '$expected'"
    fi
  elif [ -n "$root" ]; then
    verify_fail "ARS marketplace is present but its Git source cannot be verified: $root"
  elif [ "$required" = "required" ]; then
    verify_fail "ARS marketplace is not configured"
  else
    verify_warn "optional ARS marketplace is not configured"
  fi
  if ars_plugin_installed; then
    verify_pass "ARS-Codex plugin is installed and detectable"
  elif [ "$required" = "required" ]; then
    verify_fail "ARS-Codex plugin is not installed"
  else
    verify_warn "optional ARS-Codex plugin is not installed"
  fi
}

verify_summary() {
  printf '\nVerification summary\n'
  printf 'PASS: %s\n' "$VERIFY_PASS"
  printf 'WARN: %s\n' "$VERIFY_WARN"
  printf 'FAIL: %s\n' "$VERIFY_FAIL"
  [ "$VERIFY_FAIL" -eq 0 ]
}
