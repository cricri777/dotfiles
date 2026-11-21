# KISS review

- Start a fresh read-only subagent with the Agent tool (`subagent_type` general-purpose). Give it only the goal, the diff and the repo rules files.
- Ask for concrete cuts: dead code, needless abstraction, duplication, comments, redundant docs, over-engineering.
- Apply the valid cuts. List the rejected cuts with a reason.
- Rerun 03-verify.md.
