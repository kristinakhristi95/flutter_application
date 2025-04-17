import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/screens/patient_list_screen.dart';
import 'package:meditrack/models/patient.dart';

void main() {
  group('PatientListScreen Widget Tests', () {
    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should show search field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show refresh button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should show clear button when search has text',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Verify clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear search text when clear button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Find and tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Get the TextField widget
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('should show loading indicator when refresh button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientListScreen(),
      ));

      // Initial build
      await tester.pump();

      // Find and tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
