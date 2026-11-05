#!/usr/bin/env python3
"""Keep a Sway pixel border on floating windows.

When a window is made floating (keybind, mouse drag, or a script), Sway
switches it to client-side decorations, i.e. `border: csd`. With `csd` Sway
draws no border of its own, so the configured client.focused border color
disappears. `default_floating_border` does not help here because it only
applies to windows that are *spawned* floating.

This listens to Sway's window events and forces `border pixel 2` on every
container that becomes floating, so floating windows keep the same visible
border as tiled ones.

Sway sends the `floating` event *before* the switch to `csd`, so the border
is applied twice: once immediately and once shortly after.
"""

import fcntl
import json
import os
import subprocess
import sys
import threading

BORDER_WIDTH = 2

# Delay (seconds) after the floating event, once Sway has switched to csd.
RECHECK_DELAY = 0.25


def take_lock() -> "object | None":
    """Ensure only one instance runs; return the lock file (keep it open)."""
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
    path = os.path.join(runtime_dir, "sway-floating-border.lock")
    handle = open(path, "w")
    try:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        handle.close()
        return None
    return handle


def enforce_border(container_id: int) -> None:
    subprocess.run(
        [
            "swaymsg",
            f"[con_id={container_id}]",
            "border",
            "pixel",
            str(BORDER_WIDTH),
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )


def main() -> int:
    proc = subprocess.Popen(
        ["swaymsg", "--type", "subscribe", "--monitor", '["window"]'],
        stdout=subprocess.PIPE,
        text=True,
    )
    assert proc.stdout is not None

    for line in proc.stdout:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if event.get("change") != "floating":
            continue

        con = event.get("container") or {}
        if con.get("type") != "floating_con":
            continue

        con_id = con["id"]

        # The event may still report the old (tiled) border, so only skip the
        # immediate call when it is already correct. The delayed call always
        # runs, because Sway switches to `csd` after sending the event.
        if not (
            con.get("border") == "pixel"
            and con.get("current_border_width") == BORDER_WIDTH
        ):
            enforce_border(con_id)

        threading.Timer(RECHECK_DELAY, enforce_border, args=(con_id,)).start()

    return 0


if __name__ == "__main__":
    lock = take_lock()
    if lock is None:
        sys.exit(0)
    try:
        sys.exit(main())
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(0)
