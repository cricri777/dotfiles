# Commit and push

- Run `git fetch origin && git rebase origin/main`. If new commits arrived, rerun 03-verify.md.
- Stage only the files this task changed.
- Write the commit message following 06-unslop.md, and end it with the session's Co-Authored-By line.
- Run `git push origin HEAD:main`. The guard hook reruns the repo verify entry point.
- If the repo has CI, run `gh run watch` on the triggered run. If it is red, fix forward through 03-verify.md, or run `git revert`, push, and report.
- Never force-push.
- Fallback: commit and push `HEAD:cricri/<slug>`, leave `main` untouched, and explain in the report. Auto mode uses this when verification still fails after the budget.
- If the push is rejected, interactive mode stops and asks. Auto mode uses the fallback.
- Call `ExitWorktree` when done.
