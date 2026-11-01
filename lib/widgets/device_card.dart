import 'package:flutter/material.dart';

import '../models/devices.dart';

const _ink = Color(0xFF14243D);
const _muted = Color(0xFF5C6B80);
const _blue = Color(0xFF3265E8);

/// A device card renders model state and delegates every change to that model.
class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onChanged,
    required this.onSchedule,
  });

  final SmartDevice device;
  final VoidCallback onChanged;
  final ValueChanged<SmartLight> onSchedule;

  void _change(VoidCallback action) {
    action();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, label, tint, iconColor) = switch (device) {
      SmartLight() => (
        Icons.lightbulb_outline_rounded,
        'Smart Light',
        const Color(0xFFFFF4DB),
        const Color(0xFFBF851A),
      ),
      Thermostat() => (
        Icons.thermostat_rounded,
        'Thermostat',
        const Color(0xFFFFEDE6),
        const Color(0xFFD46E45),
      ),
      SmartSpeaker() => (
        Icons.speaker_rounded,
        'Smart Speaker',
        const Color(0xFFEBEEFF),
        const Color(0xFF6263C5),
      ),
      _ => (Icons.devices_rounded, 'Device', const Color(0xFFF0F3F8), _muted),
    };
    return Container(
      key: ValueKey('surface-${device.id}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EAF1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: device.isConnected ? tint : const Color(0xFFF0F3F8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: device.isConnected ? iconColor : _muted,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$label · ${device.room}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: PopupMenuButton<String>(
                  key: ValueKey('options-${device.id}'),
                  tooltip: '${device.name} options',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz_rounded, color: _muted),
                  onSelected: (value) {
                    switch (value) {
                      case 'connection':
                        final connectable = device as Connectable;
                        _change(
                          device.isConnected
                              ? connectable.disconnect
                              : connectable.connect,
                        );
                      case 'schedule':
                        onSchedule(device as SmartLight);
                      case 'clear-schedule':
                        _change((device as SmartLight).clearSchedule);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'connection',
                      child: Text(
                        device.isConnected
                            ? 'Disconnect device'
                            : 'Reconnect device',
                      ),
                    ),
                    if (device case final SmartLight light) ...[
                      const PopupMenuItem(
                        value: 'schedule',
                        child: Text('Schedule power toggle'),
                      ),
                      if (light.scheduledTime != null)
                        const PopupMenuItem(
                          value: 'clear-schedule',
                          child: Text('Cancel schedule'),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (device case final SmartLight light)
            _buildLight(context, light)
          else if (device case final Thermostat thermostat)
            _buildThermostat(thermostat)
          else if (device case final SmartSpeaker speaker)
            _buildSpeaker(speaker),
        ],
      ),
    );
  }

  Widget _buildLight(BuildContext context, SmartLight light) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _Status(device: light)),
            Semantics(
              label: '${light.name} power',
              child: Switch(
                key: ValueKey('power-${light.id}'),
                value: light.isOn,
                onChanged: light.isConnected
                    ? (_) => _change(light.togglePower)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ValueLabel(label: 'Brightness', value: '${light.brightness}%'),
        Slider(
          key: ValueKey('brightness-${light.id}'),
          value: light.brightness.toDouble(),
          max: 100,
          divisions: 100,
          label: '${light.brightness}%',
          semanticFormatterCallback: (value) =>
              '${value.round()} percent brightness',
          onChanged: light.isConnected && light.isOn
              ? (value) => _change(() => light.setBrightness(value.round()))
              : null,
        ),
        if (light.scheduledTime case final DateTime time) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.schedule_rounded, size: 15, color: _blue),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Scheduled toggle · ${time.day}/${time.month} · ${TimeOfDay.fromDateTime(time).format(context)}',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildThermostat(Thermostat thermostat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Status(device: thermostat),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton.outlined(
              key: ValueKey('temperature-down-${thermostat.id}'),
              tooltip: 'Decrease temperature',
              onPressed:
                  thermostat.isConnected &&
                      thermostat.temperature > Thermostat.minTemperature
                  ? () => _change(thermostat.decreaseTemperature)
                  : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${thermostat.temperature}°C',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 34,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    'Target temperature',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              key: ValueKey('temperature-up-${thermostat.id}'),
              tooltip: 'Increase temperature',
              onPressed:
                  thermostat.isConnected &&
                      thermostat.temperature < Thermostat.maxTemperature
                  ? () => _change(thermostat.increaseTemperature)
                  : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Room ${thermostat.ambientTemperature}°C  ·  Range 16–30°C',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeaker(SmartSpeaker speaker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _Status(device: speaker)),
            IconButton.filled(
              key: ValueKey('playback-${speaker.id}'),
              tooltip: speaker.isPlaying ? 'Pause speaker' : 'Play speaker',
              onPressed: speaker.isConnected
                  ? () => _change(speaker.togglePlayback)
                  : null,
              icon: Icon(
                speaker.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ValueLabel(label: 'Volume', value: '${speaker.volume}%'),
        Slider(
          key: ValueKey('volume-${speaker.id}'),
          value: speaker.volume.toDouble(),
          max: 100,
          divisions: 100,
          label: '${speaker.volume}%',
          semanticFormatterCallback: (value) =>
              '${value.round()} percent volume',
          onChanged: speaker.isConnected
              ? (value) => _change(() => speaker.setVolume(value.round()))
              : null,
        ),
      ],
    );
  }
}

class _ValueLabel extends StatelessWidget {
  const _ValueLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.device});

  final SmartDevice device;

  @override
  Widget build(BuildContext context) {
    // Polymorphism: the card asks the base type for subclass-specific status.
    final status = device.getStatus();
    final active = device.isConnected && status != 'Off' && status != 'Paused';
    final color = active ? const Color(0xFF258366) : _muted;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF6F0) : const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
