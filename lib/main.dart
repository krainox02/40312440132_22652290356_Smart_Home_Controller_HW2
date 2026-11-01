import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const SmartHomeApp());

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF172A45);
    const blue = Color(0xFF3265E8);
    return MaterialApp(
      title: 'Haven | Smart Home Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Roboto',
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: navy,
          displayColor: navy,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          foregroundColor: navy,
          scrolledUnderElevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(backgroundColor: blue),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: blue,
          thumbColor: blue,
          inactiveTrackColor: Color(0xFFE5EAF4),
          trackHeight: 5,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
