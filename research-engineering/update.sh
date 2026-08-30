#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../shared/helpers.sh
source "$SCRIPT_DIR/../shared/helpers.sh"
MANIFEST="$SCRIPT_DIR/manifest.txt"
WITH_EXTENSIONS=0
WITH_ARS=0

usage() {
  printf '%s\n' 'Usage: ./update.sh [--with-extensions] [--with-ars]'
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
status_info "Research-Engineering update preflight"
preflight_gh_skill
if [ "$WITH_ARS" -eq 1 ]; then
  preflight_codex_plugin
fi

status_info "Research-Engineering: updating only core manifest skills"
awk -F '|' '$1 == "kdense" && $4 == "core" { print }' "$MANIFEST" |
while IFS='|' read -r _kind slug repo _profile _required; do
  update_kdense_skill "$repo" "$slug"
done

if [ "$WITH_EXTENSIONS" -eq 1 ]; then
  status_info "Research-Engineering: updating only extension manifest skills"
  awk -F '|' '$1 == "kdense" && $4 == "extension" { print }' "$MANIFEST" |
  while IFS='|' read -r _kind slug repo _profile _required; do
    update_kdense_skill "$repo" "$slug"
  done
else
  status_ok "extension updates were not requested"
fi

if [ "$WITH_ARS" -eq 1 ]; then
  ars_repo="$(awk -F '|' '$1 == "plugin" && $2 == "ars-codex" { print $3; exit }' "$MANIFEST")"
  update_ars_plugin "$ars_repo"
else
  status_ok "optional ARS-Codex was not targeted"
fi

status_ok "Research-Engineering update completed. Nature Skills and unrelated Codex skills were not targeted."
