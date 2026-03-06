#!/usr/bin/env bash
set -euo pipefail

# Use a writable pub cache inside the repo (/opt/buildhome is read-only on Netlify)
export PUB_CACHE="${PWD}/.pub-cache"
mkdir -p "$PUB_CACHE"

# Install Flutter SDK (cached between builds if HOME persists)
if [ ! -d "$HOME/flutter" ]; then
  git clone --quiet https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

# Ensure web artifacts are downloaded
flutter config --enable-web
flutter precache --web

# Dependencies and build
flutter pub get
flutter build web --release
