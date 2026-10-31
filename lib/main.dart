import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ColorChangeApp()));
}

class ColorChangeApp extends StatefulWidget {
  const ColorChangeApp({super.key});

  @override
  State<ColorChangeApp> createState() => _ColorChangeAppState();
}

class _ColorChangeAppState extends State<ColorChangeApp> {
  Color _currentColor = Colors.blue;

  void _toggleColor() {
    setState(() {
      _currentColor = Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: const Key('color_box',), // Key so our widget test can find this container
        color: _currentColor,
        child: Center(
          child: ElevatedButton(
            onPressed: _toggleColor,
            child: const Text('Change to Red'),
          ),
        ),
      ),
    );
  }
}
