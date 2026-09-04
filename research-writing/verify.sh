#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/helpers.sh
source "$SCRIPT_DIR/../shared/helpers.sh"
MANIFEST="$SCRIPT_DIR/manifest.txt"
PROJECT_ROOT="$(codex_project_root)"
export CODEX_PROJECT_ROOT="$PROJECT_ROOT"
export CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$PROJECT_ROOT/.agents/skills}"
NATURE_CHECKOUT="${NATURE_SKILLS_SOURCE:-$HOME/ai-skills/nature-skills}"
SKILLS_DIR="$(codex_skills_dir)"

assert_manifest "$MANIFEST"
verify_reset

verify_gh_readiness

nature_repo="$(awk -F '|' '$1 == "nature-source" { print $3; exit }' "$MANIFEST")"
if [ -d "$NATURE_CHECKOUT/.git" ]; then
  actual_origin="$(git -C "$NATURE_CHECKOUT" remote get-url origin 2>/dev/null || true)"
  if [ "$(canonical_repo_url "$actual_origin")" = "$(canonical_repo_url "$nature_repo")" ]; then
    verify_pass "Nature source checkout has the expected origin"
  else
    verify_fail "Nature source origin is '$actual_origin', expected '$nature_repo'"
  fi
else
  verify_fail "Nature source checkout is missing or is not Git: $NATURE_CHECKOUT"
fi

while IFS='|' read -r _kind slug _repo _profile required; do
  if [ -f "$NATURE_CHECKOUT/skills/$slug/SKILL.md" ]; then
    verify_pass "Nature source contains $slug/SKILL.md"
  else
    verify_fail "Nature source is missing $slug/SKILL.md"
  fi
  verify_skill_file "$slug" "$required"
done < <(awk -F '|' '$1 == "nature-skill" { print }' "$MANIFEST")

if [ -x "$NATURE_CHECKOUT/scripts/update-codex-skills.sh" ]; then
  nature_check_log="$(mktemp "${TMPDIR:-/tmp}/nature-check.XXXXXX")"
  if "$NATURE_CHECKOUT/scripts/update-codex-skills.sh" --check >"$nature_check_log" 2>&1; then
    verify_pass "Nature installed copies MATCH the source according to the official sync script"
  else
    verify_fail "Nature official source/install match check failed"
    sed 's/^/      /' "$nature_check_log"
  fi
  rm -f "$nature_check_log"
else
  verify_fail "Nature official sync/check script is unavailable"
fi

if [ -d "$NATURE_CHECKOUT/skills" ]; then
  manifest_inventory="$(mktemp "${TMPDIR:-/tmp}/nature-manifest.XXXXXX")"
  source_inventory="$(mktemp "${TMPDIR:-/tmp}/nature-source.XXXXXX")"
  awk -F '|' '$1 == "nature-skill" { print $2 }' "$MANIFEST" | sort >"$manifest_inventory"
  find "$NATURE_CHECKOUT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename '{}' \; | sort >"$source_inventory"
  if diff -q "$manifest_inventory" "$source_inventory" >/dev/null 2>&1; then
    verify_pass "Nature manifest inventory matches the repository's complete top-level skill set"
  else
    verify_warn "Nature repository inventory changed; update manifest.txt after reviewing the new/removed skills"
  fi
  rm -f "$manifest_inventory" "$source_inventory"
fi

while IFS='|' read -r _kind slug repo _profile required; do
  verify_kdense_skill "$repo" "$slug" "$required"
done < <(awk -F '|' '$1 == "kdense" { print }' "$MANIFEST")

ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"
verify_ars_plugin required "$ars_repo"

if ! verify_summary; then
  exit 1
fi
