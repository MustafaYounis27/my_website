#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (cached between builds if HOME persists)
if [ ! -d "$HOME/flutter" ]; then
  git clone --quiet https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

# Ensure web artifacts are available (clone does not include them by default)
flutter config --enable-web
flutter precache --web

# Dependencies and build
# --web-renderer html: fewer CI memory issues than CanvasKit, smaller output
flutter pub get
flutter build web --release --web-renderer html
