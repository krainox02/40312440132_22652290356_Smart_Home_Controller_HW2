# Verification

The project was checked on two machines on **1 November 2026**.

## macOS — Flutter 3.47.9 stable / Dart 3.13.7, Xcode 27.2

- `flutter pub get`: dependencies resolved.
- `flutter analyze`: no issues found.
- `flutter test`: **23 tests passed**, comprising 16 model tests and 7 widget tests.
- `flutter build web --release`: release build completed successfully.
- `flutter build ios --simulator --debug`: build completed; the app was installed and launched on an iPhone 17 simulator (iOS 27.2) and showed the dashboard with the footer **Total devices created: 4**.

Minimum SDK check with **Flutter 3.35.7 / Dart 3.9.2** (the lowest Dart version allowed by `pubspec.yaml`): `flutter pub get`, `flutter analyze` (no issues), `flutter test` (23 passed), and `flutter build web --release` all succeeded.

## Windows 11 — Flutter 3.47.7 stable / Dart 3.13.5

- `flutter analyze`: no issues found.
- `flutter test`: **23 tests passed**, comprising 16 model tests and 7 widget tests.
- `flutter build web --release`: release build completed successfully.

## Test coverage

Model coverage includes both constructor styles and exact static counter increments, all subclass/interface relationships, polymorphic statuses, light power, brightness bounds, thermostat temperature bounds and heating/cooling/target states, playback, volume bounds, offline action guards, speaker pause on disconnect, and one-shot scheduling with cancellation/replacement/offline deferral.

Widget coverage includes all four device cards and their initial numeric properties; light switch and brightness slider; temperature buttons; speaker playback and volume slider; disconnect/reconnect and summary changes; room filtering without recreating objects; schedule creation/cancellation through the actual time picker; exact group member names/numbers; and a 320 x 740 phone viewport at 150% text scaling without overflow.

## Rendered application

- The release web build was served over local HTTP and opened in a Chromium-based browser. The dashboard loaded correctly, including the static footer count of 4.
- `screenshots/dashboard.png`: actual Flutter rendering at 1100 x 1250 with all four cards visible.
- `screenshots/phone.png`: actual Flutter rendering at 390 x 844 with vertical scrolling and a persistent footer.
- Both screenshots use real Roboto and Material Icons fonts and were visually inspected.

## Platform scope

Android, iOS, and web platform project files are included. The Android and iOS folders match the standard Flutter 3.47 project template, apart from the Android app label. The iOS app was built and run on a simulator; a native Android APK build was not performed because no Android SDK was installed on either machine. The same Dart/Flutter application code is exercised by the model/widget tests and the web and iOS builds. No physical smart-home hardware is used.

## Submission contents

The ZIP includes source, tests, platform projects, dependency lockfile, screenshots, and this documentation. It excludes `build`, `.dart_tool`, IDE state, machine-local Android paths, and the Flutter SDK.
