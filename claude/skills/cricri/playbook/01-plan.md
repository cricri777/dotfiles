# Plan

- Call `EnterWorktree` first, so parallel runs do not collide.
- Read the target repo docs: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, the CI config in `.github/workflows/`, and `Makefile`, `justfile`, `package.json` or `pyproject.toml`.
- Write a plan with a Verification section. It lists the exact commands, the end-to-end scenario that proves the change works, the tests to add or update, and the doc updates.
- If the repo has no `scripts/verify.sh` or equivalent single entry point, the plan adds one and documents it in `CLAUDE.md` or `CONTRIBUTING.md`. If the repo has no CI workflow, the plan also adds one that runs the entry point on push to `main`.
- Interactive: call `EnterPlanMode`, write the plan, then call `ExitPlanMode`. Loop on feedback until the human approves. Approval counts as the request for the listed tests.
- Auto: write the plan to the scratchpad. Start a fresh critic subagent with the Agent tool (`subagent_type` general-purpose) to review it, for at most 2 rounds. Then proceed.
