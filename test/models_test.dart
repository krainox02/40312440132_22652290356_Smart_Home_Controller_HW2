import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/models/devices.dart';

void main() {
  group('Object-oriented model requirements', () {
    test('unnamed and named constructors each count one created device', () {
      final before = SmartDevice.totalDevicesCreated;

      final light = SmartLight(
        id: 'light',
        name: 'Ceiling light',
        room: 'Living room',
      );
      final readingLight = SmartLight.reading(
        id: 'reading',
        name: 'Reading lamp',
        room: 'Study',
      );
      final thermostat = Thermostat(
        id: 'thermostat',
        name: 'Climate control',
        room: 'Bedroom',
      );
      final speaker = SmartSpeaker.lounge(
        id: 'speaker',
        name: 'Lounge speaker',
        room: 'Living room',
      );

      expect(SmartDevice.totalDevicesCreated, before + 4);
      expect(light.brightness, 75);
      expect(readingLight.brightness, 65);
      expect(readingLight.isOn, isTrue);
      expect(thermostat.temperature, 22);
      expect(speaker.volume, 40);
      expect(speaker.isPlaying, isFalse);
      expect(light.id, 'light');
      expect(light.name, 'Ceiling light');
      expect(light.room, 'Living room');
    });

    test('subclasses expose polymorphic status and implement Connectable', () {
      final devices = <SmartDevice>[
        SmartLight(id: 'light', name: 'Light', room: 'Lounge'),
        Thermostat(id: 'climate', name: 'Thermostat', room: 'Bedroom'),
        SmartSpeaker(id: 'speaker', name: 'Speaker', room: 'Kitchen'),
      ];
      expect(devices.map((device) => device.getStatus()), [
        'On',
        'Heating',
        'Paused',
      ]);

      for (final device in devices) {
        expect(device, isA<Connectable>());
        final connection = device as Connectable;
        expect(device.isConnected, isTrue);
        connection.disconnect();
        expect(device.isConnected, isFalse);
        expect(device.getStatus(), 'Offline');
        connection.connect();
        expect(device.isConnected, isTrue);
        expect(device.getStatus(), isNot('Offline'));
      }
    });

    test(
      'reading state and controlling devices do not increment static count',
      () {
        final light = SmartLight(id: 'light', name: 'Light', room: 'Lounge');
        final created = SmartDevice.totalDevicesCreated;

        for (var i = 0; i < 5; i++) {
          light.getStatus();
          light.togglePower();
          light.setBrightness(i * 10);
          light.disconnect();
          light.connect();
        }

        expect(SmartDevice.totalDevicesCreated, created);
      },
    );
  });

  group('SmartLight', () {
    late SmartLight light;

    setUp(() {
      light = SmartLight(id: 'light', name: 'Light', room: 'Lounge');
    });

    test('power action changes the actual model and status', () {
      expect(light.getStatus(), 'On');
      light.togglePower();
      expect(light.isOn, isFalse);
      expect(light.getStatus(), 'Off');
      light.togglePower();
      expect(light.isOn, isTrue);
      expect(light.getStatus(), 'On');
    });

    test('brightness accepts valid values and clamps both boundaries', () {
      light.setBrightness(42);
      expect(light.brightness, 42);
      light.setBrightness(-10);
      expect(light.brightness, 0);
      light.setBrightness(150);
      expect(light.brightness, 100);
    });

    test('offline controls reject changes and reconnect restores control', () {
      final brightness = light.brightness;
      final isOn = light.isOn;
      light.disconnect();

      expect(light.togglePower, throwsStateError);
      expect(() => light.setBrightness(10), throwsStateError);
      expect(light.brightness, brightness);
      expect(light.isOn, isOn);
      expect(light.getStatus(), 'Offline');

      light.connect();
      light.togglePower();
      expect(light.isOn, !isOn);
    });
  });

  group('Thermostat', () {
    late Thermostat thermostat;

    setUp(() {
      thermostat = Thermostat(
        id: 'climate',
        name: 'Thermostat',
        room: 'Bedroom',
      );
    });

    test(
      'temperature controls produce heating, target, and cooling states',
      () {
        expect(thermostat.getStatus(), 'Heating');
        thermostat.decreaseTemperature();
        expect(thermostat.temperature, 21);
        thermostat.decreaseTemperature();
        expect(thermostat.temperature, 20);
        expect(thermostat.getStatus(), 'At target');
        thermostat.decreaseTemperature();
        expect(thermostat.temperature, 19);
        expect(thermostat.getStatus(), 'Cooling');
        thermostat.increaseTemperature();
        expect(thermostat.temperature, 20);
        expect(thermostat.ambientTemperature, 20);
      },
    );

    test('target temperature is bounded for direct and step controls', () {
      thermostat.setTemperature(-100);
      expect(thermostat.temperature, Thermostat.minTemperature);
      thermostat.decreaseTemperature();
      expect(thermostat.temperature, Thermostat.minTemperature);

      thermostat.setTemperature(100);
      expect(thermostat.temperature, Thermostat.maxTemperature);
      thermostat.increaseTemperature();
      expect(thermostat.temperature, Thermostat.maxTemperature);
    });

    test('offline temperature changes are rejected without losing target', () {
      final target = thermostat.temperature;
      thermostat.disconnect();

      expect(thermostat.increaseTemperature, throwsStateError);
      expect(thermostat.decreaseTemperature, throwsStateError);
      expect(() => thermostat.setTemperature(25), throwsStateError);
      expect(thermostat.temperature, target);
      expect(thermostat.getStatus(), 'Offline');

      thermostat.connect();
      thermostat.increaseTemperature();
      expect(thermostat.temperature, target + 1);
    });
  });

  group('SmartSpeaker', () {
    late SmartSpeaker speaker;

    setUp(() {
      speaker = SmartSpeaker(id: 'speaker', name: 'Speaker', room: 'Kitchen');
    });

    test('play and pause change the model and current status', () {
      expect(speaker.getStatus(), 'Paused');
      speaker.togglePlayback();
      expect(speaker.isPlaying, isTrue);
      expect(speaker.getStatus(), 'Playing');
      speaker.togglePlayback();
      expect(speaker.isPlaying, isFalse);
      expect(speaker.getStatus(), 'Paused');
    });

    test('volume accepts valid values and clamps both boundaries', () {
      speaker.setVolume(67);
      expect(speaker.volume, 67);
      speaker.setVolume(-1);
      expect(speaker.volume, 0);
      speaker.setVolume(101);
      expect(speaker.volume, 100);
    });

    test(
      'disconnect pauses playback and blocks controls until reconnected',
      () {
        speaker.togglePlayback();
        final volume = speaker.volume;
        speaker.disconnect();

        expect(speaker.isPlaying, isFalse);
        expect(speaker.getStatus(), 'Offline');
        expect(speaker.togglePlayback, throwsStateError);
        expect(() => speaker.setVolume(5), throwsStateError);
        expect(speaker.volume, volume);

        speaker.connect();
        expect(speaker.getStatus(), 'Paused');
        speaker.togglePlayback();
        expect(speaker.getStatus(), 'Playing');
      },
    );
  });

  group('Schedulable mixin', () {
    late SmartLight light;
    final due = DateTime.utc(2026, 11, 10, 18);

    setUp(() {
      light = SmartLight(id: 'light', name: 'Light', room: 'Lounge');
    });

    test('scheduled action waits until due and executes exactly once', () {
      expect(light, isA<Schedulable>());
      light.schedule(due);
      expect(light.scheduledTime, due);
      expect(
        light.runScheduleIfDue(due.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(light.isOn, isTrue);

      expect(light.runScheduleIfDue(due), isTrue);
      expect(light.isOn, isFalse);
      expect(light.scheduledTime, isNull);
      expect(
        light.runScheduleIfDue(due.add(const Duration(seconds: 1))),
        isFalse,
      );
      expect(light.isOn, isFalse);
    });

    test('offline schedule is retained and runs after reconnection', () {
      light.schedule(due);
      light.disconnect();

      expect(light.runScheduleIfDue(due), isFalse);
      expect(light.scheduledTime, due);
      expect(light.isOn, isTrue);

      light.connect();
      expect(
        light.runScheduleIfDue(due.add(const Duration(minutes: 2))),
        isTrue,
      );
      expect(light.isOn, isFalse);
      expect(light.scheduledTime, isNull);
    });

    test('cancelled schedule never runs', () {
      light.schedule(due);
      light.clearSchedule();

      expect(light.scheduledTime, isNull);
      expect(light.runScheduleIfDue(due), isFalse);
      expect(light.isOn, isTrue);
    });

    test('rescheduling replaces the previous pending action', () {
      final later = due.add(const Duration(hours: 1));
      light.schedule(due);
      light.schedule(later);

      expect(light.scheduledTime, later);
      expect(light.runScheduleIfDue(due), isFalse);
      expect(light.isOn, isTrue);
      expect(light.runScheduleIfDue(later), isTrue);
      expect(light.isOn, isFalse);
    });
  });
}
