#!/usr/bin/env bash
set -euo pipefail

# Minimal test script to verify the download link selection logic.
# Usage: ./scripts/test_affinity_installer.sh designer
# Prints the chosen URL (no download).

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <designer|photo|publisher>" >&2
  exit 2
fi
product="$1"
page="https://store.serif.com/en-us/update/windows/${product}/2/"

# fetch page
if command -v wget >/dev/null 2>&1; then
  html=$(wget -q -O- "$page") || { echo "Failed to fetch page" >&2; exit 3; }
elif command -v curl >/dev/null 2>&1; then
  html=$(curl -sL "$page") || { echo "Failed to fetch page" >&2; exit 3; }
else
  echo "wget or curl required" >&2
  exit 4
fi

# extract dropdown block
block=$(echo "$html" | sed -n '/download-alternates/,/<\/div>/p' || true)
url=""
if [ -n "$block" ]; then
  hrefs=$(echo "$block" | grep -oE 'href="[^"]+"' | sed 's/^href="//;s/"$//' || true)
  if [ -n "$hrefs" ]; then
    # prefer any href that contains -msi- or .exe
    while IFS= read -r h; do
      h_unescaped="${h//&amp;/&}"
      lower="${h_unescaped,,}"
      if [[ "$lower" == *"-msi-"* || "$lower" == *".exe"* ]]; then
        url="$h_unescaped"
        break
      fi
      if [ -z "$url" ]; then
        url="$h_unescaped"
      fi
    done <<< "$(echo "$hrefs")"
    # fallback to second then first
    if [ -z "$url" ]; then
      second=$(echo "$hrefs" | sed -n '2p' || true)
      first=$(echo "$hrefs" | sed -n '1p' || true)
      if [ -n "$second" ]; then
        url="${second//&amp;/&}"
      else
        url="${first//&amp;/&}"
      fi
    fi
  fi
fi

# fallback: scan for affinity-<product> links
if [ -z "$url" ]; then
  candidates=$(echo "$html" | grep -oE "https?://[^\"']*affinity-${product}[^\"']*\.(exe|msi|msix)(\?[^\"']*)?" || true)
  if [ -n "$candidates" ]; then
    while read -r line; do
      cand="${line//&amp;/&}"
      if echo "$cand" | grep -qiE "\.exe(\?|$)" || echo "$cand" | grep -qi "-msi-"; then
        url="$cand"
        break
      fi
      if [ -z "$url" ]; then
        url="$cand"
      fi
    done <<< "$candidates"
  fi
fi

if [ -z "$url" ]; then
  echo "No download link found for $product" >&2
  exit 5
fi

# unescape (safe) and print
url=$(echo "$url" | sed 's/&amp;/\&/g')
echo "$url"
exit 0
