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

## Commit signing

`main` requires signed commits, so every machine that pushes needs its own signing key registered on GitHub. Run this once per machine:

```bash
ssh-keygen -t ed25519 -C "git-signing $(hostname)" -f ~/.ssh/git_signing_ed25519
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/git_signing_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Then add the public key at https://github.com/settings/ssh/new with the key type "Signing Key", or run `gh auth refresh -s admin:ssh_signing_key` followed by `gh ssh-key add ~/.ssh/git_signing_ed25519.pub --type signing --title "$(hostname)"`.

Check with `git commit --allow-empty -m test && git log --show-signature -1`, then drop the test commit. Revoke a lost machine by deleting its key in the same settings page.

## Server access to a repo

A server such as cb-lab that sends commits to GitHub needs its own deploy key per repo, because a deploy key works for one repo only. The signing key above is shared by every repo on that machine. Replace `<repo>` below.

```bash
ssh-keygen -t ed25519 -N "" -C "$(hostname) deploy <repo>" -f ~/.ssh/github_<repo>_ed25519
printf '\nHost github-<repo>\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/github_<repo>_ed25519\n  IdentitiesOnly yes\n' >> ~/.ssh/config
gh api meta --jq '.ssh_keys[]' | sed 's/^/github.com /' >> ~/.ssh/known_hosts
git remote set-url origin git@github-<repo>:cricri777/<repo>.git
```

Then add `~/.ssh/github_<repo>_ed25519.pub` at https://github.com/cricri777/<repo>/settings/keys/new with "Allow write access" ticked. Test with `ssh -T github-<repo>`. Run `gh api meta` on a machine with `gh`, since cb-lab has none.

## Branch rule on every repo

Each public repo of mine has the ruleset `protect-main` on its default branch: no deletion, no force update, signed commits only. To add it to a new repo, run `scripts/protect-repo.sh <repo>`, which is safe to rerun. Private repos need GitHub Pro for rulesets, and forks are left alone.

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
| `claude/skills/<name>/` | `~/.claude/skills/<name>`, for example `/cricri [--auto] <task>` and `/cricri-ui-prototype`, see [ui-prototype.md](ui-prototype.md) |
| `claude/settings.shared.json` | Merged into `~/.claude/settings.json` with `jq` |
