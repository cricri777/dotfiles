# Install

## Packages

Install the tools first:

```bash
# Arch / Omarchy
sudo pacman -S neovim lazygit git jq

# Debian / Ubuntu / WSL (lazygit may be outdated in apt; see https://github.com/jesseduffield/lazygit#installation)
sudo apt install neovim git jq
```

- Herdr: see https://herdr.dev.
- Nerd Font: install one (for example JetBrainsMono Nerd Font) and select it in your terminal.

## Run the install script

```bash
git clone https://github.com/cricri777/dotfiles.git ~/git/perso/dotfiles
~/git/perso/dotfiles/install.sh
```

The script symlinks each config into `~/.config` (Claude Code keybindings go to `~/.claude`, and the shared voice and hooks settings are merged into `~/.claude/settings.json`). Existing files are moved to `~/.config-backup-<timestamp>` first, so re-running it is safe.

It also adds one line to `~/.bashrc` that sources the shared aliases (`n` = nvim, `lg` = lazygit). Running the script again does not add the line twice.

Then install the herdr plugins listed in [`herdr/plugins.txt`](../herdr/plugins.txt). Plugins may need `cargo` to build:

```bash
grep -v '^#' herdr/plugins.txt | grep -v '^$' | while read -r plugin; do herdr plugin install -y "$plugin"; done
```

For the Herdr plugin and its keybindings, see [herdr.md](herdr.md).

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
rm ~/.config/nvim && mv ~/.config-backup-<timestamp>/.config/nvim ~/.config/nvim
```

## Layout

| Path | Linked to |
| --- | --- |
| `nvim/` | `~/.config/nvim` |
| `lazygit/` | `~/.config/lazygit` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `herdr/plugins.txt` | Herdr plugins to install (not linked) |
| `shell/aliases.sh` | `~/.config/shell/aliases.sh`, sourced once from `~/.bashrc` |
| `claude/keybindings.json` | `~/.claude/keybindings.json` |
| `claude/AGENTS.md`, `claude/CLAUDE.md` | `~/.claude/AGENTS.md`, `~/.claude/CLAUDE.md` |
| `claude/hooks/cricri-guard.sh` | `~/.claude/hooks/cricri-guard.sh`, blocks force pushes and pushes that fail `scripts/verify.sh` |
| `claude/skills/<name>/` | `~/.claude/skills/<name>`, for example `/cricri [--auto] <task>` |
| `claude/settings.shared.json` | Merged into `~/.claude/settings.json` with `jq` |
