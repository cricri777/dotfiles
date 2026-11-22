#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$here/common.sh"

usage="usage: feedback.sh <project> list | feedback.sh <project> reply <comment-id> <resolved|wont_fix|in_progress> <text>"
[ $# -ge 2 ] || fail "$usage"
project="$1"
action="$2"
validate_project "$project"
case "$action" in
  list) [ $# -eq 2 ] || fail "$usage" ;;
  reply)
    [ $# -eq 5 ] || fail "$usage"
    case "$4" in resolved | wont_fix | in_progress) ;; *) fail "status must be resolved, wont_fix or in_progress" ;; esac
    ;;
  *) fail "$usage" ;;
esac

# shellcheck disable=SC2029
ssh "$CB_HOST" "$(printf '%q ' python3 - "$CB_URL" "$@")" <<'PYTHON'
import json
import os
import secrets
import sys
import urllib.error
import urllib.request

origin, project, action, *args = sys.argv[1:]
base = "http://127.0.0.1:8787/v1/annotate/reviews/" + project
secrets_file = os.path.expanduser("~/git/prototypes/%s.secrets" % project)

try:
    with open(secrets_file) as handle:
        agent_token = dict(line.strip().split("=", 1) for line in handle if "=" in line)["AGENT_TOKEN"]
except (OSError, KeyError):
    sys.exit("error: no secrets for project '%s', deploy it first" % project)


def call(method, path, token=None, body=None):
    data = json.dumps(body).encode() if body is not None else None
    request = urllib.request.Request(base + path, data=data, method=method)
    request.add_header("Origin", origin)
    if body is not None:
        request.add_header("Content-Type", "application/json")
    if token:
        request.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(request) as response:
            raw = response.read()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as error:
        detail = error.read().decode()
        sys.exit("error: HTTP %s %s" % (error.code, detail if detail.startswith("{") else ""))
    except urllib.error.URLError as error:
        sys.exit("error: annotate server unreachable: %s" % error.reason)


token = call("POST", "/session", body={"invite": agent_token})["token"]
comments = call("GET", "/comments", token)["comments"]

if action == "list":
    for comment in comments:
        if comment["status"] in ("resolved", "wont_fix"):
            continue
        print(json.dumps({
            "id": comment["id"],
            "page": comment["page"],
            "type": comment["type"],
            "status": comment["status"],
            "author": comment["author"],
            "quote": (comment.get("anchor") or {}).get("exact"),
            "selector": (comment.get("geom") or {}).get("selector"),
            "text": comment["text"],
            "replies": [{"author": r["author"], "text": r["text"]} for r in comment["replies"]],
        }, ensure_ascii=False))
else:
    comment_id, status, text = args
    comment = next((c for c in comments if c["id"] == comment_id), None)
    if comment is None:
        sys.exit("error: comment '%s' not found" % comment_id)
    call("POST", "/comments/%s/replies" % comment_id, token, {"id": "r" + secrets.token_hex(8), "text": text})
    if comment["status"] != status:
        call("PUT", "/comments/%s" % comment_id, token, {
            "type": comment["type"],
            "page": comment["page"],
            "url": comment["url"],
            "text": comment["text"],
            "color": comment["color"],
            "anchor": comment["anchor"],
            "geom": comment["geom"],
            "status": status,
        })
    print("replied to %s, status %s" % (comment_id, status))
PYTHON
