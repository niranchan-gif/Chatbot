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

if [[ "${NETLIFY:-false}" == "true" && -z "${API_BASE_URL:-}" ]]; then
  echo "API_BASE_URL must be configured in Netlify before deploying StudyMate."
  echo "Example: https://your-studyMate-backend.example.com"
  exit 1
fi

build_args=(--release)
if [[ -n "${API_BASE_URL:-}" ]]; then
  build_args+=("--dart-define=API_BASE_URL=${API_BASE_URL}")
fi

flutter build web "${build_args[@]}"