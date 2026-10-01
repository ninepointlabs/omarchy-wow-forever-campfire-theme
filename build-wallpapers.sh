#!/bin/bash
# Regenerate backgrounds/ from the 1280x540 source art in assets/.
#
# The source is too small for a desktop, so it is upscaled 4x to 5120x2160
# with Real-ESRGAN (x4plus, run on the GPU through Vulkan), then 15% of a plain
# Lanczos resize is blended back in so the grass and pine needles keep some
# grain instead of going waxy, and a light unsharp mask finishes it.
# The 21:9 frame is kept: Omarchy fills the screen, so 16:9 and 16:10 monitors
# get a centre crop around the campfire and ultrawides get all of it.
#
# Requires ImageMagick 7 (`magick`), curl, unzip and a Vulkan GPU.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
mkdir -p build backgrounds tools

ESRGAN=tools/realesrgan/realesrgan-ncnn-vulkan
if [[ ! -x $ESRGAN ]]; then
  curl -sL -o tools/realesrgan.zip \
    https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
  unzip -q -o tools/realesrgan.zip -d tools/realesrgan
  chmod +x $ESRGAN
fi

magick assets/wow-forever-camp.jpeg build/src.png
$ESRGAN -i build/src.png -o build/esrgan.png -n realesrgan-x4plus -m tools/realesrgan/models
magick build/src.png -filter Lanczos -resize 400% build/lanczos.png

magick build/esrgan.png build/lanczos.png -compose blend -define compose:args=15 -composite \
  -unsharp 0x1.2+0.35+0.02 -strip -quality 94 -sampling-factor 4:4:4 \
  backgrounds/campfire.jpg

echo "Wrote backgrounds/campfire.jpg"
