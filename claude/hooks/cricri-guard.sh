#!/usr/bin/env bash
set -uo pipefail

input="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"

push_pattern='(^|[;&|(]|[[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?push([[:space:]]|$)'
force_pattern='[[:space:]](--force(-with-lease)?(=[^[:space:]]*)?|-[a-zA-Z]*f[a-zA-Z]*|\+[^[:space:]]+)([[:space:]]|$)'

if ! [[ "$command" =~ $push_pattern ]]; then
  exit 0
fi

push_args="${command#*push}"
if [[ "$push_args" =~ $force_pattern ]]; then
  echo "cricri-guard: force push is blocked." >&2
  exit 2
fi

if [ -n "$cwd" ] && [ -f "$cwd/scripts/verify.sh" ]; then
  if ! output="$(cd "$cwd" && bash scripts/verify.sh 2>&1)"; then
    echo "cricri-guard: scripts/verify.sh failed, push blocked." >&2
    tail -n 40 <<<"$output" >&2
    exit 2
  fi
fi

exit 0
