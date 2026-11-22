#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

[ $# -eq 1 ] || fail "usage: deploy.sh <project-dir>"
dir="$(cd "$1" 2>/dev/null && pwd -P)" || fail "directory '$1' does not exist"
project="$(basename "$dir")"
validate_project "$project"
remote_url="$CB_HOST:git/prototypes/$project.git"

[ "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" = "$dir" ] || fail "$dir must be the root of its own git repo"
git -C "$dir" rev-parse --verify -q HEAD >/dev/null || fail "$dir has no commit yet"
[ -z "$(git -C "$dir" status --porcelain)" ] || fail "$dir has uncommitted changes, commit them first"
other_remotes="$(git -C "$dir" remote | grep -vx cb-lab || true)"
[ -z "$other_remotes" ] || fail "prototypes are versioned only on cb-lab, remove the remote(s): $other_remotes"
current_url="$(git -C "$dir" remote get-url cb-lab 2>/dev/null || true)"
[ -z "$current_url" ] || [ "$current_url" = "$remote_url" ] || fail "remote cb-lab points to '$current_url', expected '$remote_url'"

ssh "$CB_HOST" bash -s -- "$project" <<'REMOTE'
set -euo pipefail
bare="$HOME/git/prototypes/$1.git"
[ -d "$bare" ] || git init -q --bare -b main "$bare"
REMOTE

[ -n "$current_url" ] || git -C "$dir" remote add cb-lab "$remote_url"
git -C "$dir" push cb-lab HEAD:refs/heads/main --tags 2>&1 || fail "push rejected. A kept repo named '$project' with another history may exist on cb-lab: pick another name, or ask an admin to delete it"

ssh "$CB_HOST" bash -s -- "$project" "$CB_URL" <<'REMOTE'
set -euo pipefail
project="$1"
origin="$2"
repos="$HOME/git/prototypes"
bare="$repos/$project.git"
secrets="$repos/$project.secrets"
site="/srv/prototypes/$project"
htpasswd="/etc/nginx/prototypes/$project.htpasswd"

mkdir -p "$site"
git --git-dir="$bare" --work-tree="$site" checkout -q -f main

if [ ! -f "$secrets" ]; then
  (
    umask 077
    {
      echo "PASSWORD=$(openssl rand -hex 12)"
      echo "AGENT_TOKEN=inv_$(openssl rand -hex 16)"
      echo "CLIENT_TOKEN=inv_$(openssl rand -hex 16)"
    } >"$secrets"
  )
fi
PASSWORD="$(sed -n 's/^PASSWORD=//p' "$secrets")"
AGENT_TOKEN="$(sed -n 's/^AGENT_TOKEN=//p' "$secrets")"
CLIENT_TOKEN="$(sed -n 's/^CLIENT_TOKEN=//p' "$secrets")"

if [ ! -f "$htpasswd" ]; then
  printf '%s' "$PASSWORD" | sudo htpasswd -i -c "$htpasswd" "$project"
fi

reviews=/etc/annotate/reviews.json
if ! jq -e --arg id "$project" '.reviews[] | select(.id == $id)' "$reviews" >/dev/null; then
  jq --arg id "$project" --arg origin "$origin" --arg agent "$AGENT_TOKEN" --arg client "$CLIENT_TOKEN" '
    .reviews += [{
      id: $id, name: $id, note: "Comment on the variant you prefer.", pages: [],
      origins: [$origin], open: false, closed: false, authors: ["claude"],
      invites: [
        {token: $agent, reviewer: {id: "claude", name: "Claude"}, expiresAt: null, revoked: false},
        {token: $client, reviewer: {id: "client", name: "Client"}, expiresAt: null, revoked: false}
      ]
    }]' "$reviews" >"$reviews.tmp"
  mv "$reviews.tmp" "$reviews"
  sudo systemctl restart annotate
  for _ in $(seq 50); do
    curl -s -o /dev/null http://127.0.0.1:8787/ && break
    sleep 0.2
  done
fi

echo
echo "Client link (open it once, it stores the comment access in the browser):"
echo "  $origin/$project/?an_invite=$CLIENT_TOKEN"
echo "Login:    $project"
echo "Password: $PASSWORD"
REMOTE
