#!/usr/bin/env bash
# Start a Konsole session wrapped by `script(1)` to record all TTY I/O.
# The log stays on the local machine (where this wrapper runs).

set -euo pipefail

# Where to store logs
LOG_DIR="$HOME/.local/share/konsole/audit"
mkdir -p "$LOG_DIR"

# Timestamp + PID to avoid collisions and help ordering sessions
TS="$(date +%F_%H%M%S)"
LOG_FILE="$LOG_DIR/${TS}-$$.log"
TIME_FILE="$LOG_DIR/${TS}-$$.time"  # timing file used by `scriptreplay` (optional)

# `script` flags:
# -q: quiet (less noise)
# -f: flush after each write (safer if the session crashes)
# -a: append (in case the same file gets reused)
# -t: write timing info to stderr (we redirect it to TIME_FILE)
# Without `-c`, `script` launches your default login shell.
exec script -q -f -a -t 2>"$TIME_FILE" "$LOG_FILE"
