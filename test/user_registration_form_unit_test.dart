import 'package:flutter_test/flutter_test.dart';

void main() {


  // Create a helper instance to access validation methods
  late _UserRegistrationFormStateTestHelper helper;

  setUp(() {
    // This runs before each test
    // We create a helper object to access the validation methods
    helper = _UserRegistrationFormStateTestHelper();
  });

  // GROUP: Email Validation Tests
  // Testing the isValidEmail() function with different inputs
  group('Email Validation Unit Tests', () {
    test('should accept valid email addresses', () {
      // ARRANGE: Set up test data
      const validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'first.last@company.org',
        'user+tag@gmail.com',
      ];

      // ACT & ASSERT: Test each valid email
      for (final email in validEmails) {
        expect(
          helper.isValidEmail(email),
          true,
          reason: '$email should be valid',
        );
      }
    });

    test('should reject invalid email addresses', () {
      // These are emails that should FAIL validation
      const invalidEmails = [
        'a@',           // Missing domain
        '@b',           // Missing username
        'nodomain',     // No @ symbol
        'no@domain',    // Missing top-level domain (.com, .org, etc.)
        '@',            // Just @ symbol
        '',             // Empty string
        'spaces in@email.com',  // Spaces not allowed
      ];

      // ACT & ASSERT: Each should return false
      for (final email in invalidEmails) {
        expect(
          helper.isValidEmail(email),
          false,
          reason: '$email should be invalid',
        );
      }
    });
  });

  // GROUP: Password Validation Tests
  // Testing the isValidPassword() function
  group('Password Validation Unit Tests', () {
    test('should accept strong passwords', () {
      // Valid passwords: 8+ chars, has number, has special char
      const validPasswords = [
        'Password1!',
        'SecurePass123@',
        'MyP@ssw0rd',
        '12345678!A',
      ];

      for (final password in validPasswords) {
        expect(
          helper.isValidPassword(password),
          true,
          reason: '$password should be valid',
        );
      }
    });

    test('should reject passwords shorter than 8 characters', () {
      // Too short, even with numbers and special chars
      expect(helper.isValidPassword('Pass1!'), false);
      expect(helper.isValidPassword('a1!'), false);
    });

    test('should reject passwords without numbers', () {
      // 8+ chars and special char, but NO number
      expect(helper.isValidPassword('Password!'), false);
      expect(helper.isValidPassword('NoNumbers@Here'), false);
    });

    test('should reject passwords without special characters', () {
      // 8+ chars and number, but NO special char
      expect(helper.isValidPassword('Password1'), false);
      expect(helper.isValidPassword('NoSpecial123'), false);
    });

    test('should reject empty passwords', () {
      expect(helper.isValidPassword(''), false);
    });
  });
}



class _UserRegistrationFormStateTestHelper {
  // Same email validation logic as the real widget
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Same password validation logic as the real widget
  bool isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }
}
