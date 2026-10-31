import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_test/main.dart';

void main() {
  testWidgets('Pressing button changes color from Blue to Red', (tester) async {
    // 1. Load widget (MaterialApp gives themes & direction)
    await tester.pumpWidget(const MaterialApp(home: ColorChangeApp()));

    // 2. Check initial color is Blue
    Container boxBefore = tester.widget<Container>(
      find.byKey(const Key('color_box')),
    );
    expect(boxBefore.color, Colors.blue);

    // 3. Verify button exists and tap it
    expect(find.text('Change to Red'), findsOneWidget);
    await tester.tap(find.text('Change to Red'));

    // 4. Wait for screen to rebuild
    await tester.pump();

    // 5. Check color changed to Red
    Container after = tester.widget<Container>(
      find.byKey(const Key('color_box')),
    );
    expect(after.color, Colors.red);
  });
}
