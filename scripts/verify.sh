#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

files() {
  git ls-files --cached --others --exclude-standard -- "$1"
}

while IFS= read -r script; do
  bash -n "$script"
done < <(files '*.sh')

while IFS= read -r json; do
  jq empty "$json"
done < <(files '*.json')

if command -v shellcheck >/dev/null; then
  files '*.sh' | xargs shellcheck
else
  echo "warning: shellcheck not installed, skipping" >&2
fi

echo "verify ok"
