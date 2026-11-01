import '../models/devices.dart';

/// One object per card. Called in initState, never during build.
List<SmartDevice> createDemoDevices() => <SmartDevice>[
  // Unnamed/default constructor.
  SmartLight(id: 'living-light', name: 'Ceiling light', room: 'Living room'),
  Thermostat(id: 'bedroom-climate', name: 'Room climate', room: 'Bedroom'),
  // Named constructors are actually used, not just declared.
  SmartSpeaker.lounge(
    id: 'kitchen-speaker',
    name: 'Home speaker',
    room: 'Kitchen',
  ),
  SmartLight.reading(id: 'study-light', name: 'Reading lamp', room: 'Study'),
];
