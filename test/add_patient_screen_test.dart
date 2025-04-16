import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/screens/add_patient_screen.dart';

void main() {
  group('AddPatientScreen Widget Tests', () {
    testWidgets('should render all form fields initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Verify all form fields are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextFormField),
          findsAtLeastNWidgets(3)); // Name, Address, Contact
      expect(find.byType(DropdownButtonFormField<String>),
          findsOneWidget); // Gender
      expect(find.byIcon(Icons.person_outline), findsAtLeastNWidgets(2));
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('should show validation error for empty name',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Try to submit the form without filling required fields
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify name validation error message
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should validate phone number format',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Find phone field using the hint text
      final phoneField =
          find.widgetWithText(TextFormField, 'Enter 10 digit number');
      await tester.enterText(phoneField, '123');

      // Try to submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify phone validation error
      expect(
          find.text('Phone number must be exactly 10 digits'), findsOneWidget);
    });

    testWidgets('should show gender dropdown options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Find and tap the gender dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Find dropdown items in the overlay
      expect(find.text('Male'), findsWidgets);
      expect(find.text('Female'), findsWidgets);
      expect(find.text('Other'), findsWidgets);
    });

    testWidgets('should validate name length', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Find name field using label text
      final nameField = find.ancestor(
        of: find.text('Patient Name *'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(nameField, 'A');

      // Try to submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify name length validation error
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('should format phone number correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Find phone field using hint text
      final phoneField =
          find.widgetWithText(TextFormField, 'Enter 10 digit number');

      // Enter phone number with non-digit characters
      await tester.enterText(phoneField, '1234567890');
      await tester.pump();

      // Get the TextField widget and verify text
      final textField = tester.widget<TextFormField>(phoneField);
      expect(textField.controller?.text, '1234567890');
    });

    testWidgets('should show loading state when saving',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddPatientScreen(),
      ));

      // Fill required fields
      final nameField = find.ancestor(
        of: find.text('Patient Name *'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(nameField, 'John Doe');

      // Select date
      await tester.tap(find.text('Select Date of Birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Select gender
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      // Submit form to trigger loading state
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
