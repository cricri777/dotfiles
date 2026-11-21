# Contributing

## Workflow

1. Create a branch from `main`: `git checkout -b <short-description>`.
2. Make your change in this repo, not in `~/.config`. The symlinks make the edits show up there.
3. Run `scripts/verify.sh`. It checks shell syntax, JSON validity and shellcheck. CI runs it on every push.
4. Commit with a short message that says what changed and why.
5. Push the branch and open a pull request into `main`.

## Guidelines

- Keep only portable config. Do not commit runtime or machine-specific files such as logs, sockets, sessions, plugin checkouts or build output.
- Never commit secrets (tokens, passwords, API keys). Use environment variables or a local file that is git-ignored instead.
- Commit `nvim/lazy-lock.json` after plugin updates so every laptop gets the same versions.
- Keep any platform-specific setting out of the shared config, or guard it in the config itself.
- To add a tool, create a folder for it at the root and add a line to `install.sh`.
- Follow `.editorconfig` (LF line endings, 2-space indentation, final newline).
- Update the matching page in `docs/` when you change behaviour or keybindings.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
