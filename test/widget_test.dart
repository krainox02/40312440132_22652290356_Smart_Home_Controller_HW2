import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_controller/main.dart';
import 'package:smart_home_controller/models/devices.dart';
import 'package:smart_home_controller/widgets/device_card.dart';

Finder card(String id) => find.byWidgetPredicate(
  (widget) => widget is DeviceCard && widget.device.id == id,
);

Finder inside(String id, Finder finder) =>
    find.descendant(of: card(id), matching: finder);

T model<T extends SmartDevice>(WidgetTester tester, String id) =>
    tester.widget<DeviceCard>(card(id)).device as T;

Future<void> launch(
  WidgetTester tester, {
  Size size = const Size(1100, 1500),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(const SmartHomeApp());
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> changeSlider(
  WidgetTester tester,
  Finder finder,
  double fraction,
) async {
  await tester.ensureVisible(finder);
  final rect = tester.getRect(finder);
  // Tap the actual track rather than invoking the widget callback directly.
  await tester.tapAt(Offset(rect.left + rect.width * fraction, rect.center.dy));
  await tester.pumpAndSettle();
}

Future<void> stop(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  testWidgets(
    'shows all model types and a footer backed by the static counter',
    (tester) async {
      final before = SmartDevice.totalDevicesCreated;
      await launch(tester);

      expect(find.byType(DeviceCard), findsNWidgets(4));
      expect(find.text('Ceiling light'), findsOneWidget);
      expect(find.text('Room climate'), findsOneWidget);
      expect(find.text('Home speaker'), findsOneWidget);
      expect(find.text('Reading lamp'), findsOneWidget);
      expect(model<SmartLight>(tester, 'living-light').brightness, 75);
      expect(model<SmartLight>(tester, 'study-light').brightness, 65);
      expect(model<Thermostat>(tester, 'bedroom-climate').temperature, 22);
      expect(model<SmartSpeaker>(tester, 'kitchen-speaker').volume, 40);
      expect(SmartDevice.totalDevicesCreated, before + 4);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('device-count'))).data,
        'Total devices created: ${SmartDevice.totalDevicesCreated}',
      );
      expect(find.text('4 of 4 devices connected'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await stop(tester);
    },
  );

  testWidgets('device controls update model values and the visible statuses', (
    tester,
  ) async {
    await launch(tester);
    final light = model<SmartLight>(tester, 'living-light');
    final thermostat = model<Thermostat>(tester, 'bedroom-climate');
    final speaker = model<SmartSpeaker>(tester, 'kitchen-speaker');
    final power = find.byKey(const ValueKey('power-living-light'));
    final brightness = find.byKey(const ValueKey('brightness-living-light'));

    await press(tester, power);
    expect(light.isOn, isFalse);
    expect(inside('living-light', find.text('Off')), findsOneWidget);
    expect(tester.widget<Slider>(brightness).onChanged, isNull);
    await press(tester, power);
    expect(light.isOn, isTrue);
    await changeSlider(tester, brightness, 0.25);
    expect(light.brightness, lessThan(50));
    expect(
      inside('living-light', find.text('${light.brightness}%')),
      findsOneWidget,
    );

    await press(
      tester,
      find.byKey(const ValueKey('temperature-up-bedroom-climate')),
    );
    expect(thermostat.temperature, 23);
    expect(inside('bedroom-climate', find.text('23°C')), findsOneWidget);
    await press(
      tester,
      find.byKey(const ValueKey('temperature-down-bedroom-climate')),
    );
    expect(thermostat.temperature, 22);
    expect(inside('bedroom-climate', find.text('22°C')), findsOneWidget);

    final playback = find.byKey(const ValueKey('playback-kitchen-speaker'));
    await press(tester, playback);
    expect(speaker.isPlaying, isTrue);
    expect(inside('kitchen-speaker', find.text('Playing')), findsOneWidget);
    await changeSlider(
      tester,
      find.byKey(const ValueKey('volume-kitchen-speaker')),
      0.8,
    );
    expect(speaker.volume, greaterThan(60));
    expect(
      inside('kitchen-speaker', find.text('${speaker.volume}%')),
      findsOneWidget,
    );
    await press(tester, playback);
    expect(speaker.isPlaying, isFalse);
    expect(inside('kitchen-speaker', find.text('Paused')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await stop(tester);
  });

  testWidgets(
    'disconnect and reconnect update controls and connection summary',
    (tester) async {
      await launch(tester);
      final speaker = model<SmartSpeaker>(tester, 'kitchen-speaker');
      final options = find.byKey(const ValueKey('options-kitchen-speaker'));
      final playback = find.byKey(const ValueKey('playback-kitchen-speaker'));
      final volume = find.byKey(const ValueKey('volume-kitchen-speaker'));
      await press(tester, playback);
      await press(tester, options);
      await press(tester, find.text('Disconnect device'));

      expect(speaker.isConnected, isFalse);
      expect(speaker.isPlaying, isFalse);
      expect(inside('kitchen-speaker', find.text('Offline')), findsOneWidget);
      expect(tester.widget<IconButton>(playback).onPressed, isNull);
      expect(tester.widget<Slider>(volume).onChanged, isNull);
      expect(find.text('3 of 4 devices connected'), findsOneWidget);

      await press(tester, options);
      await press(tester, find.text('Reconnect device'));
      expect(speaker.isConnected, isTrue);
      expect(inside('kitchen-speaker', find.text('Paused')), findsOneWidget);
      expect(tester.widget<IconButton>(playback).onPressed, isNotNull);
      expect(tester.widget<Slider>(volume).onChanged, isNotNull);
      expect(find.text('4 of 4 devices connected'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await stop(tester);
    },
  );

  testWidgets('room filters preserve objects, state and the static count', (
    tester,
  ) async {
    await launch(tester);
    final light = model<SmartLight>(tester, 'living-light');
    final count = SmartDevice.totalDevicesCreated;
    await press(tester, find.byKey(const ValueKey('power-living-light')));
    await press(tester, find.byKey(const ValueKey('room-Bedroom')));
    expect(find.byType(DeviceCard), findsOneWidget);
    expect(card('bedroom-climate'), findsOneWidget);
    expect(SmartDevice.totalDevicesCreated, count);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('device-count'))).data,
      'Total devices created: $count',
    );
    await press(tester, find.byKey(const ValueKey('room-All rooms')));
    expect(find.byType(DeviceCard), findsNWidgets(4));
    expect(model<SmartLight>(tester, 'living-light'), same(light));
    expect(light.isOn, isFalse);
    expect(inside('living-light', find.text('Off')), findsOneWidget);
    expect(SmartDevice.totalDevicesCreated, count);
    expect(tester.takeException(), isNull);
    await stop(tester);
  });

  testWidgets('light schedule can be created and cancelled through its menu', (
    tester,
  ) async {
    await launch(tester);
    final light = model<SmartLight>(tester, 'living-light');
    final options = find.byKey(const ValueKey('options-living-light'));
    await press(tester, options);
    await press(tester, find.text('Schedule power toggle'));
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await press(tester, find.text('OK'));
    expect(light.scheduledTime, isNotNull);
    expect(find.textContaining('Scheduled toggle ·'), findsOneWidget);
    await press(tester, options);
    await press(tester, find.text('Cancel schedule'));
    expect(light.scheduledTime, isNull);
    expect(find.textContaining('Scheduled toggle ·'), findsNothing);
    expect(tester.takeException(), isNull);
    await stop(tester);
  });

  testWidgets('about dialog identifies both group members exactly', (
    tester,
  ) async {
    await launch(tester);
    await press(tester, find.byKey(const ValueKey('about')));
    expect(find.textContaining('Tarık Ata Kılıç'), findsOneWidget);
    expect(find.textContaining('40312440132'), findsOneWidget);
    expect(find.textContaining('Ata Turan'), findsOneWidget);
    expect(find.textContaining('22652290356'), findsOneWidget);
    await press(tester, find.text('Close'));
    expect(tester.takeException(), isNull);
    await stop(tester);
  });

  testWidgets(
    'narrow phone and large text render every card without overflow',
    (tester) async {
      await launch(tester, size: const Size(320, 740), textScale: 1.5);
      expect(find.byKey(const ValueKey('device-count')), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final id in [
        'living-light',
        'bedroom-climate',
        'kitchen-speaker',
        'study-light',
      ]) {
        await tester.ensureVisible(card(id));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$id overflowed');
      }
      await stop(tester);
    },
  );
}
