import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:widget_test/main.dart';

void main() {
  patrolTest('taps "Change to Red" button and verifies color change', (
    $,
  ) async {
    // 1. Pump the app
    await $.pumpWidgetAndSettle(const MaterialApp(home: ColorChangeApp()));

    // 2. Verify button is displayed
    expect($('Change to Red'), findsOneWidget);

    // Verify initial blue color
    final initialBox = $.tester.widget<Container>($(const Key('color_box')));
    expect(initialBox.color, Colors.blue);

    // 3. Tap the button using Patrol finder
    await $('Change to Red').tap();

    // 4. Verify the container color changed to red
    final updatedBox = $.tester.widget<Container>($(const Key('color_box')));
    expect(updatedBox.color, Colors.red);

    // Keep the app open on screen for 10 seconds so you can see it!
    await Future<void>.delayed(const Duration(minutes: 2));
  });
}
