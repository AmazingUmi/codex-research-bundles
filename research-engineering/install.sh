#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/helpers.sh
source "$SCRIPT_DIR/../shared/helpers.sh"
MANIFEST="$SCRIPT_DIR/manifest.txt"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$PROJECT_ROOT/.agents/skills}"
WITH_EXTENSIONS=0
WITH_ARS=0

usage() {
  printf '%s\n' 'Usage: ./install.sh [--with-extensions] [--with-ars]'
  printf '%s\n' '  default: install only Engineering core K-Dense skills'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --with-extensions) WITH_EXTENSIONS=1 ;;
    --with-ars) WITH_ARS=1 ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done

assert_manifest "$MANIFEST"
status_info "Research-Engineering preflight"
preflight_gh_skill
if [ "$WITH_ARS" -eq 1 ]; then
  preflight_codex_plugin
fi

status_info "Research-Engineering: K-Dense core"
awk -F '|' '$1 == "kdense" && $4 == "core" { print }' "$MANIFEST" |
while IFS='|' read -r _kind slug repo _profile _required; do
  install_kdense_skill "$repo" "$slug" project
done

if [ "$WITH_EXTENSIONS" -eq 1 ]; then
  status_info "Research-Engineering: recommended extensions"
  awk -F '|' '$1 == "kdense" && $4 == "extension" { print }' "$MANIFEST" |
  while IFS='|' read -r _kind slug repo _profile _required; do
    install_kdense_skill "$repo" "$slug" project
  done
else
  status_ok "recommended extensions were not requested; use --with-extensions to add them"
fi

if [ "$WITH_ARS" -eq 1 ]; then
  ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"
  ars_ref="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $4; exit }' "$MANIFEST")"
  status_info "Research-Engineering: optional ARS-Codex"
  install_ars_plugin "$ars_repo" "$ars_ref"
else
  status_ok "ARS-Codex was not requested and remains unmodified"
fi

status_ok "Research-Engineering installation completed. Open a new Codex conversation before using newly installed skills."
