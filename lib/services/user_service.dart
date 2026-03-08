import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Stream all users, ordered by name.
  Stream<List<UserModel>> streamUsers() {
    return _usersRef
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return UserModel.fromJson(data);
            }).toList());
  }

  /// Toggle isPremium for a user.
  Future<void> togglePremium(String userId, bool isPremium) async {
    await _usersRef.doc(userId).update({'isPremium': isPremium});
  }
}
