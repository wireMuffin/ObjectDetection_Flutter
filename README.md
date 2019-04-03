# version_0_1

##NOT COMPLETED

A Flutter project that plays specific video when the app detected the corresponding object (by reading captured image from ESP32).

## Getting Started (From Very Beginning)

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

##Really Getting Started

#### pubspec.yml

1. "image picker" and "video_player" packages is imported by adding 2 lines in ***version_0_1/pubspec.yml*** :

```yaml
dependencies:
  flutter:
    sdk: flutter
  #newly added packages
  image_picker: ^0.5.0+6
  video_player: ^0.10.0+4 
  #end newly added packages
```

2. 2 video are imported as assets:

   2 video files, "bunnyShort.mp4" and "bunny.mp4" are added to ***version_0_1/assets/*** , and 3 lines are added to ***version_0_1/pubspec.yml***:

   ```yaml
     assets:
       - assets/bunny.mp4
       - assets/bunnyShort.mp4
   ```

   - these 2 lines are added **BELOW** "flutter: " with level 2 of indentation.

