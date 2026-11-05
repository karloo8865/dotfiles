#!/bin/sh
# Simple power menu for Waybar (uses rofi as a dmenu).

chosen=$(printf 'Lock\nLogout\nReboot\nShutdown' | rofi -dmenu -p 'Power')

case "$chosen" in
    Lock)     swaylock -f ;;
    Logout)   swaymsg exit ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
