#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-instagram-post-ssr-patch.sh || true
exec /bin/bash ./apply-instagram-post-ssr-patch.sh
