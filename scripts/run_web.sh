#!/usr/bin/env bash
# Flutter looks for `google-chrome`; on Arch/Garuda the binary is often google-chrome-stable.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${CHROME_EXECUTABLE:-}" ]]; then
  for candidate in \
    /usr/bin/google-chrome-stable \
    /usr/bin/google-chrome \
    /usr/bin/chromium \
    /usr/bin/brave; do
    if [[ -x "$candidate" ]]; then
      export CHROME_EXECUTABLE="$candidate"
      break
    fi
  done
fi

if [[ -z "${CHROME_EXECUTABLE:-}" ]]; then
  echo "No Chrome/Chromium binary found. Install Google Chrome or set CHROME_EXECUTABLE." >&2
  exit 1
fi

fvm flutter run -d chrome "$@"
