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

## Installation (Arch Linux)

The repository ships with `install.sh`, which installs every config into
`~/.config` and sets up the greymon GTK theme.

```bash
git clone https://github.com/karloo8865/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Optional but recommended: preview what will happen first.
./install.sh --dry-run

# Install missing packages and link the configs.
./install.sh --install-deps
```

By default the script **symlinks** each config entry, so `git pull` in
`~/dotfiles` immediately updates the live configuration. Anything that already
exists in `~/.config` is moved to `~/.dotfiles-backup/<timestamp>/` instead of
being deleted. Re-running the script is safe.

If you would rather have an independent copy (no links back into the repo), use:

```bash
./install.sh --copy --install-deps
```

### Script options

| Option | Meaning |
| --- | --- |
| `-l`, `--link` | Symlink configs into `~/.config` (default) |
| `-c`, `--copy` | Copy configs instead of symlinking |
| `-n`, `--dry-run` | Print every action without changing anything |
| `-d`, `--install-deps` | Install missing packages with `pacman`/`yay` |
| `-y`, `--yes` | Pass `--noconfirm` to package managers |
| `-w`, `--wallpaper FILE` | Install `FILE` as the Sway wallpaper |
| `-b`, `--backup-dir DIR` | Backup directory (default `~/.dotfiles-backup`) |
| `-h`, `--help` | Show help |

Examples:

```bash
./install.sh                                  # link configs, list missing packages
./install.sh --install-deps                   # link configs + install dependencies
./install.sh --copy                           # copy configs
./install.sh --wallpaper ~/Pictures/wall.png  # link configs + set wallpaper
```

### After installing

1. Make fish your login shell (optional):
   ```bash
   chsh -s /usr/bin/fish
   ```
2. Log out and back in, then start Sway from your display manager or a TTY:
   ```bash
   sway
   ```
3. If GTK apps are not using the greymon theme, open **nwg-look** and select
   **greymon**. The script installs it to `~/.local/share/themes/greymon`.
4. The wallpaper is chosen by `sway/wallpaper.sh`. It uses
   `~/.local/share/wallpapers/dotfiles.*` if present, then
   `~/.config/sway/wallpaper.*`, then `~/Downloads/ign_unsplash29.png`, then the
   stock Sway background. To install your own, run
   `./install.sh --wallpaper /path/to/image.png`.

## Dependencies

The configs are for **Arch Linux** with **Sway/Wayland**. The installer targets
the official repositories plus the AUR; run `./install.sh --install-deps` to
install everything automatically.

### Official repositories

```bash
sudo pacman -S --needed \
  sway swaybg swayidle swaylock waybar autotiling-rs xorg-xwayland \
  xsettingsd dbus \
  kitty fish eza rofi btop cava pavucontrol dolphin zed \
  networkmanager network-manager-applet nwg-look \
  grim slurp brightnessctl playerctl \
  pipewire pipewire-pulse pipewire-alsa wireplumber libpulse \
  sound-theme-freedesktop \
  adwaita-fonts ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-libertinus \
  breeze-icons papirus-icon-theme \
  python
```

What each group is for:

| Group | Packages | Used by |
| --- | --- | --- |
| Sway desktop | `sway`, `swaybg`, `swayidle`, `swaylock`, `waybar`, `autotiling-rs`, `xorg-xwayland` | Window manager, wallpaper, idle/lock, status bar, tiling |
| Settings | `xsettingsd`, `dbus` | GTK/Xft settings for Xwayland apps |
| Terminal & apps | `kitty`, `fish`, `eza`, `rofi`, `btop`, `cava`, `pavucontrol`, `dolphin`, `zed` | Terminal, shell, launcher, monitors, audio mixer, file manager, editor |
| Network | `networkmanager`, `network-manager-applet` | `network` Waybar module and `nm-connection-editor` |
| Theme tooling | `nwg-look` | GTK theme/icon/cursor selection |
| Sway keybinds | `grim`, `slurp`, `brightnessctl`, `playerctl` | Screenshots, volume/brightness/media keys |
| Audio | `pipewire`, `pipewire-pulse`, `pipewire-alsa`, `wireplumber`, `libpulse`, `sound-theme-freedesktop` | PipeWire stack, `pactl` and GTK sound theme |
| Fonts & icons | `adwaita-fonts`, `ttf-jetbrains-mono`, `ttf-jetbrains-mono-nerd`, `ttf-libertinus`, `breeze-icons`, `papirus-icon-theme` | GTK/Zed UI, Kitty, Waybar, Rofi and icons |
| Scripts | `python` | `sway/floating-border.py` |

### AUR

```bash
yay -S --needed bibata-cursor-theme
```

`bibata-cursor-theme` provides the `Bibata-Modern-Ice` cursor used by
`gtk-3.0/settings.ini` and `xsettingsd`. Install `yay` or `paru` first; the
installer uses whichever AUR helper it finds.

### Optional

| Package | Why |
| --- | --- |
| `helium-browser-bin` (AUR) | Default browser in `mimeapps.list` |
| `localsend-bin` (AUR) | Target of `autostart/localsend_app.desktop` |
| `libreoffice-still` | LibreOffice profile (not tracked in this repo) |
| `noto-fonts`, `noto-fonts-cjk` | Fallback fonts for CJK and missing glyphs |
| `sddm` or `lightdm` | Graphical login; start Sway from a display manager |
| `polkit` + a polkit agent | Graphical privilege prompts for desktop apps |

### Updating

```bash
cd ~/dotfiles
git pull
```

With the default symlink mode no reinstall is needed. If you used `--copy`,
re-run `./install.sh --copy` after pulling.

## Contents

| Path | What it configures |
| --- | --- |
| `install.sh` | Arch Linux installer for all configs and the GTK theme |
| `sway/` | Sway WM config, wallpaper helper, status script, floating-border helper |
| `waybar/` | Waybar layout, styles and power-menu script |
| `kitty/` | Kitty terminal, including the greymon theme |
| `rofi/` | Application launcher, layout and greymon colours |
| `cava/` | Audio visualizer config, themes and shaders |
| `fish/` | Fish shell config, prompt and conf.d snippets |
| `gtk-3.0/`, `gtk-4.0/` | GTK settings and greymon theme CSS |
| `zed/` | Zed editor settings, keymap, tasks and greymon theme |
| `btop/`, `htop/` | System monitor configs |
| `xsettingsd/`, `nwg-look/` | GTK theme export settings |
| `kdeglobals`, `dolphinrc`, `kde/` | KDE/Qt config, colour scheme and integration |
| `lxqt/`, `autostart/` | Small desktop startup entries |
| `index.theme`, `README.txt` | greymon GTK theme metadata and palette |

## greymon GTK theme

A dark GTK 3 / GTK 4 theme with square controls, built on the Tre Cime palette
so GTK apps match kitty, waybar and the rest of the setup.

- `index.theme` - theme metadata.
- `gtk-3.0/gtk.css` - GTK 3 styling (includes compact list rows for apps such as nwg-look).
- `gtk-4.0/gtk.css` - GTK 4 / libadwaita styling.

`install.sh` copies these files to `~/.local/share/themes/greymon`, which is
where [nwg-look](https://github.com/nwg-piotr/nwg-look) expects user themes.
It also installs `kde/Greymon.colors` to `~/.local/share/color-schemes` so
Dolphin and other Qt/KDE apps use the same palette. Pick **greymon** in
nwg-look. See `README.txt` for the palette.

## Secrets

This repository intentionally excludes tokens, browser profiles, caches and
runtime state (see `.gitignore`). Do not commit `~/.config/gh`, `~/.config/opencode`
or similar directories.
