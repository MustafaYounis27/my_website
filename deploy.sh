#!/usr/bin/env bash
set -euo pipefail

# Build Flutter web (root base href for Firebase Hosting).
export BASE_HREF="${BASE_HREF:-/}"
bash "$(dirname "$0")/netlify_build.sh"

echo "Deploying to Firebase Hosting (my-website-c0f57)..."
firebase deploy --only hosting --project my-website-c0f57
