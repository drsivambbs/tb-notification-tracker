import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tb_notification_tracker/models/case_model.dart';
import 'package:tb_notification_tracker/models/user_model.dart';

/// Filter parameters for case queries
class CaseFilter {
  final String? phcName;
  final DateTime? startDate;
  final DateTime? endDate;
  final CaseStatus? status;
  final String? searchQuery;

  CaseFilter({
    this.phcName,
    this.startDate,
    this.endDate,
    this.status,
    this.searchQuery,
  });
}

/// Repository for case data operations
abstract class CaseRepository {
  /// Get cases with optional filtering and role-based scoping
  Future<List<CaseModel>> getCases({
    required UserModel currentUser,
    CaseFilter? filter,
  });

  /// Get a case by ID
  Future<CaseModel?> getCaseById(String caseId);

  /// Create a new case
  Future<String> createCase(CaseModel caseModel);

  /// Update a case
  Future<void> updateCase(String caseId, Map<String, dynamic> updates);

  /// Delete a case
  Future<void> deleteCase(String caseId);

  /// Check if Nikshay ID already exists
  Future<bool> nikshayIdExists(String nikshayId, {String? excludeCaseId});

  /// Watch cases in real-time
  Stream<List<CaseModel>> watchCases({
    required UserModel currentUser,
    CaseFilter? filter,
  });
}

/// Firestore implementation of CaseRepository
class FirestoreCaseRepository implements CaseRepository {
  final FirebaseFirestore _firestore;

  FirestoreCaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CaseModel>> getCases({
    required UserModel currentUser,
    CaseFilter? filter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('cases');

      // Apply role-based data scoping
      query = _applyRoleBasedScoping(query, currentUser, filter);

      // Apply date range filter
      if (filter?.startDate != null) {
        query = query.where(
          'created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter!.startDate!),
        );
      }
      if (filter?.endDate != null) {
        final endOfDay = DateTime(
          filter!.endDate!.year,
          filter.endDate!.month,
          filter.endDate!.day,
          23,
          59,
          59,
        );
        query = query.where(
          'created_at',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        );
      }

      // Apply status filter
      if (filter?.status != null) {
        query = query.where('case_status', isEqualTo: filter!.status!.value);
      }

      // Order by created date (most recent first)
      query = query.orderBy('created_at', descending: true);

      final snapshot = await query.get();
      var cases = snapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();

      // Apply search filter (client-side for flexibility)
      if (filter?.searchQuery != null && filter!.searchQuery!.isNotEmpty) {
        final searchLower = filter.searchQuery!.toLowerCase();
        cases = cases.where((caseModel) {
          return caseModel.patientName.toLowerCase().contains(searchLower) ||
              caseModel.phoneNumber.contains(searchLower) ||
              (caseModel.nikshayId?.toLowerCase().contains(searchLower) ??
                  false);
        }).toList();
      }

      return cases;
    } catch (e) {
      throw Exception('Failed to fetch cases: $e');
    }
  }

  @override
  Future<CaseModel?> getCaseById(String caseId) async {
    try {
      final doc = await _firestore.collection('cases').doc(caseId).get();

      if (!doc.exists) {
        return null;
      }

      return CaseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch case: $e');
    }
  }

