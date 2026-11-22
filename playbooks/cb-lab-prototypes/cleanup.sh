#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

[ $# -eq 1 ] || fail "usage: cleanup.sh <project>"
project="$1"
validate_project "$project"

ssh "$CB_HOST" bash -s -- "$project" <<'REMOTE'
set -euo pipefail
project="$1"
repos="$HOME/git/prototypes"
reviews=/etc/annotate/reviews.json
comments="/var/lib/annotate/$project.json"

sudo rm -f "/etc/nginx/prototypes/$project.htpasswd"
rm -rf "/srv/prototypes/$project"
rm -f "/srv/prototypes-offline/$project" "$repos/$project.secrets"

if jq -e --arg id "$project" '.reviews[] | select(.id == $id)' "$reviews" >/dev/null; then
  jq --arg id "$project" '.reviews |= map(select(.id != $id))' "$reviews" >"$reviews.tmp"
  mv "$reviews.tmp" "$reviews"
  sudo systemctl restart annotate
fi

if [ -f "$comments" ]; then
  mv --backup=numbered "$comments" "$repos/$project.comments.json"
fi
REMOTE

echo "$project is cleaned up on cb-lab. The git repo and the comments are kept."
echo "To delete them for good, an admin runs:"
echo "  ssh $CB_HOST 'rm -rf ~/git/prototypes/$project.git ~/git/prototypes/$project.comments.json*'"
