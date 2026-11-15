# dotfiles

Personal configs for nvim, lazygit and herdr, shared across laptops.

## Supported platforms

| Platform | Status | Notes |
| --- | --- | --- |
| Linux | Supported | Tested on Omarchy (Arch). |
| Windows (WSL) | Supported | Run everything inside the WSL distro. Clone the repo under the Linux home (`~/`), not under `/mnt/c`, so symlinks work. |
| Native Windows (PowerShell) | Not supported | `install.sh` is a bash script. Use WSL instead. |

## Packages

Install the tools first:

```bash
# Arch / Omarchy
sudo pacman -S neovim lazygit git

# Debian / Ubuntu / WSL (lazygit may be outdated in apt; see https://github.com/jesseduffield/lazygit#installation)
sudo apt install neovim git
```

- Herdr: see https://herdr.dev.
- Nerd Font: install one (for example JetBrainsMono Nerd Font) and select it in your terminal.

## Install

```bash
git clone https://github.com/cricri777/dotfiles.git ~/git/perso/dotfiles
~/git/perso/dotfiles/install.sh
```

The script symlinks each config into `~/.config`. Existing files are moved to `~/.config-backup-<timestamp>` first, so re-running it is safe.

Then install the herdr plugins listed in `herdr/plugins.txt` (plugins may need `cargo` to build):

```bash
grep -v '^#' herdr/plugins.txt | grep -v '^$' | while read -r plugin; do herdr plugin install -y "$plugin"; done
```

## Verify

```bash
ls -l ~/.config/nvim ~/.config/lazygit ~/.config/herdr/config.toml   # should point into this repo
nvim --headless "+Lazy! sync" +qa                                    # installs plugins from lazy-lock.json
lazygit --print-config-dir                                           # should print ~/.config/lazygit
herdr plugin list
```

## Restore

Backups from `install.sh` are kept in `~/.config-backup-<timestamp>`. To restore one, remove the symlink and move the backup back:

```bash
rm ~/.config/nvim && mv ~/.config-backup-<timestamp>/nvim ~/.config/nvim
```

## Layout

| Path | Linked to |
| --- | --- |
| `nvim/` | `~/.config/nvim` |
| `lazygit/` | `~/.config/lazygit` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `herdr/plugins.txt` | Herdr plugins to install (not linked) |
| `shell/aliases.sh` | `~/.config/shell/aliases.sh`, sourced once from `~/.bashrc` (`n` = nvim, `lg` = lazygit) |

## Contributing

1. Create a branch: `git checkout -b <short-description>`.
2. Make your change in this repo, not in `~/.config`. The symlinks make the edits show up there.
3. Run `shellcheck install.sh` before committing. CI runs it too.
4. Commit with a short message that says what changed and why.
5. Push the branch and open a pull request into `main`.

Guidelines:

- Keep only portable config. Do not commit runtime or machine-specific files such as logs, sockets, sessions, plugin checkouts or build output.
- Never commit secrets (tokens, passwords, API keys). Use environment variables or a local file that is git-ignored instead.
- Commit `nvim/lazy-lock.json` after plugin updates so every laptop gets the same versions.
- Keep any platform-specific setting out of the shared config, or guard it in the config itself.
- To add a tool, create a folder for it at the root and add a line to `install.sh`.
- Follow `.editorconfig` (LF line endings, 2-space indentation, final newline).
