#!/usr/bin/env bash
# Symlink the configs in this repo into $HOME (mostly ~/.config), backing up any existing files.
set -euo pipefail

command -v jq >/dev/null || { echo "error: jq is required to merge settings.json" >&2; exit 1; }

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
link shell/aliases.sh .config/shell/aliases.sh
link claude/keybindings.json .claude/keybindings.json

# Source the shared aliases from ~/.bashrc once. Re-running does not add the line twice.
# shellcheck disable=SC2016 # the line is written literally into ~/.bashrc, so $HOME must not expand here
source_line='[ -f "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"'
if ! grep -qF "$source_line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# dotfiles aliases\n%s\n' "$source_line" >> "$HOME/.bashrc"
  echo "add     $source_line -> $HOME/.bashrc"
else
  echo "ok      $HOME/.bashrc already sources aliases"
fi

# settings.json also holds machine-specific entries, so merge only the shared keys into it.
settings="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$settings")"
[ -f "$settings" ] || echo '{}' > "$settings"
if ! jq -s '.[0] * .[1]' "$settings" "$repo/claude/settings.shared.json" > "$settings.tmp"; then
  rm -f "$settings.tmp"
  echo "error: could not merge $settings (invalid JSON?)" >&2
  exit 1
fi
if cmp -s "$settings.tmp" "$settings"; then
  rm "$settings.tmp"
  echo "ok      $settings"
else
  mkdir -p "$backup/.claude"
  cp -L "$settings" "$backup/.claude/settings.json"
  # Write through the path so a symlinked settings.json stays a symlink.
  cat "$settings.tmp" > "$settings" && rm "$settings.tmp"
  echo "merged  $settings <- claude/settings.shared.json (backup in $backup/.claude)"
fi
