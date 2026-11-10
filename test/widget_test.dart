import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('splash screen shows the DakirTV brand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('DakirTV'), findsOneWidget);
    expect(find.text('Live television, reimagined.'), findsOneWidget);
  });
}
