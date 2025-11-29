import 'package:flutter_test/flutter_test.dart';
import 'package:tb_notification_tracker/models/case_model.dart';

void main() {
  group('CaseModel', () {
    test('creates case with all required fields', () {
      final caseModel = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(caseModel.caseId, 'case123');
      expect(caseModel.caseStatus, CaseStatus.processing);
      expect(caseModel.nikshayId, isNull);
    });

    test('validateAge accepts valid ages', () {
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
    });

    test('validateAge rejects ages below 0', () {
      final invalidCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: -1,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(invalidCase.validateAge(), isNotNull);
    });

    test('validateAge rejects ages above 120', () {
      final invalidCase = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 121,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      expect(invalidCase.validateAge(), isNotNull);
    });

    test('validateAge accepts boundary values 0 and 120', () {
      final case0 = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 0,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
      );

      final case120 = CaseModel(
        caseId: 'case124',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'Jane Doe',
        patientAge: 120,
        patientGender: Gender.female,
        phoneNumber: '9876543210',
      );

      expect(case0.validateAge(), isNull);
      expect(case120.validateAge(), isNull);
    });

    test('validatePhoneNumber accepts valid 10-digit numbers', () {
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
    });

    test('validatePhoneNumber rejects invalid formats', () {
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

    test('validatePhoneNumber accepts numbers with formatting', () {
      final caseWithSpaces = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime.now(),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '987 654 3210',
      );

      expect(caseWithSpaces.validatePhoneNumber(), isNull);
    });

    test('validateNikshayId requires ID when status is nikshayIdGiven', () {
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

    test('validateNikshayId allows empty ID for other statuses', () {
      final processingCase = CaseModel(
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

      expect(processingCase.validateNikshayId(), isNull);
    });

    test('Gender enum converts from string correctly', () {
      expect(Gender.fromString('Male'), Gender.male);
      expect(Gender.fromString('Female'), Gender.female);
      expect(Gender.fromString('Other'), Gender.other);
      expect(Gender.fromString('Unknown'), Gender.unknown);
    });

    test('Gender enum throws on invalid string', () {
      expect(
        () => Gender.fromString('invalid'),
        throwsArgumentError,
      );
    });

    test('CaseStatus enum converts from string correctly', () {
      expect(CaseStatus.fromString('Processing'), CaseStatus.processing);
      expect(CaseStatus.fromString('Unable to Contact'), CaseStatus.unableToContact);
      expect(CaseStatus.fromString('NIKSHAY ID given'), CaseStatus.nikshayIdGiven);
    });

    test('toFirestore converts model to map correctly', () {
      final caseModel = CaseModel(
        caseId: 'case123',
        phcName: 'PHC Central',
        createdByUserId: 'user123',
        createdAt: DateTime(2024, 1, 1),
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: Gender.male,
        phoneNumber: '9876543210',
        caseStatus: CaseStatus.processing,
      );

      final map = caseModel.toFirestore();

      expect(map['case_id'], 'case123');
      expect(map['patient_gender'], 'Male');
      expect(map['case_status'], 'Processing');
      expect(map['patient_age'], 45);
    });
  });
}
