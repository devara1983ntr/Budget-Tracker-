import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/main.dart';

void main() {
  testWidgets('Budget Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudgetTrackerApp());

    // Verify that we start with splash screen or navigation
    expect(find.text('Budget Tracker'), findsOneWidget);
  });
}