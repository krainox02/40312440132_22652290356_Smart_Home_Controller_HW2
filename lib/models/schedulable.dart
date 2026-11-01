import 'smart_device.dart';

/// Reusable scheduling behavior mixed into an appropriate device subclass.
mixin Schedulable on SmartDevice {
  DateTime? _scheduledTime;

  DateTime? get scheduledTime => _scheduledTime;

  /// Accepts an explicit time without depending on the system clock.
  /// A past time is eligible on the next call to [runScheduleIfDue].
  void schedule(DateTime time) {
    _scheduledTime = time;
  }

  void clearSchedule() {
    _scheduledTime = null;
  }

  /// Executes once when due. An offline device retains its pending action.
  bool runScheduleIfDue(DateTime now) {
    final dueTime = _scheduledTime;
    if (dueTime == null || dueTime.isAfter(now) || !isConnected) {
      return false;
    }

    performScheduledAction();
    _scheduledTime = null;
    return true;
  }

  /// The host class supplies the action; the mixin supplies the timing logic.
  void performScheduledAction();
}
