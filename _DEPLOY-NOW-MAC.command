#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
chmod +x ./deploy-now.sh || true
exec /bin/bash ./deploy-now.sh
