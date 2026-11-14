# Icon variations

These icons are licensed under GPLv3. Please see the [script for generating icons](../../tools/README.md) and appropriatedly redirect for seasonal icons.

- `base_named.svg` - Named variant (deprecated).
- `base_small.svg`: Variant used for tiny icons (16x16, 64x64, etc).
- `base.svg`: Variant without branding/naming.
- `base_<platform>.svg`: `base.svg` drawn in that platform's own style -- a Fluent tile with caption
  buttons (Windows), a squircle with traffic lights (macOS), a terminal panel with a `>_` prompt
  (Linux), a Material circle with a gesture bar (Android) -- with its badge highlighted in the
  platform's accent colour. Update one platform with
  `PLATFORM=<platform> VARIATION=base_<platform> tools/update-icons.sh`.
- `base_<platform>_small.svg`: same icon with the window chrome simplified for small frames (up to
  64px), where the caption glyphs and traffic lights would be sub-pixel and turn to mush.

Try to keep the icons simple. And preferably automatically be able to be generated (to reduce maintanaince burden). Additionally keep the files small (use `svgo` and `optipng`) to not clutter the git.
