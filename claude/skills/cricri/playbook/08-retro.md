# Retro

- Run this step only when there is a real lesson: a flaky command, a missing doc or a playbook gap.
- Target-repo lesson: create a branch, edit its `CLAUDE.md` or `CONTRIBUTING.md`, push, and run `gh pr create`. When `origin` is not on GitHub, report the pushed branch name instead of a PR link.
- Playbook lesson: do the same in the dotfiles repo. `readlink -f ~/.claude/skills/cricri` locates it.
- Never auto-merge a PR. Put the links in the final report.
- Write the PR text following 06-unslop.md.
