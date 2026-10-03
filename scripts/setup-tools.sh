#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version=v0.33.0
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo 'Unsupported architecture' >&2; exit 1 ;;
esac
mkdir -p "$root/.local/bin"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
asset="kind-linux-$arch"
url="https://github.com/kubernetes-sigs/kind/releases/download/$version"
curl --fail --location --retry 3 "$url/$asset" -o "$work/$asset"
curl --fail --location --retry 3 "$url/$asset.sha256sum" -o "$work/checksum"
(cd "$work" && sha256sum --check checksum)
install -m 0755 "$work/$asset" "$root/.local/bin/kind"
"$root/.local/bin/kind" version
echo 'Tools installed. Run: bash scripts/check-environment.sh'
