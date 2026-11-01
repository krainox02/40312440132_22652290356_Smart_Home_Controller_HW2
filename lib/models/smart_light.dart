import 'connectable.dart';
import 'schedulable.dart';
import 'smart_device.dart';

/// Inheritance, an explicit interface, and reusable mixin behavior in one model.
class SmartLight extends SmartDevice with Schedulable implements Connectable {
  /// Unnamed/default constructor; `super` initializes the inherited identity.
  // Keep explicit delegation visible for the assignment's `super` example.
  // ignore: use_super_parameters
  SmartLight({
    required String id,
    required String name,
    required String room,
    int brightness = 75,
    bool isOn = true,
  }) : _brightness = brightness.clamp(0, 100).toInt(),
       // Public argument and private field intentionally have different names.
       // ignore: prefer_initializing_formals
       _isOn = isOn,
       super(id: id, name: name, room: room);

  /// Named constructor provides a ready-to-use reading configuration.
  SmartLight.reading({
    required String id,
    required String name,
    required String room,
  }) : this(id: id, name: name, room: room, brightness: 65, isOn: true);

  int _brightness;
  bool _isOn;

  int get brightness => _brightness;
  bool get isOn => _isOn;

  void togglePower() {
    requireConnection();
    _isOn = !_isOn;
  }

  void setBrightness(int brightness) {
    requireConnection();
    _brightness = brightness.clamp(0, 100).toInt();
  }

  @override
  String getStatus() => !isConnected ? 'Offline' : (_isOn ? 'On' : 'Off');

  @override
  void connect() {
    isConnected = true;
  }

  @override
  void disconnect() {
    isConnected = false;
  }

  @override
  void performScheduledAction() {
    togglePower();
  }
}
