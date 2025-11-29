import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  group('UserRepository', () {
    test('password hashing is consistent', () {
      final password = 'testPassword123';
      final bytes1 = utf8.encode(password);
      final hash1 = sha256.convert(bytes1).toString();

      final bytes2 = utf8.encode(password);
      final hash2 = sha256.convert(bytes2).toString();

      expect(hash1, equals(hash2));
    });

    test('different passwords produce different hashes', () {
      final password1 = 'password1';
      final password2 = 'password2';

      final hash1 = sha256.convert(utf8.encode(password1)).toString();
      final hash2 = sha256.convert(utf8.encode(password2)).toString();

      expect(hash1, isNot(equals(hash2)));
    });

    test('UserModel validates required fields', () {
      final validUser = UserModel(
        userId: 'user123',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(validUser.validateRequiredFields(), isNull);

      final invalidUser = UserModel(
        userId: '',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(invalidUser.validateRequiredFields(), isNotNull);
    });

    test('UserModel copyWith creates new instance with updated fields', () {
      final user = UserModel(
        userId: 'user123',
        passwordHash: 'hashed',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
        isActive: true,
      );

      final updatedUser = user.copyWith(isActive: false);

      expect(updatedUser.userId, equals(user.userId));
      expect(updatedUser.isActive, false);
      expect(user.isActive, true); // Original unchanged
    });
  });
}
