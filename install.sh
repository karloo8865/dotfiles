#!/usr/bin/env bash
#
# install.sh - install these dotfiles on an Arch Linux machine.
#
# Default behaviour is to symlink every config entry from this repository into
# ~/.config (so `git pull` keeps the machine up to date). Existing files are
# moved to a timestamped backup instead of being deleted. Use --copy to copy
# the files instead of linking them.
#
# Run `./install.sh --help` for all options.
#
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
THEME_NAME="greymon"
THEME_DIR="$DATA_HOME/themes/$THEME_NAME"
KDE_SCHEME_SRC="$REPO_DIR/kde/Greymon.colors"
KDE_SCHEME_DST="$DATA_HOME/color-schemes/Greymon.colors"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"
STAMP="$(date +%Y%m%d-%H%M%S)"

MODE="symlink"
DRY_RUN=0
INSTALL_DEPS=0
ASSUME_YES=0
WALLPAPER_SRC=""

# Top-level ~/.config entries managed by this repository.
CONFIG_ENTRIES=(
    autostart
    btop
    cava
    dolphinrc
    fish
    gtk-3.0
    gtk-4.0
    htop
    kdeglobals
    kitty
    lxqt
    mimeapps.list
    nwg-look
    pavucontrol.ini
    rofi
    sway
    waybar
    xsettingsd
    zed
)

# Packages needed for the setup to work. Keep this list in sync with README.md.
OFFICIAL_PKGS=(
    # Window manager and desktop
    sway
    swaybg
    swayidle
    swaylock
    waybar
    autotiling-rs
    xorg-xwayland
    xsettingsd
    dbus

    # Terminal and everyday applications
    kitty
    fish
    eza
    rofi
    btop
    cava
    pavucontrol
    dolphin
    zed
    networkmanager
    network-manager-applet
    nwg-look

    # Sway keybind helpers
    grim
    slurp
    brightnessctl
    playerctl

    # Audio (PipeWire + pactl)
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    libpulse
    sound-theme-freedesktop

    # Fonts, icons, cursors
    adwaita-fonts
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    ttf-libertinus
    breeze-icons
    papirus-icon-theme

    # Helper for sway/floating-border.py
    python
)

# Arch User Repository packages.
AUR_PKGS=(
    bibata-cursor-theme
)

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<EOF
Install karloo8865's dotfiles on Arch Linux.

Usage: ./install.sh [OPTIONS]

Options:
  -l, --link              Symlink configs into ~/.config (default)
  -c, --copy              Copy configs instead of symlinking
  -n, --dry-run           Show what would happen without changing anything
  -d, --install-deps      Install missing packages with pacman/yay
  -y, --yes               Do not ask for confirmation when installing packages
  -w, --wallpaper FILE    Install FILE as the Sway wallpaper
  -b, --backup-dir DIR    Where to move existing configs (default: ~/.dotfiles-backup)
  -h, --help              Show this help

Examples:
  ./install.sh                     # link configs, print missing packages
  ./install.sh --install-deps      # link configs and install dependencies
  ./install.sh --copy              # copy configs (no links into the repo)
  ./install.sh --dry-run           # preview every action

Existing configs are never deleted: they are moved to
  ~/.dotfiles-backup/<timestamp>/
EOF
}

