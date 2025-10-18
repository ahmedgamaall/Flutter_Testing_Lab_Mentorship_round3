import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';

void main() {
  // ============================================
  // WIDGET TESTS - Testing UI and user interactions
  // ============================================
  // These tests render the actual widget and simulate user actions
  // like typing text, tapping buttons, and checking what appears on screen

  group('User Registration Form Widget Tests', () {
    // Helper function to wrap our widget in a MaterialApp
    // (Required for Flutter widgets to work properly in tests)
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: UserRegistrationForm(),
        ),
      );
    }

    testWidgets('should display all form fields', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ASSERT: Check that all fields are present on screen
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('should show error when name is empty', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Tap the Register button without filling the form
      await tester.tap(find.text('Register'));
      await tester.pump(); // Rebuild the widget after tap

      // ASSERT: Error message should appear
      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('should show error when name is too short', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter a single character name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'A',
      );
      await tester.tap(find.text('Register'));
      await tester.pump();

      // ASSERT: Should show "too short" error
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('should show error for invalid email format', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter invalid emails and tap Register
      final invalidEmails = ['a@', '@b', 'nodomain', 'no@domain'];

      for (final email in invalidEmails) {
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          email,
        );
        await tester.tap(find.text('Register'));
        await tester.pump();

        // ASSERT: Error message should appear
        expect(
          find.text('Please enter a valid email'),
          findsOneWidget,
          reason: 'Email "$email" should show error',
        );

        // Clear the field for next test
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          '',
        );
      }
    });

    testWidgets('should accept valid email format', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter a valid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.text('Register'));
      await tester.pump();

      // ASSERT: Should NOT show email error (other errors might appear)
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('should show error for weak password', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter weak passwords
      final weakPasswords = [
        'short1!',        // Too short
        'NoNumbers!',     // No numbers
        'NoSpecial123',   // No special chars
      ];

      for (final password in weakPasswords) {
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          password,
        );
        await tester.tap(find.text('Register'));
        await tester.pump();

        // ASSERT: Error should appear
        expect(
          find.text('Password is too weak'),
          findsOneWidget,
          reason: 'Password "$password" should be rejected',
        );

        // Clear for next test
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          '',
        );
      }
    });

    testWidgets('should show error when passwords do not match', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter different passwords
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Password1!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'DifferentPass1!',
      );
      await tester.tap(find.text('Register'));
      await tester.pump();

      // ASSERT: Mismatch error should appear
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should submit successfully with valid data', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Fill all fields with valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'john.doe@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'SecurePass123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'SecurePass123!',
      );

      // Tap submit button
      await tester.tap(find.text('Register'));
      await tester.pump(); // Start the async operation

      // ASSERT: Loading indicator should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the simulated API call to complete (2 seconds)
      await tester.pumpAndSettle();

      // ASSERT: Success message should appear
      expect(find.text('Registration successful!'), findsOneWidget);
    });

    testWidgets('should not submit with invalid data', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'SecurePass123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'SecurePass123!',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      // ASSERT: Should NOT show loading indicator (form validation failed)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Should NOT show success message
      expect(find.text('Registration successful!'), findsNothing);
    });

    testWidgets('should obscure password fields', (WidgetTester tester) async {
      // ARRANGE: Build the widget
      await tester.pumpWidget(createTestWidget());

      // ACT: Find all TextField widgets
      final textFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );

      // ASSERT: Count how many have obscureText enabled
      final obscuredFields = textFields.where((field) => field.obscureText).length;

      // Should have 2 obscured fields (Password and Confirm Password)
      expect(obscuredFields, 2);
    });
  });
}
