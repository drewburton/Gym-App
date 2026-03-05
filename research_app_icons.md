# Research Findings - App Icons

## Source Icons: `/Users/drewburton/dev/Gym-App/AppIcons/`
- `appstore.png` (1024x1024)
- `playstore.png` (512x512?)
- `Assets.xcassets/AppIcon.appiconset/` contains:
  - `1024.png` (1024x1024)
  - `114.png` (114x114)
  - `120.png` (120x120)
  - `180.png` (180x180)
  - `29.png` (29x29)
  - `40.png` (40x40)
  - `57.png` (57x57)
  - `58.png` (58x58)
  - `60.png` (60x60)
  - `80.png` (80x80)
  - `87.png` (87x87)
  - `Contents.json`: Already contains mapping for these files.

## Destination: `/Users/drewburton/dev/Gym-App/WorkoutTracker-iOS/Resources/Assets.xcassets/AppIcon.appiconset/`
- Current `Contents.json` is minimal (universal 1024x1024 only).
- No image files present.

## Mapping
The files in `AppIcons/Assets.xcassets/AppIcon.appiconset/` should be copied to the destination, and `Contents.json` should be replaced with the one from the source (with adjustments if paths differ, but usually `Contents.json` paths are relative to the folder).

The source `Contents.json` has:
```json
{"images":[{"size":"60x60","expected-size":"180","filename":"180.png","folder":"Assets.xcassets/AppIcon.appiconset/","idiom":"iphone","scale":"3x"}, ...]}
```
Note: The "folder" key in source `Contents.json` might be non-standard or specific to whatever tool generated it. Standard Xcode `Contents.json` doesn't usually have a "folder" key per image. However, copying it as is might work, or it might need cleanup.

## Requirements
Standard iOS App Icon sizes:
- iPhone Notification (20pt): 40x40 (2x), 60x60 (3x)
- iPhone Settings (29pt): 29x29 (1x), 58x58 (2x), 87x87 (3x)
- iPhone Spotlight (40pt): 80x80 (2x), 120x120 (3x)
- iPhone App (60pt): 120x120 (2x), 180x180 (3x)
- App Store (1024pt): 1024x1024 (1x)

The source files cover most of these.
Missing or extra:
- 57.png and 114.png are for older iPhone icons (pre-iOS 7).
- 40.png (size 20x20 @ 2x) is present.
- 60.png (size 20x20 @ 3x) is present.
- 120.png (size 40x40 @ 3x) is present.
- 120.png (size 60x60 @ 2x) is present.
- 180.png (size 60x60 @ 3x) is present.
- 29.png (size 29x29 @ 1x) is present.
- 58.png (size 29x29 @ 2x) is present.
- 87.png (size 29x29 @ 3x) is present.
- 80.png (size 40x40 @ 2x) is present.
- 1024.png (size 1024x1024 @ 1x) is present.

Everything seems to be there.
