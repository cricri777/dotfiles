# Herdr

Herdr config lives in [`herdr/config.toml`](../herdr/config.toml). The plugins to install are listed in [`herdr/plugins.txt`](../herdr/plugins.txt).

## Plugin: last tab and last workspace

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

The loop in [install.md](install.md#run-the-install-script) already installs it. To install only this plugin:

```bash
herdr plugin install m4salah/herdr-plugin-last
```

The plugin is pinned to a commit when installed. To pull a newer version, run `herdr plugin update m4salah.last`.

### Keybindings

`herdr/config.toml` binds last-tab to `prefix+tab`:

```toml
[[keys.command]]
key = "prefix+tab"
type = "plugin_action"
command = "m4salah.last.last-tab"
description = "toggle to last focused tab"
```

- `prefix+t` is bound to `last_pane` in this config (`last_pane = "prefix+t"`), not to last-tab. `prefix+;` is no longer used.
- `last-workspace` is not bound. To bind it, add a block like the one above with `command = "m4salah.last.last-workspace"`. Pick a key that is not already used in `herdr/config.toml`. Herdr does not report key collisions.

After editing the config, reload it:

```bash
herdr server reload-config
```

## Troubleshooting

- **The key does nothing.** The plugin records focus changes, so it has no history until you have switched tabs or workspaces at least once since installing. Switch once, then try again.
- **Install failed.** Read the build log with `herdr plugin log list`.
- **Key triggers something else.** Check `herdr/config.toml` for a duplicate key. Herdr does not warn about duplicates.
