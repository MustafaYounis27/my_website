#!/usr/bin/env bash
set -euo pipefail

BASE_HREF="${BASE_HREF:-/}"

# Local/CI: skip when Flutter is already on PATH (e.g. GitHub Actions flutter-action).
if [ "${SKIP_FLUTTER_INSTALL:-}" != "1" ]; then
  if [ ! -d "$HOME/flutter" ]; then
    git clone --quiet https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
  fi
  export PATH="$HOME/flutter/bin:$PATH"
  flutter config --enable-web
fi

flutter --version
flutter pub get
# --wasm emits a WebAssembly build plus the JS build; the loader picks wasm when
# the browser supports it and falls back to JS otherwise.
flutter build web --release --wasm --no-web-resources-cdn --base-href="$BASE_HREF"

# Older Flutter versions could inject an empty {} into buildConfig.builds;
# if present it breaks FlutterLoader and the app never starts.
if [ -f build/web/flutter_bootstrap.js ]; then
  perl -0777 -i -pe '
    s/"mainJsPath":"main\.dart\.js"},\{\}]/"mainJsPath":"main.dart.js"}]/g;
    s/_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[^}]*\}\s*\}\);/_flutter.loader.load({config: {canvasKitBaseUrl: "canvaskit"}});/s;
    s/_flutter\.loader\.load\(\);/_flutter.loader.load({config: {canvasKitBaseUrl: "canvaskit"}});/s;
  ' build/web/flutter_bootstrap.js
fi
