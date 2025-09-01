#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-post-page.sh || true
exec /bin/bash ./apply-post-page.sh
