import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing case status
enum CaseStatus {
  processing('Processing'),
  unableToContact('Unable to Contact'),
  nikshayIdGiven('NIKSHAY ID given');

  final String value;
  const CaseStatus(this.value);

  static CaseStatus fromString(String value) {
    return CaseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid case status: $value'),
    );
  }
}

/// Enum representing patient gender
enum Gender {
  male('Male'),
  female('Female'),
  other('Other'),
  unknown('Unknown');

  final String value;
  const Gender(this.value);

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => throw ArgumentError('Invalid gender: $value'),
    );
  }
}

/// Case model representing a TB case notification
class CaseModel {
  final String caseId;
  final String phcName;
  final String createdByUserId;
  final DateTime createdAt;
  final String patientName;
  final int patientAge;
  final Gender patientGender;
  final String phoneNumber;
  final CaseStatus caseStatus;
  final String? nikshayId;
  final String? statusUpdatedBy;
  final DateTime? statusUpdatedAt;

  CaseModel({
    required this.caseId,
    required this.phcName,
    required this.createdByUserId,
    required this.createdAt,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.phoneNumber,
    this.caseStatus = CaseStatus.processing,
    this.nikshayId,
    this.statusUpdatedBy,
    this.statusUpdatedAt,
  });

  /// Convert CaseModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'case_id': caseId,
      'phc_name': phcName,
      'created_by_user_id': createdByUserId,
      'created_at': Timestamp.fromDate(createdAt),
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_gender': patientGender.value,
      'phone_number': phoneNumber,
      'case_status': caseStatus.value,
      'nikshay_id': nikshayId,
      'status_updated_by': statusUpdatedBy,
      'status_updated_at': statusUpdatedAt != null 
          ? Timestamp.fromDate(statusUpdatedAt!) 
          : null,
    };
  }

  /// Create CaseModel from Firestore document
  factory CaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseModel(
      caseId: data['case_id'] as String,
      phcName: data['phc_name'] as String,
      createdByUserId: data['created_by_user_id'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      patientName: data['patient_name'] as String,
      patientAge: data['patient_age'] as int,
      patientGender: Gender.fromString(data['patient_gender'] as String),
      phoneNumber: data['phone_number'] as String,
      caseStatus: CaseStatus.fromString(data['case_status'] as String),
      nikshayId: data['nikshay_id'] as String?,
      statusUpdatedBy: data['status_updated_by'] as String?,
      statusUpdatedAt: data['status_updated_at'] != null
          ? (data['status_updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Validate patient age (must be between 0 and 120)
  String? validateAge() {
    if (patientAge < 0 || patientAge > 120) {
      return 'Patient age must be between 0 and 120';
    }
    return null;
  }

  /// Validate phone number format
  /// Accepts 10-digit Indian phone numbers
  String? validatePhoneNumber() {
    // Remove any spaces, dashes, or parentheses
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it's a valid 10-digit number
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Phone number must be a valid 10-digit number';
    }
    
    return null;
  }

  /// Validate Nikshay ID
  /// Nikshay ID is required when case status is "NIKSHAY ID given"
  String? validateNikshayId() {
    if (caseStatus == CaseStatus.nikshayIdGiven) {
      if (nikshayId == null || nikshayId!.trim().isEmpty) {
        return 'Nikshay ID is required when status is "NIKSHAY ID given"';
      }
    }
    return null;
  }

  /// Validate all fields
  bool isValid() {
    return validateAge() == null &&
        validatePhoneNumber() == null &&
        validateNikshayId() == null;
  }

  /// Create a copy of CaseModel with updated fields
  CaseModel copyWith({
    String? caseId,
    String? phcName,
    String? createdByUserId,
    DateTime? createdAt,
    String? patientName,
    int? patientAge,
    Gender? patientGender,
    String? phoneNumber,
    CaseStatus? caseStatus,
    String? nikshayId,
    String? statusUpdatedBy,
    DateTime? statusUpdatedAt,
  }) {
    return CaseModel(
      caseId: caseId ?? this.caseId,
      phcName: phcName ?? this.phcName,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      caseStatus: caseStatus ?? this.caseStatus,
      nikshayId: nikshayId ?? this.nikshayId,
      statusUpdatedBy: statusUpdatedBy ?? this.statusUpdatedBy,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    );
  }
}
