import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_devices.dart';
import '../models/devices.dart';
import '../widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<SmartDevice> _devices;
  Timer? _scheduleTimer;
  String _selectedRoom = 'All rooms';

  @override
  void initState() {
    super.initState();
    _devices = createDemoDevices();
    // Schedules run in this local simulation only while the app is open.
    _scheduleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      var changed = false;
      for (final light in _devices.whereType<SmartLight>()) {
        if (light.runScheduleIfDue(now)) changed = true;
      }
      if (changed && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _schedule(SmartLight light) async {
    final chosen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(minutes: 1)),
      ),
      helpText: 'Schedule a power toggle',
    );
    if (chosen == null || !mounted) return;
    final current = DateTime.now();
    var due = DateTime(
      current.year,
      current.month,
      current.day,
      chosen.hour,
      chosen.minute,
    );
    if (!due.isAfter(current)) due = due.add(const Duration(days: 1));
    setState(() => light.schedule(due));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${light.name}: toggle scheduled for ${due.day}/${due.month} at ${chosen.format(context)}.',
        ),
      ),
    );
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Made for a smarter home'),
        content: const SingleChildScrollView(
          child: Text(
            'BIM493 Mobile Programming I\nAssignment #2 · Smart Home Controller\n\n'
            'Tarık Ata Kılıç\n40312440132\n\n'
            'Ata Turan\n22652290356\n\n'
            'A local Flutter simulation. Controls change device objects; '
            'no physical devices or accounts are needed. State resets when '
            'the app restarts. Scheduled actions run while the app is open.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connected = _devices.where((d) => d.isConnected).length;
    final rooms = ['All rooms', ..._devices.map((d) => d.room).toSet()];
    final visible = _devices
        .where((d) => _selectedRoom == 'All rooms' || d.room == _selectedRoom)
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            82 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3265E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.roofing_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HAVEN',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'Smart Home Controller',
                    style: TextStyle(fontSize: 12, color: Color(0xFF67768D)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('about'),
            tooltip: 'About this project',
            onPressed: _showAbout,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          key: const ValueKey('home-scroll'),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeBanner(connected: connected, total: _devices.length),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your devices',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_devices.length} devices',
                        style: const TextStyle(color: Color(0xFF67768D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: rooms
                          .map(
                            (room) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                key: ValueKey('room-$room'),
                                label: Text(room),
                                selected: _selectedRoom == room,
                                showCheckmark: false,
                                selectedColor: const Color(0xFF172A45),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: _selectedRoom == room
                                      ? Colors.transparent
                                      : const Color(0xFFE3E8F1),
                                ),
                                labelStyle: TextStyle(
                                  color: _selectedRoom == room
                                      ? Colors.white
                                      : const Color(0xFF67768D),
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onSelected: (_) =>
                                    setState(() => _selectedRoom = room),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 700 ? 2 : 1;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 18) / columns;
                      return Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: visible
                            .map(
                              (device) => SizedBox(
                                width: width,
                                child: DeviceCard(
                                  key: ValueKey('card-${device.id}'),
                                  device: device,
                                  onChanged: _refresh,
                                  onSchedule: _schedule,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 15,
                        color: Color(0xFF5C6B80),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Local demo · Your home, at your fingertips',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5C6B80),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE3E8F1))),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              // This must come from the static class variable, not devices.length.
              Text(
                'Total devices created: ${SmartDevice.totalDevicesCreated}',
                key: const ValueKey('device-count'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'BIM493 · HW02',
                style: TextStyle(fontSize: 11, color: Color(0xFF5C6B80)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.connected, required this.total});
  final int connected;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF233E78), Color(0xFF3265E8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WELCOME HOME',
          style: TextStyle(
            color: Color(0xFFBED2FF),
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your home,\nin harmony.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Icon(
              connected == total
                  ? Icons.check_circle_rounded
                  : Icons.wifi_off_rounded,
              size: 16,
              color: const Color(0xFFB4F5D6),
            ),
            Text(
              '$connected of $total devices connected',
              key: const ValueKey('connection-count'),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}
