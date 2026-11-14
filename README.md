# dotfiles

Personal configs for nvim, lazygit and herdr, shared across laptops.

## Supported platforms

| Platform | Status | Notes |
| --- | --- | --- |
| Linux | Supported | Tested on Omarchy (Arch). |
| Windows (WSL) | Supported | Run everything inside the WSL distro. Clone the repo under the Linux home (`~/`), not under `/mnt/c`, so symlinks work. |
| macOS | Supported | Requires bash (preinstalled); the script runs on the default macOS bash 3.2. |
| Native Windows (PowerShell) | Not supported | `install.sh` is a bash script. Use WSL instead. |

On macOS, lazygit may read its config from `~/Library/Application Support/lazygit` instead of `~/.config/lazygit`. Check with `lazygit --print-config-dir` and adjust `install.sh` if needed.

## Install

```bash
git clone https://github.com/cricri777/dotfiles.git ~/git/perso/dotfiles
~/git/perso/dotfiles/install.sh
```

The script symlinks each config into `~/.config`. Existing files are moved to `~/.config-backup-<timestamp>` first, so re-running it is safe.

## Layout

| Path | Linked to |
| --- | --- |
| `nvim/` | `~/.config/nvim` |
| `lazygit/` | `~/.config/lazygit` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |

## Contributing

1. Create a branch: `git checkout -b <short-description>`.
2. Make your change in this repo, not in `~/.config`. The symlinks make the edits show up there.
3. Commit with a short message that says what changed and why.
4. Push the branch and open a pull request into `main`.

Guidelines:

- Keep only portable config. Do not commit runtime or machine-specific files such as logs, sockets, sessions, plugin checkouts or build output.
- Never commit secrets (tokens, passwords, API keys). Use environment variables or a local file that is git-ignored instead.
- Commit `nvim/lazy-lock.json` after plugin updates so every laptop gets the same versions.
- Keep any platform-specific setting out of the shared config, or guard it in the config itself (for example with `vim.fn.has("mac")` in Neovim).
- To add a tool, create a folder for it at the root and add a line to `install.sh`.
