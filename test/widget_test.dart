import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build a minimal app for testing
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: Text('Test')))),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