run() {
    if (( DRY_RUN )); then
        printf '   [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

same_path() {
    [[ -e "$1" ]] || [[ -L "$1" ]] || return 1
    [[ -e "$2" ]] || [[ -L "$2" ]] || return 1
    [[ "$(readlink -f -- "$1")" == "$(readlink -f -- "$2")" ]]
}

# True when a copied destination already matches the source.
copy_is_current() {
    local src="$1" dst="$2"
    if [[ -L "$src" ]]; then
        [[ -L "$dst" ]] && [[ "$(readlink -- "$src")" == "$(readlink -- "$dst")" ]]
    elif [[ -d "$src" ]]; then
        [[ -d "$dst" && ! -L "$dst" ]] &&
            diff -rq --no-dereference -- "$src" "$dst" >/dev/null 2>&1
    else
        [[ -f "$dst" ]] && cmp -s -- "$src" "$dst"
    fi
}

# Move an existing path into the backup folder.
backup_existing() {
    local target="$1"
    local category="$2"
    local name
    name="$(basename -- "$target")"
    local dest="$BACKUP_ROOT/$STAMP/$category/$name"

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return 0
    fi

    log "Backing up $target -> $dest"
    if (( DRY_RUN )); then
        return 0
    fi
    mkdir -p -- "$(dirname -- "$dest")"
    mv -- "$target" "$dest"
}

install_entry() {
    local name="$1"
    local src="$REPO_DIR/$name"
    local dst="$CONFIG_HOME/$name"

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        warn "Skipping missing entry: $name"
        return 0
    fi

    # Already installed? This also handles running from ~/.config itself,
    # where the source and the destination are the same path.
    if same_path "$dst" "$src"; then
        log "Already in place: $dst"
        return 0
    fi

    if [[ "$MODE" == "copy" ]]; then
        if copy_is_current "$src" "$dst"; then
            log "Already up to date: $dst"
            return 0
        fi
        log "Copying $src -> $dst"
        backup_existing "$dst" "config"
        if (( !DRY_RUN )); then
            mkdir -p -- "$(dirname -- "$dst")"
            cp -a -- "$src" "$dst"
        fi
    else
        log "Linking $dst -> $src"
        backup_existing "$dst" "config"
        if (( !DRY_RUN )); then
            mkdir -p -- "$(dirname -- "$dst")"
            ln -s -- "$src" "$dst"
        fi
    fi
}

theme_is_current() {
    [[ -f "$THEME_DIR/index.theme" ]] &&
    [[ -f "$THEME_DIR/gtk-3.0/gtk.css" ]] &&
    [[ -f "$THEME_DIR/gtk-4.0/gtk.css" ]] &&
    cmp -s -- "$REPO_DIR/index.theme" "$THEME_DIR/index.theme" &&
    cmp -s -- "$REPO_DIR/gtk-3.0/gtk.css" "$THEME_DIR/gtk-3.0/gtk.css" &&
    cmp -s -- "$REPO_DIR/gtk-4.0/gtk.css" "$THEME_DIR/gtk-4.0/gtk.css"
}

install_theme() {
    if [[ ! -f "$REPO_DIR/index.theme" ]]; then
        warn "index.theme not found, skipping GTK theme"
        return 0
    fi

    if theme_is_current; then
        log "GTK theme already installed: $THEME_DIR"
        return 0
    fi

    log "Installing GTK theme: $THEME_DIR"
    if (( DRY_RUN )); then
        return 0
    fi

    if [[ -e "$THEME_DIR" ]]; then
        backup_existing "$THEME_DIR" "themes"
    fi

    mkdir -p -- "$THEME_DIR/gtk-3.0" "$THEME_DIR/gtk-4.0"
    cp -f -- "$REPO_DIR/index.theme" "$THEME_DIR/index.theme"
    cp -f -- "$REPO_DIR/gtk-3.0/gtk.css" "$THEME_DIR/gtk-3.0/gtk.css"
    cp -f -- "$REPO_DIR/gtk-4.0/gtk.css" "$THEME_DIR/gtk-4.0/gtk.css"
}

install_kde_scheme() {
    if [[ ! -f "$KDE_SCHEME_SRC" ]]; then
        warn "kde/Greymon.colors not found, skipping KDE colour scheme"
        return 0
    fi

    if [[ -f "$KDE_SCHEME_DST" ]] && cmp -s -- "$KDE_SCHEME_SRC" "$KDE_SCHEME_DST"; then
        log "KDE colour scheme already installed: $KDE_SCHEME_DST"
        return 0
    fi

    log "Installing KDE colour scheme: $KDE_SCHEME_DST"
    if (( DRY_RUN )); then
        return 0
    fi

    if [[ -e "$KDE_SCHEME_DST" ]]; then
        backup_existing "$KDE_SCHEME_DST" "color-schemes"
    fi

    mkdir -p -- "$(dirname -- "$KDE_SCHEME_DST")"
    cp -f -- "$KDE_SCHEME_SRC" "$KDE_SCHEME_DST"
}

install_wallpaper() {
    [[ -n "$WALLPAPER_SRC" ]] || return 0

    [[ -f "$WALLPAPER_SRC" ]] || die "Wallpaper not found: $WALLPAPER_SRC"

    local ext="${WALLPAPER_SRC##*.}"
    ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
    local dst="$DATA_HOME/wallpapers/dotfiles.$ext"

    log "Installing wallpaper: $dst"
    if (( DRY_RUN )); then
        return 0
    fi

    mkdir -p -- "$DATA_HOME/wallpapers"
    rm -f -- \
        "$DATA_HOME/wallpapers/dotfiles.png" \
        "$DATA_HOME/wallpapers/dotfiles.jpg" \
        "$DATA_HOME/wallpapers/dotfiles.jpeg" \
        "$DATA_HOME/wallpapers/dotfiles.webp"
    cp -f -- "$WALLPAPER_SRC" "$dst"
}

check_deps() {
    if [[ ! -f /etc/arch-release ]]; then
        warn "This script targets Arch Linux (/etc/arch-release not found)."
        return 0
    fi
    command -v pacman >/dev/null 2>&1 || {
        warn "pacman not found; skipping dependency check."
        return 0
    }

    local missing_official=() missing_aur=() pkg

    for pkg in "${OFFICIAL_PKGS[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing_official+=("$pkg")
        fi
    done
    for pkg in "${AUR_PKGS[@]}"; do
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
            missing_aur+=("$pkg")
        fi
    done

    if (( ${#missing_official[@]} == 0 && ${#missing_aur[@]} == 0 )); then
        log "All required packages are installed."
        return 0
    fi

    if (( ${#missing_official[@]} > 0 )); then
        warn "Missing official packages: ${missing_official[*]}"
    fi
    if (( ${#missing_aur[@]} > 0 )); then
        warn "Missing AUR packages: ${missing_aur[*]}"
    fi

    if (( !INSTALL_DEPS )); then
        printf '\nInstall them with:\n'
        if (( ${#missing_official[@]} > 0 )); then
            printf '  sudo pacman -S --needed %s\n' "${missing_official[*]}"
        fi
        if (( ${#missing_aur[@]} > 0 )); then
            printf '  yay -S --needed %s\n' "${missing_aur[*]}"
        fi
        printf '(or re-run this script with --install-deps)\n\n'
        return 0
    fi

    # Install official packages.
    if (( ${#missing_official[@]} > 0 )); then
        local pacman_cmd=(sudo pacman -S --needed)
        if (( ASSUME_YES )); then
            pacman_cmd+=(--noconfirm)
        fi
        run "${pacman_cmd[@]}" "${missing_official[@]}"
    fi

    # Install AUR packages with whichever helper is available.
    if (( ${#missing_aur[@]} > 0 )); then
        local helper=""
        if command -v yay >/dev/null 2>&1; then
            helper="yay"
        elif command -v paru >/dev/null 2>&1; then
            helper="paru"
        fi

        if [[ -n "$helper" ]]; then
            local aur_cmd=("$helper" -S --needed)
            if (( ASSUME_YES )); then
                aur_cmd+=(--noconfirm)
            fi
            run "${aur_cmd[@]}" "${missing_aur[@]}"
        else
            warn "No AUR helper found. Install these manually: ${missing_aur[*]}"
            printf '  (bootstrap yay/paru, then: yay -S --needed %s)\n' "${missing_aur[*]}"
        fi
    fi
}

# --- argument parsing -------------------------------------------------------

while (( $# > 0 )); do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -l|--link)
            MODE="symlink"
            ;;
        -c|--copy)
            MODE="copy"
            ;;
        -n|--dry-run)
            DRY_RUN=1
            ;;
        -d|--install-deps)
            INSTALL_DEPS=1
            ;;
        -y|--yes)
            ASSUME_YES=1
            ;;
        -w|--wallpaper)
            shift
            [[ $# -gt 0 ]] || die "--wallpaper needs a file path"
            WALLPAPER_SRC="$1"
            ;;
        --wallpaper=*)
            WALLPAPER_SRC="${1#*=}"
            ;;
        -b|--backup-dir)
            shift
            [[ $# -gt 0 ]] || die "--backup-dir needs a path"
            BACKUP_ROOT="$1"
            ;;
        --backup-dir=*)
            BACKUP_ROOT="${1#*=}"
            ;;
        *)
            die "Unknown option: $1 (try --help)"
            ;;
    esac
    shift
done

# --- main -------------------------------------------------------------------

if (( EUID == 0 )); then
    die "Do not run this script as root. Run it as your normal user (sudo is used only for packages)."
fi
[[ -n "${HOME:-}" ]] || die "HOME is not set."

if [[ ! -d "$REPO_DIR/sway" || ! -d "$REPO_DIR/waybar" ]]; then
    die "Run this script from the root of the dotfiles repository."
fi

log "Repository:  $REPO_DIR"
log "Config dir:  $CONFIG_HOME"
if (( DRY_RUN )); then
    log "Mode:        $MODE (dry-run)"
else
    log "Mode:        $MODE"
fi

if (( DRY_RUN )); then
    log "Dry run: no files will be changed."
fi

check_deps

for entry in "${CONFIG_ENTRIES[@]}"; do
    install_entry "$entry"
done

install_theme
install_kde_scheme
install_wallpaper

cat <<EOF

Done.

Next steps:
  1. Make fish your login shell (optional):
       chsh -s /usr/bin/fish
  2. Log out and back in, then start Sway from your display manager or TTY:
       sway
  3. If the greymon theme is not active, select it in nwg-look.
  4. If you did not pass --wallpaper, the Sway wallpaper falls back to
       ~/Downloads/ign_unsplash29.png and then the stock Sway background.
     Install one with:
       ./install.sh --wallpaper /path/to/image.png

Backups of anything replaced are in $BACKUP_ROOT/$STAMP/
EOF
