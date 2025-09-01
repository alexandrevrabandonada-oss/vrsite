#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-home-feed.sh || true
exec /bin/bash ./apply-home-feed.sh
