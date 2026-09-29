#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.5}"
FLUTTER_HOME="${NETLIFY_CACHE_DIR:-$HOME/.cache}/flutter-${FLUTTER_VERSION}"

if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  archive="$(mktemp)"
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o "$archive"
  mkdir -p "$FLUTTER_HOME"
  tar -xJf "$archive" --strip-components=1 -C "$FLUTTER_HOME"
  rm -f "$archive"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"
flutter config --enable-web
flutter pub get
flutter build web --release