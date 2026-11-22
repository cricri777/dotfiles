---
name: cricri
description: Plan, code, verify and push a task straight to main, interactively or unattended after plan approval with --auto.
argument-hint: "[--auto] <task>"
disable-model-invocation: true
---

# cricri

Task: $ARGUMENTS

Mode is auto when `--auto` is present, otherwise interactive.

Run the steps in order. Read each playbook file when its step starts.

1. Plan: playbook/01-plan.md
2. Code: playbook/02-code.md
3. Verify: playbook/03-verify.md
4. Break: playbook/04-break.md
5. KISS review: playbook/05-kiss-review.md
6. Unslop: playbook/06-unslop.md
7. Commit and push: playbook/07-commit-push.md
8. Retro: playbook/08-retro.md

Any change made in step 4, 5 or 6 sends you back through step 3.

## Modes

- Interactive: the human reviews the plan. Stop and ask when stuck.
- Both modes: the human always reviews and approves the plan in step 1.
- Auto: no human interaction after the plan is approved. Do not call `AskUserQuestion` after step 1. Pick the simplest reasonable option for each ambiguity and list it under Assumptions. The verify loop has a budget of 5 rounds. End with a final report, written following playbook/06-unslop.md, that lists the changes, the verification summary, the assumptions, the commit SHA or fallback branch, and the retro PR links.

## Hard rules

- Never skip or fake verification.
- Never force-push.
- Never push unverified code to `main`.
- Write no comments in code.
