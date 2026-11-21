# Verify

This step blocks everything after it.

- Run the repo verify entry point. If none exists, run every check found in the docs and CI: build, lint, format, typecheck and the full test suite.
- Run the plan's end-to-end scenario on the real thing. Use the `run` skill for apps and a real CLI invocation for scripts.
- Re-read the full diff. Check correctness, edge cases, clarity, debug leftovers and comments.
- On failure, fix and rerun from the top.
- Report real command output, never a summary of what you expect.
- Interactive: if something cannot be verified, stop and ask.
- Auto: after 5 failed rounds, go to the fallback in 07-commit-push.md.
