#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$root/.local/bin:$PATH"
for tool in docker kind kubectl helm git python3; do
  command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done
docker info --format '{{.ServerVersion}}'
kind version
kubectl version --client
helm version --short
git --version
python3 --version
echo 'Environment preflight passed; cluster acceptance still requires cluster creation.'
