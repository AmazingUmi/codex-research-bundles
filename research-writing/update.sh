#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/helpers.sh
source "$SCRIPT_DIR/../shared/helpers.sh"
MANIFEST="$SCRIPT_DIR/manifest.txt"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$PROJECT_ROOT/.agents/skills}"
NATURE_CHECKOUT="${NATURE_SKILLS_SOURCE:-$HOME/ai-skills/nature-skills}"

assert_manifest "$MANIFEST"
nature_repo="$(awk -F '|' '$1 == "nature-source" { print $3; exit }' "$MANIFEST")"
ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"

status_info "Research-Writing update preflight"
preflight_gh_skill
preflight_codex_plugin

status_info "Research-Writing: updating Nature-managed directories only"
update_nature_all "$nature_repo" "$NATURE_CHECKOUT"

status_info "Research-Writing: updating only manifest-listed K-Dense skills"
awk -F '|' '$1 == "kdense" { print }' "$MANIFEST" |
while IFS='|' read -r _kind slug repo _profile _required; do
  update_kdense_skill "$repo" "$slug"
done

status_info "Research-Writing: updating only ARS-Codex"
update_ars_plugin "$ars_repo"

status_ok "Research-Writing update completed. Other Codex skills were not targeted."
