#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (cached between builds if HOME persists)
if [ ! -d "$HOME/flutter" ]; then
  git clone --quiet https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

# Enable web, fetch deps, and build
flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
