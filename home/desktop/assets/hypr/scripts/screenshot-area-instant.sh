#!/usr/bin/env bash

set -euo pipefail

# Prevent multiple instances from stacking
exec 9>/tmp/screenshot-area.lock
flock -n 9 || exit 0
trap 'rm -f /tmp/screenshot-area.lock' EXIT

screens_dir="${HOME}/Pictures/Screenshots"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
outfile="${screens_dir}/screenshot-${timestamp}.png"

mkdir -p "${screens_dir}"

geometry="$(slurp)"
[ -n "${geometry}" ]

grim -g "${geometry}" "${outfile}"
wl-copy < "${outfile}"
dms -c /home/imperaluna/.config/quickshell/dms notify "Screenshot saved" "$(basename "${outfile}") copied to clipboard" --file "${outfile}" --icon "${outfile}" --app "Screenshot" --timeout 3500
