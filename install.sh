#!/usr/bin/env bash
# Symlink the configs in this repo into ~/.config, backing up any existing files.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
config="$HOME/.config"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$repo/$1" dest="$config/$2"
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

link nvim nvim
link lazygit lazygit
# Herdr keeps runtime files (sockets, logs, sessions) in its config dir, so link only the config file.
link herdr/config.toml herdr/config.toml
