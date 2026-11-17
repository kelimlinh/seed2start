import 'package:cloud_firestore/cloud_firestore.dart';

enum AccessCodeLookupFailure {
  permissionDenied,
  unavailable,
}

class AccessCodeLookupException implements Exception {
  const AccessCodeLookupException(this.failure, [this.cause]);

  final AccessCodeLookupFailure failure;
  final Object? cause;

  @override
  String toString() => 'AccessCodeLookupException($failure, $cause)';
}

class AccessCodeService {
  AccessCodeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String normalize(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static bool isValid(String value) => normalize(value).length == 6;

  Future<String?> resolveResourceId(String rawCode) async {
    final code = normalize(rawCode);
    if (code.length != 6) return null;

    try {
      final snapshot =
          await _firestore.collection('accessCodes').doc(code).get();
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data['active'] != true) return null;

      final resourceId = data['resourceId'];
      if (resourceId is! String || resourceId.trim().isEmpty) return null;

      return resourceId.trim();
    } on FirebaseException catch (error) {
      if (error.code == 'not-found') return null;
      if (error.code == 'permission-denied') {
        throw AccessCodeLookupException(
          AccessCodeLookupFailure.permissionDenied,
          error,
        );
      }
      throw AccessCodeLookupException(
        AccessCodeLookupFailure.unavailable,
        error,
      );
    }
  }
}