  @override
  Future<String> createCase(CaseModel caseModel) async {
    try {
      // Validate case data
      if (!caseModel.isValid()) {
        throw Exception('Invalid case data');
      }

      // Generate a unique case ID
      final docRef = _firestore.collection('cases').doc();
      final caseWithId = caseModel.copyWith(caseId: docRef.id);

      // Create case document
      await docRef.set(caseWithId.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create case: $e');
    }
  }

  @override
  Future<void> updateCase(String caseId, Map<String, dynamic> updates) async {
    try {
      // Check if case exists
      final doc = await _firestore.collection('cases').doc(caseId).get();
      if (!doc.exists) {
        throw Exception('Case not found');
      }

      // If Nikshay ID is being updated, check uniqueness
      if (updates.containsKey('nikshay_id') && updates['nikshay_id'] != null) {
        final nikshayId = updates['nikshay_id'] as String;
        if (nikshayId.isNotEmpty) {
          final exists = await nikshayIdExists(nikshayId, excludeCaseId: caseId);
          if (exists) {
            throw Exception('Nikshay ID already exists');
          }
        }
      }

      // Convert DateTime to Timestamp if present
      if (updates.containsKey('status_updated_at') &&
          updates['status_updated_at'] is DateTime) {
        updates['status_updated_at'] =
            Timestamp.fromDate(updates['status_updated_at'] as DateTime);
      }

      await _firestore.collection('cases').doc(caseId).update(updates);
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }

  @override
  Future<void> deleteCase(String caseId) async {
    try {
      await _firestore.collection('cases').doc(caseId).delete();
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  @override
  Future<bool> nikshayIdExists(String nikshayId,
      {String? excludeCaseId}) async {
    try {
      if (nikshayId.isEmpty) return false;

      final snapshot = await _firestore
          .collection('cases')
          .where('nikshay_id', isEqualTo: nikshayId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      // If excluding a case ID, check if the found case is different
      if (excludeCaseId != null) {
        return snapshot.docs.first.id != excludeCaseId;
      }

      return true;
    } catch (e) {
      throw Exception('Failed to check Nikshay ID: $e');
    }
  }

  @override
  Stream<List<CaseModel>> watchCases({
    required UserModel currentUser,
    CaseFilter? filter,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('cases');

      // Apply role-based data scoping
      query = _applyRoleBasedScoping(query, currentUser, filter);

      // Apply date range filter
      if (filter?.startDate != null) {
        query = query.where(
          'created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter!.startDate!),
        );
      }
      if (filter?.endDate != null) {
        final endOfDay = DateTime(
          filter!.endDate!.year,
          filter.endDate!.month,
          filter.endDate!.day,
          23,
          59,
          59,
        );
        query = query.where(
          'created_at',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        );
      }

      // Apply status filter
      if (filter?.status != null) {
        query = query.where('case_status', isEqualTo: filter!.status!.value);
      }

      // Order by created date
      query = query.orderBy('created_at', descending: true);

      return query.snapshots().map((snapshot) {
        var cases = snapshot.docs
            .map((doc) => CaseModel.fromFirestore(doc))
            .toList();

        // Apply search filter
        if (filter?.searchQuery != null && filter!.searchQuery!.isNotEmpty) {
          final searchLower = filter.searchQuery!.toLowerCase();
          cases = cases.where((caseModel) {
            return caseModel.patientName.toLowerCase().contains(searchLower) ||
                caseModel.phoneNumber.contains(searchLower) ||
                (caseModel.nikshayId?.toLowerCase().contains(searchLower) ??
                    false);
          }).toList();
        }

        return cases;
      });
    } catch (e) {
      throw Exception('Failed to watch cases: $e');
    }
  }

  /// Apply role-based data scoping to query
  Query<Map<String, dynamic>> _applyRoleBasedScoping(
    Query<Map<String, dynamic>> query,
    UserModel currentUser,
    CaseFilter? filter,
  ) {
    switch (currentUser.role) {
      case UserRole.adminUser:
        // Admin sees all cases, optionally filtered by PHC
        if (filter?.phcName != null) {
          query = query.where('phc_name', isEqualTo: filter!.phcName);
        }
        break;

      case UserRole.stsUser:
        // STS sees cases from their assigned PHC
        query = query.where('phc_name', isEqualTo: currentUser.phcName);
        break;

      case UserRole.phcUser:
        // PHC user sees only their own PHC's cases
        query = query.where('phc_name', isEqualTo: currentUser.phcName);
        break;
    }

    return query;
  }
}
