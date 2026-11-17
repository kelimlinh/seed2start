import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<Map<String, dynamic>?> watchProfile() {
    final user = currentUser;
    if (user == null) {
      return Stream<Map<String, dynamic>?>.value(null);
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (snapshot) => snapshot.data(),
        );
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }

    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(displayName, 'displayName');
    }

    await Future.wait([
      _firestore.collection('users').doc(user.uid).update({
        'displayName': cleanName,
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      user.updateDisplayName(cleanName),
    ]);
  }

  Future<void> updateLocale(String languageCode) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'locale': languageCode,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
