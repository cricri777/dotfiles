# Plan

- Call `EnterWorktree` first, so parallel runs do not collide.
- If `EnterWorktree` refuses because the session did not start in a git repo, run `git worktree add` inside the target repo and use absolute paths there.
- Read the target repo docs: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, the CI config in `.github/workflows/`, and `Makefile`, `justfile`, `package.json` or `pyproject.toml`.
- Write the plan following 06-unslop.md, with a Verification section. It lists the exact commands, the end-to-end scenario that proves the change works, the tests to add or update, and the doc updates.
- If the repo has no `scripts/verify.sh` or equivalent single entry point, the plan adds one and documents it in `CLAUDE.md` or `CONTRIBUTING.md`. If the repo has no CI workflow, the plan also adds one that runs the entry point on push to `main`. Skip the workflow when `origin` is not on GitHub, and say so in the plan.
- Call `EnterPlanMode`, write the plan, then call `ExitPlanMode`. Loop on feedback until the human approves. Approval counts as the request for the listed tests.
- Both modes: the human always reviews and approves the plan. Never skip this step, even with `--auto`.
