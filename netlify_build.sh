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
flutter build web --release --no-wasm-dry-run

# Flutter 3.41 can still inject an empty {} into buildConfig.builds without --no-wasm-dry-run;
# if present it breaks FlutterLoader and the app never starts.
if [ -f build/web/flutter_bootstrap.js ]; then
  sed -i 's/"mainJsPath":"main.dart.js"},{}]/"mainJsPath":"main.dart.js"}]/' build/web/flutter_bootstrap.js
  # Service worker is deprecated; skip registration so stale SW caches cannot block startup.
  perl -0777 -i -pe 's/_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[^}]*\}\s*\}\);/_flutter.loader.load();/s' build/web/flutter_bootstrap.js
fi
