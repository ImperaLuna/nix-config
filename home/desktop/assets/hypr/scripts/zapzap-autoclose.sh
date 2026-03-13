#!/usr/bin/env bash

set -eu

log_file="/tmp/zapzap-autoclose.log"
echo "--- $(date --iso-8601=seconds) ---" >> "$log_file"
exec >> "$log_file" 2>&1

echo "starting zapzap helper"
zapzap &
echo "launched zapzap"

for attempt in $(seq 1 60); do
  addr="$(
    hyprctl clients | awk '
      BEGIN {
        RS = ""
        FS = "\n"
      }
      {
        addr = ""
        class = ""

        for (i = 1; i <= NF; i++) {
          if ($i ~ /^Window /) {
            split($i, parts, " ")
            addr = parts[2]
          }

          if ($i ~ /^[[:space:]]*class: /) {
            class = $i
            sub(/^[[:space:]]*class: /, "", class)
          }
        }

        if (class == "ZapZap") {
          print addr
          exit
        }
      }
    ' | head -n1
  )"

  echo "attempt=$attempt addr=${addr:-<none>}"

  if [ -n "$addr" ]; then
    case "$addr" in
      0x*) ;;
      *) addr="0x$addr" ;;
    esac

    echo "window detected, waiting 1 second before close"
    sleep 1
    echo "closing address=$addr"
    hyprctl dispatch closewindow address:"$addr"
    echo "close command sent"
    exit 0
  fi

  sleep 1
done

echo "timed out waiting for ZapZap window"
exit 0
