# Break

- Start a fresh subagent with the Agent tool (`subagent_type` general-purpose). Give it the goal, the diff and the verify commands, and no conversation context.
- Tell it to break the change by running things: edge cases, bad inputs, missing paths.
- It reports reproducible failures only.
- Fix each confirmed failure. Add a test only when the plan's test policy allows it.
- Rerun 03-verify.md.
