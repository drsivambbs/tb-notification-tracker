import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates user with all required fields', () {
      final user = UserModel(
        userId: 'user123',
        passwordHash: 'hashed_password',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(user.userId, 'user123');
      expect(user.role, UserRole.phcUser);
      expect(user.isActive, true);
    });

    test('validates required fields correctly', () {
      final validUser = UserModel(
        userId: 'user123',
        passwordHash: 'hashed_password',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(validUser.validateRequiredFields(), isNull);

      final invalidUser = UserModel(
        userId: '',
        passwordHash: 'hashed_password',
        role: UserRole.phcUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );

      expect(invalidUser.validateRequiredFields(), isNotNull);
    });

    test('toFirestore converts model to map correctly', () {
      final user = UserModel(
        userId: 'user123',
        passwordHash: 'hashed_password',
        role: UserRole.stsUser,
        phcName: 'PHC Central',
        email: 'user@example.com',
        phoneNumber: '9876543210',
        createdAt: DateTime(2024, 1, 1),
        isActive: false,
      );

      final map = user.toFirestore();

      expect(map['user_id'], 'user123');
      expect(map['role'], 'sts_user');
      expect(map['is_active'], false);
    });

    test('UserRole enum converts from string correctly', () {
      expect(UserRole.fromString('admin_user'), UserRole.adminUser);
      expect(UserRole.fromString('sts_user'), UserRole.stsUser);
      expect(UserRole.fromString('phc_user'), UserRole.phcUser);
    });

    test('UserRole enum throws on invalid string', () {
      expect(
        () => UserRole.fromString('invalid_role'),
        throwsArgumentError,
      );
    });
  });
}
