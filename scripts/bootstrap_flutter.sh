#!/bin/sh
set -eu

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK not found. Please install Flutter first.' >&2
  exit 1
fi

flutter create . \
  --platforms=android,windows,macos,linux \
  --project-name=three_dgs_real \
  --org=com.real.threedgs

echo 'Flutter platform scaffolding generated successfully.'
