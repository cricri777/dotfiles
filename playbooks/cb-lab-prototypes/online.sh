#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

[ $# -eq 1 ] || fail "usage: online.sh <project>"
validate_project "$1"
ssh "$CB_HOST" bash -s -- "$1" <<'REMOTE'
rm -f "/srv/prototypes-offline/$1"
REMOTE
echo "$1 is online: $CB_URL/$1/"
