#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.38.3"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/${FLUTTER_VERSION}/${FLUTTER_ARCHIVE}"

# Netlify provides a persistent cache directory across builds
CACHE_DIR="${NETLIFY_CACHE_DIR:-$HOME/.cache}"
FLUTTER_DIR="${CACHE_DIR}/flutter_${FLUTTER_VERSION}"

export PUB_CACHE="${CACHE_DIR}/.pub-cache"
mkdir -p "$PUB_CACHE"

echo "==> Flutter ${FLUTTER_VERSION} build starting"

if [ -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "==> Using cached Flutter SDK"
else
  echo "==> Downloading Flutter ${FLUTTER_VERSION}..."
  rm -rf "${FLUTTER_DIR}"
  mkdir -p "${FLUTTER_DIR}"

  MAX_RETRIES=3
  for i in $(seq 1 $MAX_RETRIES); do
    if curl -fSL --retry 3 --retry-delay 5 -o "/tmp/${FLUTTER_ARCHIVE}" "$FLUTTER_URL"; then
      break
    fi
    echo "==> Download attempt $i/$MAX_RETRIES failed, retrying..."
    [ "$i" -eq "$MAX_RETRIES" ] && { echo "ERROR: Failed to download Flutter SDK"; exit 1; }
    sleep 5
  done

  echo "==> Extracting Flutter SDK..."
  tar xf "/tmp/${FLUTTER_ARCHIVE}" -C "${FLUTTER_DIR}" --strip-components=1
  rm -f "/tmp/${FLUTTER_ARCHIVE}"
fi

export PATH="${FLUTTER_DIR}/bin:${FLUTTER_DIR}/bin/cache/dart-sdk/bin:$PATH"

flutter config --enable-web --no-analytics 2>/dev/null || true
flutter precache --web

echo "==> Running flutter pub get..."
flutter pub get

echo "==> Building Flutter web (release)..."
flutter build web --release --no-tree-shake-icons

echo "==> Build complete! Output in build/web/"
ls -la build/web/
