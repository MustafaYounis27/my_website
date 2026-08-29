#!/usr/bin/env bash
set -euo pipefail

# Build Flutter web (root base href for Firebase Hosting).
export BASE_HREF="${BASE_HREF:-/}"
bash "$(dirname "$0")/netlify_build.sh"

echo "Deploying to https://mustafa-younis-portfolio.web.app ..."
firebase deploy --only hosting:mustafa-younis-portfolio --project my-website-c0f57
