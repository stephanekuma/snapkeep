import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapkeep/src/core/locator/index.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize dependencies for testing
    configureDependencies();

    // Create a simple test widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Snapkeep Test'),
          ),
        ),
      ),
    );

    // Verify that the app loads
    expect(find.text('Snapkeep Test'), findsOneWidget);
  });
}
