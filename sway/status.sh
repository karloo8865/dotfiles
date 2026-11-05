#!/bin/sh
# Status line for swaybar. Prints one line every second.
#
# Layout: [date/time centered]  ...  [volume | memory | keyboard layout]
# swaybar right-aligns the status area, so the date is pushed to the middle
# with trailing spaces based on the output width and the actual font width.

# Must match `font` in the bar block of ~/.config/sway/config.
BAR_FONT="monospace 10"

# Measure the real width of one character, in pixels, at 96 dpi.
# Falls back to 7 if pango-view is unavailable.
CW=7
if command -v pango-view >/dev/null 2>&1; then
    tmp="${XDG_RUNTIME_DIR:-/tmp}/swaybar-char-width.png"
    if pango-view --no-display --dpi=96 --font="$BAR_FONT" --margin=0 \
            -t "MMMMMMMMMM" -o "$tmp" 2>/dev/null; then
        measured=$(od -An -tu1 -j16 -N4 "$tmp" 2>/dev/null \
            | awk '{print ($1 * 16777216 + $2 * 65536 + $3 * 256 + $4) / 10}')
        [ -n "$measured" ] && CW=$measured
    fi
    rm -f "$tmp"
fi

# Width of the first output in pixels (single-monitor assumption).
# Computed once; reload the config if you change resolution.
OUT_W="$(swaymsg -t get_outputs -r 2>/dev/null \
    | awk '/"rect": \{/ {found=1} found && /"width":/ {gsub(/[^0-9]/, ""); print; exit}')"
[ -n "$OUT_W" ] || OUT_W=1920

while true; do
    # Volume (shows MUTED when the default sink is muted)
    if [ "$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
        vol="MUTED"
    else
        vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk 'NR==1 {print $5}')"
    fi

    # Memory usage
    mem="$(free -h | awk '/^Mem:/ {print $3"/"$2}')"

    # Keyboard layout (e.g. English (US))
    layout="$(swaymsg -t get_inputs -r 2>/dev/null \
        | grep -m1 '"xkb_active_layout_name"' \
        | sed 's/.*: "\(.*\)".*/\1/')"

    # Right-hand modules
    modules="Vol ${vol:-?}  |  Mem ${mem:-?}  |  Kbd ${layout:-?}"

    # Date/time text and its width in characters
    date_text="$(date +'%a %d %b  %H:%M:%S')"
    date_len=${#date_text}

    # Compute how many spaces are needed so the date's center lands on the
    # middle of the screen. 3px is swaybar's default status_edge_padding.
    pad=$(awk -v W="$OUT_W" -v cw="$CW" -v dl="$date_len" -v ml="${#modules}" \
        'BEGIN { p = (W / 2 - 3 - dl * cw / 2 - ml * cw) / cw;
                 c = int(p + 0.5); if (c < 1) c = 1; print c }')

    # #cdd6f4 date/time, colored with pango markup
    printf '<span color="#cdd6f4">%s</span>%*s%s\n' \
        "$date_text" "$pad" "" "$modules"

    sleep 1
done
