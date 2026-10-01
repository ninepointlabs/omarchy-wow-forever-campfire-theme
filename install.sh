#!/bin/bash
# Copy this checkout into the Omarchy user theme directory and apply it.
# Re-run after editing; `omarchy theme set` re-reads the files.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.config/omarchy/themes/wow-forever-campfire"

mkdir -p "$dest/backgrounds"
cp "$src/colors.toml" "$src/icons.theme" "$src/README.md" "$src/preview.png" "$dest/"
rm -f "$dest/backgrounds/"*.jpg
cp "$src/backgrounds/"*.jpg "$dest/backgrounds/"

echo "Installed to $dest"
if [[ "${1:-}" == "--apply" ]]; then
  omarchy theme set wow-forever-campfire
fi
