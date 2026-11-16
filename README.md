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

## Herdr plugin: last tab and last workspace

`herdr/plugins.txt` installs [m4salah/herdr-plugin-last](https://github.com/m4salah/herdr-plugin-last), a tmux-style `last-window` and `switch-client -l` for Herdr. It provides two actions:

| Action | What it does |
| --- | --- |
| `m4salah.last.last-tab` | Jumps to the most recently focused tab in the current workspace |
| `m4salah.last.last-workspace` | Jumps to the most recently focused workspace |

Both toggle: press the key twice to go back to where you started.

### Requirements

- Herdr 0.7.5 or newer.
- A Rust toolchain (`cargo`). `herdr plugin install` compiles the plugin from source. The build output is hidden, so the install can look stuck for a few seconds to a minute. Wait for it to finish.

### Install

The loop in [Install](#install) already installs it. To install only this plugin:

```bash
herdr plugin install m4salah/herdr-plugin-last
```

The plugin is pinned to a commit when installed. To pull a newer version, run `herdr plugin update m4salah.last`.

### Keybindings

`herdr/config.toml` already binds last-tab:

```toml
[[keys.command]]
key = "prefix+t"
type = "plugin_action"
command = "m4salah.last.last-tab"
description = "toggle to last focused tab"
```

- Do not use `prefix+;` for last-tab. This config binds it to `last_pane`.
- `last-workspace` is not bound. To bind it, add a block like the one above with `command = "m4salah.last.last-workspace"`. Pick a key that is not already used in `herdr/config.toml`. Herdr does not report key collisions.

After editing the config, reload it:

```bash
herdr server reload-config
```

### Troubleshooting

- **The key does nothing.** The plugin records focus changes, so it has no history until you have switched tabs or workspaces at least once since installing. Switch once, then try again.
- **Install failed.** Read the build log with `herdr plugin log list`.
- **Key triggers something else.** Check `herdr/config.toml` for a duplicate key. Herdr does not warn about duplicates.

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
