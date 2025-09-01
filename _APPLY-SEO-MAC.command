#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./apply-seo-pack.sh || true
exec /bin/bash ./apply-seo-pack.sh
