#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/helpers.sh
source "$SCRIPT_DIR/../shared/helpers.sh"
MANIFEST="$SCRIPT_DIR/manifest.txt"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$PROJECT_ROOT/.agents/skills}"

assert_manifest "$MANIFEST"
verify_reset
verify_gh_readiness

while IFS='|' read -r _kind slug repo _profile required; do
  verify_kdense_skill "$repo" "$slug" "$required"
done < <(awk -F '|' '$1 == "kdense" { print }' "$MANIFEST")

ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"
verify_ars_plugin optional "$ars_repo"

if ! verify_summary; then
  exit 1
fi
