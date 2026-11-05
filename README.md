# dotfiles

My personal configuration for a Sway/Wayland desktop, built around the
**greymon** palette (background `#14171D`, text `#D2D3CE`, accent `#8A9FAD`,
yellow `#B0A883`).

## Credits

This setup is based on and adapted from **[solux-dots](https://github.com/nszmak35/solux-dots)
by [nszmak35](https://github.com/nszmak35)**. Full credit for the original
configuration, theme direction and wallpaper goes to them. If you like this
rice, please check out and star the upstream project:

- https://github.com/nszmak35/solux-dots

Additional credits:

- Rofi layout is a fork of the config from
  [Zproger/bspwm-dotfiles](https://github.com/Zproger/bspwm-dotfiles).
- Rofi font: Libertinus Mono from the
  [Libertinus](https://github.com/alerque/libertinus) family (SIL OFL 1.1).

## Contents

| Path | What it configures |
| --- | --- |
| `sway/` | Sway WM config, status script, floating-border helper |
| `waybar/` | Waybar layout, styles and power-menu script |
| `kitty/` | Kitty terminal, including the greymon theme |
| `rofi/` | Application launcher, layout and greymon colours |
| `cava/` | Audio visualizer config, themes and shaders |
| `fish/` | Fish shell config and prompt |
| `gtk-3.0/`, `gtk-4.0/` | GTK settings and greymon theme CSS |
| `zed/` | Zed editor settings, keymap and tasks |
| `btop/`, `htop/` | System monitor configs |
| `xsettingsd/`, `nwg-look/` | GTK theme export settings |
| `kdeglobals`, `dolphinrc` | KDE/Qt config and colour integration |
| `index.theme`, `README.txt` | greymon GTK theme metadata and palette |

## greymon GTK theme

A dark GTK 3 / GTK 4 theme with square controls, built on the Tre Cime palette
so GTK apps match foot, waybar and the rest of the setup.

- `index.theme` - theme metadata.
- `gtk-3.0/gtk.css` - GTK 3 styling (includes compact list rows for apps such as nwg-look).
- `gtk-4.0/gtk.css` - GTK 4 / libadwaita styling.

Install (for [nwg-look](https://github.com/nwg-piotr/nwg-look)): place this
folder as `greymon` in `/usr/share/themes` (or `~/.local/share/themes`), then
pick **greymon** in nwg-look. See `README.txt` for the palette.

## Secrets

This repository intentionally excludes tokens, browser profiles, caches and
runtime state (see `.gitignore`). Do not commit `~/.config/gh`, `~/.config/opencode`
or similar directories.
