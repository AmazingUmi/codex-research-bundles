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

assert_manifest "$MANIFEST"

nature_repo="$(awk -F '|' '$1 == "nature-source" { print $3; exit }' "$MANIFEST")"
nature_ref="$(awk -F '|' '$1 == "nature-source" { print $4; exit }' "$MANIFEST")"
ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"
ars_ref="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $4; exit }' "$MANIFEST")"

status_info "Research-Writing preflight"
preflight_gh_skill
preflight_codex_plugin

status_info "Research-Writing: Nature component"
install_nature_all "$nature_repo" "$nature_ref" "$NATURE_CHECKOUT"

status_info "Research-Writing: K-Dense component"
awk -F '|' '$1 == "kdense" { print }' "$MANIFEST" |
while IFS='|' read -r _kind slug repo _profile _required; do
  install_kdense_skill "$repo" "$slug" project
done

status_info "Research-Writing: ARS component"
install_ars_plugin "$ars_repo" "$ars_ref"

status_ok "Research-Writing installation completed. Open a new Codex conversation before using newly installed skills."
