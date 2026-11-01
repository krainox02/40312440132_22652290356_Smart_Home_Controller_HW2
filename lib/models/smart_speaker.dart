import 'connectable.dart';
import 'smart_device.dart';

class SmartSpeaker extends SmartDevice implements Connectable {
  // Keep the base-constructor delegation explicit for the OOP demonstration.
  // ignore: use_super_parameters
  SmartSpeaker({
    required String id,
    required String name,
    required String room,
    int volume = 40,
    bool isPlaying = false,
  }) : _volume = volume.clamp(0, 100).toInt(),
       // Preserve a public `isPlaying` argument with encapsulated storage.
       // ignore: prefer_initializing_formals
       _isPlaying = isPlaying,
       super(id: id, name: name, room: room);

  /// Named configuration, delegated to the unnamed constructor.
  SmartSpeaker.lounge({
    required String id,
    required String name,
    required String room,
  }) : this(id: id, name: name, room: room, volume: 40, isPlaying: false);

  int _volume;
  bool _isPlaying;

  int get volume => _volume;
  bool get isPlaying => _isPlaying;

  void togglePlayback() {
    requireConnection();
    _isPlaying = !_isPlaying;
  }

  void setVolume(int volume) {
    requireConnection();
    _volume = volume.clamp(0, 100).toInt();
  }

  @override
  String getStatus() =>
      !isConnected ? 'Offline' : (_isPlaying ? 'Playing' : 'Paused');

  @override
  void connect() {
    isConnected = true;
  }

  @override
  void disconnect() {
    _isPlaying = false;
    isConnected = false;
  }
}
