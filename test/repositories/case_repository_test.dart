import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/models/case_model.dart';
import 'package:tb_notification_tracker/repositories/case_repository.dart';

void main() {
  group('CaseRepository', () {
    test('CaseFilter can be created with optional parameters', () {
      final filter = CaseFilter(
        phcName: 'PHC Central',
        status: CaseStatus.processing,
      );

      expect(filter.phcName, equals('PHC Central'));
      expect(filter.status, equals(CaseStatus.processing));
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.searchQuery, isNull);
    });

    test('CaseModel validates age correctly', () {
      final validCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(validCase.validateAge(), isNull);

      final invalidCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 150,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(invalidCase.validateAge(), isNotNull);
    });

    test('CaseModel validates phone number correctly', () {
      final validCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(validCase.validatePhoneNumber(), isNull);

      final invalidCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '123',
      );

      expect(invalidCase.validatePhoneNumber(), isNotNull);
    });

    test('CaseModel validates Nikshay ID requirement', () {
      final caseWithoutId = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.nikshayIdGiven,
      );

      expect(caseWithoutId.validateNikshayId(), isNotNull);

      final caseWithId = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.nikshayIdGiven,
        nikshayId: 'NIK123456',
      );

      expect(caseWithId.validateNikshayId(), isNull);
    });

    test('CaseModel isValid checks all validations', () {
      final validCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.processing,
      );

      expect(validCase.isValid(), true);

      final invalidCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 150, // Invalid age
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.processing,
      );

      expect(invalidCase.isValid(), false);
    });

    test('CaseModel copyWith creates new instance with updated fields', () {
      final caseModel = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.processing,
      );

      final updatedCase = caseModel.copyWith(
        caseStatus: CaseStatus.nikshayIdGiven,
        nikshayId: 'NIK123456',
      );

      expect(updatedCase.caseId, equals(caseModel.caseId));
      expect(updatedCase.caseStatus, equals(CaseStatus.nikshayIdGiven));
      expect(updatedCase.nikshayId, equals('NIK123456'));
      expect(caseModel.caseStatus, equals(CaseStatus.processing)); // Original unchanged
    });
  });
}
