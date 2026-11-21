# dotfiles

Personal configs for nvim, lazygit, herdr and Claude Code (rules, hooks, the `/cricri` skill), shared across laptops.

## Supported platforms

| Platform | Status |
| --- | --- |
| Linux (Omarchy / Arch) | Supported |
| Windows (WSL) | Supported, clone under `~/` |
| Native Windows (PowerShell) | Not supported |

## Quick start

```bash
git clone https://github.com/cricri777/dotfiles.git ~/git/perso/dotfiles
~/git/perso/dotfiles/install.sh
```

The script symlinks each config into `~/.config`. See the full guide in [docs/install.md](docs/install.md).

## Documentation

- [Install, verify and restore](docs/install.md)
- [Herdr: plugins and keybindings](docs/herdr.md)
- [Contributing](CONTRIBUTING.md)

## License

[MIT](LICENSE)
