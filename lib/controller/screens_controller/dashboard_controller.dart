import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Load all friends of user
  Future<List<Map<String, dynamic>>> getFriends() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);
    List<Map<String, dynamic>> result = [];

    for (String uid in friendUids) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        result.add({'uid': doc.id, ...?doc.data()});
      }
    }

    return result;
  }

  /// Gets all groups that contain current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('groups')
        .where('members', arrayContains: user.uid)
        .snapshots();
  }
}
