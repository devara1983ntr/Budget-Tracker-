// Budget Tracker widget tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/main.dart';

void main() {
  testWidgets('Budget Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen loads
    expect(find.text('Budget Tracker'), findsOneWidget);
    expect(find.text('Created with ❤️ by'), findsOneWidget);
    expect(find.text('Roshan'), findsOneWidget);
  });
}
