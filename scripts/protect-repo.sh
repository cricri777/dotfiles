#!/usr/bin/env bash
set -euo pipefail

repo="${1:?usage: protect-repo.sh <repo-name>}"
owner="$(gh api user --jq .login)"

if [ "$(gh api "repos/$owner/$repo/rulesets" --jq '[.[] | select(.name == "protect-main")] | length')" != 0 ]; then
  echo "ok      $owner/$repo already has protect-main"
  exit 0
fi

gh api -X POST "repos/$owner/$repo/rulesets" --input - --jq '"added   protect-main to \(.source)"' <<'JSON'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "rules": [{"type": "deletion"}, {"type": "non_fast_forward"}, {"type": "required_signatures"}],
  "bypass_actors": []
}
JSON
