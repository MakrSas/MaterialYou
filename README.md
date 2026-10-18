# Material You for iOS 16

Android 17 Material You colours for jailbroken iOS 16 (rootless). The customisation core shared by
[LineageQS](https://github.com/MakrSas/LineageQS) and future ports (Trebuchet launcher).

- **Settings → Material You** (right under Display & Brightness): Android 17 "Colors" picker. It has wallpaper colours,
  a custom colour on a hue slider, Neutral / Soft / Bright / Bold styles, and a dark theme switch.
- Palettes are exact output of Google's libmonet (SPEC_2026), precomputed per hue and style (`Resources/monet_table.bin`, `tools/Gen.java`).
  Wallpaper seeds use the Android pipeline (Celebi quantizer + ColorScheme seed scoring, ported in `Monet/`).

## For tweak developers
- Theme: `/var/mobile/Library/MaterialYou/theme.json` → `{"seeds", "style", "source", "hue", "colors": {"system_<token>_light|dark": "#RRGGBB|#AARRGGBB"}}`
  (token names = Android `system_*` colours, e.g. `system_primary_dark`, `system_accent1_200_light`).
- Darwin notification after Apply: `com.makr.materialyou/theme-changed`.
- Add `Depends: com.makr.materialyou` to your package.

## Build
Theos, iOS 16.5 SDK: `./build.sh` → `packages/*.deb`.

Apache License 2.0, see NOTICE.

## roothide branch

This branch builds for roothide (Procursus roothide, Nyxian "Procursus Jailed"):
build as usual with `build.sh`, then `scripts/roothide.sh packages/<pkg>_iphoneos-arm64.deb`
produces the `iphoneos-arm64e` package.
