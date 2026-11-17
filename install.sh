#!/usr/bin/env bash
# Symlink the configs in this repo into $HOME (mostly ~/.config), backing up any existing files.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$repo/$1" dest="$HOME/$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok      $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$backup/$(dirname "$2")"
    mv "$dest" "$backup/$2"
    echo "backup  $dest -> $backup/$2"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "link    $dest -> $src"
}

link nvim .config/nvim
link lazygit .config/lazygit
# Herdr keeps runtime files (sockets, logs, sessions) in its config dir, so link only the config file.
link herdr/config.toml .config/herdr/config.toml
link claude/keybindings.json .claude/keybindings.json

# settings.json also holds machine-specific entries, so merge only the shared keys into it.
settings="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$settings")"
[ -f "$settings" ] || echo '{}' > "$settings"
jq -s '.[0] * .[1]' "$settings" "$repo/claude/settings.shared.json" > "$settings.tmp" && mv "$settings.tmp" "$settings"
echo "merged  $settings <- claude/settings.shared.json"
