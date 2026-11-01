/// Abstract base class: all smart-home devices share identity and connectivity.
///
/// A device is counted when constructed, rather than when its widget rebuilds.
abstract class SmartDevice {
  SmartDevice({required this.id, required this.name, required this.room}) {
    totalDevicesCreated++;
  }

  // `this` in the constructor initializes these immutable instance fields.
  final String id;
  final String name;
  final String room;

  // `static` makes this a shared count across every SmartDevice subclass.
  static int totalDevicesCreated = 0;

  bool isConnected = true;

  /// Abstract behavior supplied by each concrete subclass (polymorphism).
  String getStatus();

  /// Mutating a disconnected device is not a successful remote action.
  void requireConnection() {
    if (!isConnected) {
      throw StateError(
        '$name is offline. Connect it before using its controls.',
      );
    }
  }
}
