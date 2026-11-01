# Haven · Smart Home Controller

BIM493 Mobile Programming I — Assignment #2

- **Tarık Ata Kılıç** — **40312440132**
- **Ata Turan** — **22652290356**

A Flutter smart-home simulation with four device objects: two lights, one thermostat, and one speaker. No account, API key, network service, or physical device is required. The interface is in English, matching the assignment.

## Run the project

Use a recent stable Flutter SDK (the project was developed with Flutter 3.47; Dart 3.9 or newer is required). Open this directory (the one containing `pubspec.yaml`) in VS Code or Android Studio, then run:

```sh
flutter pub get
flutter run -d chrome
```

For Android, install/configure the Android SDK, start an emulator or connect a USB-debugging-enabled phone, and use:

```sh
flutter devices
flutter run -d <android-device-id>
```

For iOS, open the project on macOS with Xcode and an iOS simulator or configured device:

```sh
flutter run -d <ios-device-id>
```

The project includes Android, iOS, and web platform folders. Test and build results are recorded in `docs/VERIFICATION.md`.

## Try the controls

1. Toggle **Ceiling light** and change its brightness. The stored brightness is retained when the light is off; its slider is disabled until powered on.
2. Adjust **Room climate** with minus/plus. The target stays between 16 and 30°C. Its status compares the target with the simulated room temperature of 20°C: Heating, Cooling, or At target.
3. Play/pause **Home speaker** and change its volume. This simulates playback state; it does not stream audio.
4. Use any card's options menu to disconnect/reconnect. Offline controls are disabled, and the summary updates. Disconnecting a speaker pauses playback.
5. For a light, choose **Schedule power toggle**. Pick a future time today, or an earlier time for the next day. The card shows the scheduled date/time. The action executes once while the app is open; if offline, it waits for reconnection. **Cancel schedule** removes it.
6. Filter by room. Device state and the total created count stay unchanged. The info button displays both group members.

State is intentionally held in memory and resets on app restart. Scheduling is an in-app demonstration, not an operating-system background alarm.

## Assignment requirements

### Classes and Dart features

| Concept | Implementation |
| --- | --- |
| **Class** | Base class `SmartDevice` (`lib/models/smart_device.dart`) and the subclasses `SmartLight`, `Thermostat`, and `SmartSpeaker` (`lib/models/smart_light.dart`, `thermostat.dart`, `smart_speaker.dart`). |
| **Objects** | `lib/data/demo_devices.dart` creates four objects: two `SmartLight`, one `Thermostat`, and one `SmartSpeaker`. `HomeScreen.initState()` creates the list once, outside `build()`, and every object is displayed as a card. |
| **Constructor** | Default (unnamed) constructors: `SmartLight(...)` and `Thermostat(...)`. Named constructors: `SmartLight.reading(...)` and `SmartSpeaker.lounge(...)`. Both kinds are used to create the objects in `demo_devices.dart`. |
| **Inheritance** | `SmartLight`, `Thermostat`, and `SmartSpeaker` each `extends SmartDevice`. |
| **Abstraction** | `SmartDevice` is an `abstract class` with the abstract method `String getStatus()`; every subclass overrides it. |
| **Interface** | `Connectable` (`lib/models/connectable.dart`) declares `connect()` and `disconnect()`. All three device classes `implements Connectable`, and each card's options menu calls these methods. |
| **Mixin** | `mixin Schedulable` (`lib/models/schedulable.dart`) adds one-shot scheduling. `SmartLight` uses it with `with Schedulable` (options menu → **Schedule power toggle**). |
| **Keywords** | `static`: `SmartDevice.totalDevicesCreated` (also `Thermostat.minTemperature` and `maxTemperature`). `super`: each subclass constructor calls `super(id: id, name: name, room: room)`. `this`: the base constructor uses `this.id`, `this.name`, and `this.room`, and the named constructors redirect with `this(...)`. |

Polymorphism: a `List<SmartDevice>` stores the different device objects, and each card calls `device.getStatus()` through the base type.

### UI screen

| Element | Implementation |
| --- | --- |
| **Device List** | `lib/screens/home_screen.dart` shows one card per device: Smart Light (two cards), Thermostat, and Smart Speaker. |
| **Device Information** | `lib/widgets/device_card.dart` shows the device name, its type and room, the relevant property (brightness %, target temperature °C, volume %), and the current status returned by `getStatus()`. |
| **Interaction** | Smart Light: on/off switch and brightness slider. Thermostat: minus/plus temperature buttons (16–30°C). Smart Speaker: play/pause button and volume slider. |
| **Bottom Text** | The footer shows **Total devices created: 4**, read directly from the static variable `SmartDevice.totalDevicesCreated`. The `SmartDevice` constructor increments it, so the value does not come from the list length. Filters, controls, and widget rebuilds never construct extra devices. |

## Check and build

```sh
flutter analyze
flutter test
flutter build web --release
```

Unit tests cover constructor counting, polymorphic behavior, connection guards, value bounds, and scheduled actions. Widget tests cover the rendered controls and layout. A release web build can be served over HTTP; opening `build/web/index.html` directly as a file is not supported.

```sh
python3 -m http.server 8080 --directory build/web
```

Then open `http://localhost:8080` in a browser. On Windows, use `python` instead of `python3`.

## Source layout

```text
lib/
  main.dart                    App and theme
  data/demo_devices.dart       Default + named constructor instances
  models/                      Dart OOP implementation
  screens/home_screen.dart     Dashboard, filtering, scheduler, static footer
  widgets/device_card.dart     Model-backed device controls
android/                       Android platform project
ios/                           iOS platform project
web/                           Web entry and launcher assets
test/                          Model and widget tests
docs/                          Verification notes and screenshots
tools/package_submission.py    Reproducible minimal source ZIP
```

## Packaging

`python3 tools/package_submission.py` creates `output/HW2_Tarik_Ata_Kilic_40312440132_Ata_Turan_22652290356.zip`. The ZIP contains the full source project and documentation, without SDKs, build caches, IDE state, or machine-specific paths.

## References

- BIM493 Mobile Programming I, Assignment #2 brief (`HW2.pdf`).
- [Flutter documentation](https://docs.flutter.dev/) (project/platform tooling).
- [Dart mixins](https://dart.dev/language/mixins) and [class modifiers](https://dart.dev/language/class-modifiers-for-apis) (language features).
