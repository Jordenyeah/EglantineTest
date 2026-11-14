#!/bin/sh -ex

# SPDX-FileCopyrightText: Copyright 2026 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# Updates main icons for eden

which magick || exit
which optipng || exit

VARIATION=${VARIATION:-base}
PLATFORM=${PLATFORM:-all}

EDEN_BASE_SVG="dist/icon_variations/${VARIATION}.svg"
EDEN_SMALL_SVG="dist/icon_variations/${VARIATION}_small.svg"
EDEN_BG_COLOR="dist/icon_variations/${VARIATION}_bgcolor"
# TODO: EDEN_MONOCHROME_SVG Variation

[ -f "$EDEN_BASE_SVG" ] && [ -f "$EDEN_BG_COLOR" ] || { echo "Error: missing ${VARIATION}.svg/${VARIATION}_bgcolor" >&2; exit; }

# The per-platform variations differ, so PLATFORM=windows|linux|macos|android updates only that set

want() {
    [ "$PLATFORM" = all ] || [ "$PLATFORM" = "$1" ]
}

# Window chrome is sub-pixel below ~64px, so a _small variation drops that detail

[ -f "$EDEN_SMALL_SVG" ] || EDEN_SMALL_SVG="$EDEN_BASE_SVG"
SMALL_MAX=64

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

render_png() {
    if [ "$1" -le "$SMALL_MAX" ]; then _src="$EDEN_SMALL_SVG"; else _src="$EDEN_BASE_SVG"; fi
    magick -background transparent "$_src" -resize "$1x$1" "$2" || exit
}

EDEN_DESKTOP_SVG="dist/dev.eden_emu.eden.svg"

# Windows

if want windows; then
    for size in 16 24 32 40 48 64 96 128 192 256; do
        render_png "$size" "$TMP_DIR/ico-$size.png"
    done
    magick "$TMP_DIR"/ico-16.png "$TMP_DIR"/ico-24.png "$TMP_DIR"/ico-32.png "$TMP_DIR"/ico-40.png \
        "$TMP_DIR"/ico-48.png "$TMP_DIR"/ico-64.png "$TMP_DIR"/ico-96.png "$TMP_DIR"/ico-128.png \
        "$TMP_DIR"/ico-192.png "$TMP_DIR"/ico-256.png dist/eden.ico || exit
    magick -density 256x256 -background transparent "$EDEN_BASE_SVG" -resize 256x256 dist/eden.bmp || exit
fi

# Linux

if want linux; then
    cp "$EDEN_BASE_SVG" "$EDEN_DESKTOP_SVG"

    magick -size 256x256 -background transparent "$EDEN_BASE_SVG" -resize 256x256 dist/qt_themes/default/icons/256x256/eden.png || exit
    optipng -o7 dist/qt_themes/default/icons/256x256/eden.png

    magick -size 512x512 -background transparent "$EDEN_BASE_SVG" -resize 512x512 dist/Eglantine.png || exit
    optipng -o7 dist/Eglantine.png
fi

# macOS

if want macos; then
    cp "$EDEN_BASE_SVG" "dist/eden.icon/Assets/dev.eden_emu.eden.svg"

    # TODO: Update Assets.car too

    for size in 32 64 128 256 512 1024; do
        render_png "$size" "$TMP_DIR/icns-$size.png"
    done

    png2icns dist/eden.icns "$TMP_DIR"/icns-32.png "$TMP_DIR"/icns-64.png \
        "$TMP_DIR"/icns-128.png "$TMP_DIR"/icns-256.png "$TMP_DIR"/icns-512.png \
        "$TMP_DIR"/icns-1024.png || echo 'non fatal'
    png2icns dist/eglantine.icns "$TMP_DIR"/icns-32.png "$TMP_DIR"/icns-64.png \
        "$TMP_DIR"/icns-128.png "$TMP_DIR"/icns-256.png "$TMP_DIR"/icns-512.png \
        "$TMP_DIR"/icns-1024.png || echo 'non fatal'
fi

# Android

if want android; then
    EDEN_ANDROID_RES="src/android/app/src/main/res"
    EDEN_ANDROID_FG="$EDEN_ANDROID_RES/drawable/ic_launcher_foreground.png"
    EDEN_ANDROID_BG_COLOR=$(cat $EDEN_BG_COLOR)

    # Update Icon Background Color
    echo "<?xml version='1.0' encoding='utf-8'?><resources><color name='ic_launcher_background'>${EDEN_ANDROID_BG_COLOR}</color></resources>" > "$EDEN_ANDROID_RES/values/colors.xml"

    magick -size 1080x1080 -background transparent "$EDEN_BASE_SVG" -gravity center -resize 660x660 -extent 1080x1080 "$EDEN_ANDROID_FG" || exit
    magick -background transparent "$EDEN_BASE_SVG" -gravity center -resize 512x512 "$EDEN_ANDROID_RES/drawable/ic_yuzu.png" || exit
    magick -size 512x512 -background transparent "$EDEN_BASE_SVG" -gravity center -resize 338x338 -extent 512x512 "$EDEN_ANDROID_RES/drawable/ic_yuzu_splash.png" || exit

    optipng -o7 "$EDEN_ANDROID_FG"
    optipng -o7 "$EDEN_ANDROID_RES/drawable/ic_yuzu.png"
    optipng -o7 "$EDEN_ANDROID_RES/drawable/ic_yuzu_splash.png"

    # Android legacy launcher icon (API <= 24)

    BASE_LEGACY="$EDEN_ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png"

    magick -size 512x512 xc:${EDEN_ANDROID_BG_COLOR} "$EDEN_ANDROID_FG" -gravity center -resize 384x384 -composite "$BASE_LEGACY" || exit

    magick "$BASE_LEGACY" -resize 192x192 "$EDEN_ANDROID_RES/mipmap-xxhdpi/ic_launcher.png"
    magick "$BASE_LEGACY" -resize 144x144 "$EDEN_ANDROID_RES/mipmap-xhdpi/ic_launcher.png"
    magick "$BASE_LEGACY" -resize 96x96 "$EDEN_ANDROID_RES/mipmap-hdpi/ic_launcher.png"
    magick "$BASE_LEGACY" -resize 72x72 "$EDEN_ANDROID_RES/mipmap-mdpi/ic_launcher.png"

    optipng -o7 "$EDEN_ANDROID_RES"/mipmap-*/ic_launcher.png
fi
