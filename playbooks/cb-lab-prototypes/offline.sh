#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

[ $# -eq 1 ] || fail "usage: offline.sh <project>"
validate_project "$1"
ssh "$CB_HOST" bash -s -- "$1" <<'REMOTE'
set -euo pipefail
[ -f "/etc/nginx/prototypes/$1.htpasswd" ] || { echo "error: project '$1' is not deployed" >&2; exit 1; }
touch "/srv/prototypes-offline/$1"
REMOTE
echo "$1 is offline (503). Run online.sh $1 to bring it back."
