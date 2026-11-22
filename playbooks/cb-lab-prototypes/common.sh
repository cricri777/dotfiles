#!/usr/bin/env bash
export CB_HOST=cb-lab
export CB_URL=https://cb-lab.tail66d40f.ts.net

fail() {
  echo "error: $*" >&2
  exit 1
}

validate_project() {
  local LC_ALL=C
  [[ "$1" =~ ^[a-z0-9][a-z0-9-]{0,39}$ ]] || fail "project name '$1' must match [a-z0-9-], start with a letter or digit, and have at most 40 characters"
}
