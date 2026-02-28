import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_cred_model.dart';

class AuthService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _adminCredRef => _firestore.collection('admin-cred');

  /// Authenticate admin by matching email & password in admin-cred collection.
  /// Each doc in admin-cred represents one admin user.
  Future<AdminCredModel?> login(String email, String password) async {
    final snapshot = await _adminCredRef
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final admin = AdminCredModel.fromJson(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );

    // Update last login timestamp
    await doc.reference.update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });

    return admin;
  }
}
