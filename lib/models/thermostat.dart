import 'connectable.dart';
import 'smart_device.dart';

class Thermostat extends SmartDevice implements Connectable {
  // Keep the base-constructor delegation explicit for the OOP demonstration.
  // ignore: use_super_parameters
  Thermostat({
    required String id,
    required String name,
    required String room,
    int temperature = 22,
    this.ambientTemperature = 20,
  }) : _temperature = temperature.clamp(minTemperature, maxTemperature).toInt(),
       super(id: id, name: name, room: room);

  static const int minTemperature = 16;
  static const int maxTemperature = 30;

  int _temperature;
  final int ambientTemperature;

  int get temperature => _temperature;

  void increaseTemperature() => setTemperature(_temperature + 1);

  void decreaseTemperature() => setTemperature(_temperature - 1);

  void setTemperature(int temperature) {
    requireConnection();
    _temperature = temperature.clamp(minTemperature, maxTemperature).toInt();
  }

  @override
  String getStatus() {
    if (!isConnected) return 'Offline';
    if (_temperature > ambientTemperature) return 'Heating';
    if (_temperature < ambientTemperature) return 'Cooling';
    return 'At target';
  }

  @override
  void connect() {
    isConnected = true;
  }

  @override
  void disconnect() {
    isConnected = false;
  }
}
