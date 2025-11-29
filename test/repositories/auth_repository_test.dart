import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  group('AuthRepository', () {
    test('password hashing produces different output than input', () {
      final password = 'testPassword123';
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();
      
      expect(hashedPassword, isNot(equals(password)));
      expect(hashedPassword.length, greaterThan(password.length));
    });

    test('same password produces same hash', () {
      final password = 'testPassword123';
      final bytes1 = utf8.encode(password);
      final hash1 = sha256.convert(bytes1).toString();
      
      final bytes2 = utf8.encode(password);
      final hash2 = sha256.convert(bytes2).toString();
      
      expect(hash1, equals(hash2));
    });

    test('different passwords produce different hashes', () {
      final password1 = 'testPassword123';
      final password2 = 'testPassword456';
      
      final bytes1 = utf8.encode(password1);
      final hash1 = sha256.convert(bytes1).toString();
      
      final bytes2 = utf8.encode(password2);
      final hash2 = sha256.convert(bytes2).toString();
      
      expect(hash1, isNot(equals(hash2)));
    });

    test('UserModel can be created with hashed password', () {
      final password = 'testPassword123';
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();
      
      final user = UserModel(
        userId: 'user123',
        passwordHash: hashedPassword,
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(user.passwordHash, equals(hashedPassword));
      expect(user.passwordHash, isNot(equals(password)));
    });
  });
}
