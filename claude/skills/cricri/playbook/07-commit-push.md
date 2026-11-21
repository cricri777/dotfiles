# Commit and push

- Stage only the files this task changed.
- Write the commit message following 06-unslop.md, and end it with the session's Co-Authored-By line.
- Run `git fetch origin && git rebase origin/main`.
- If the rebase stops on a conflict, resolve it:
  - Read both sides and the commits that touched the file (`git log origin/main -- <file>`).
  - Keep the intent of both sides. Never drop a change from `main` to make yours fit.
  - Remove every conflict marker, `git add` the file, `git rebase --continue`.
  - If the intent of a side is unclear, interactive mode stops and asks. Auto mode runs `git rebase --abort` and uses the fallback.
- If the rebase brought new commits, rerun 03-verify.md.
- Run `git push origin HEAD:main`. The guard hook reruns the repo verify entry point.
- If the push is rejected because `main` moved, fetch, rebase, resolve and verify again. After 3 rejections, interactive mode stops and asks. Auto mode uses the fallback.
- If the repo has CI, run `gh run watch` on the triggered run. If it is red, fix forward through 03-verify.md, or run `git revert`, push, and report.
- Never force-push.
- Fallback: push `HEAD:cricri/<slug>`, leave `main` untouched, and explain in the report. Auto mode uses this when verification still fails after the budget.
- Call `ExitWorktree` when done.
