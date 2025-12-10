import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ---------------- Existing function ----------------
  /// Load friends of current user (one-time fetch)
  Future<List<Map<String, dynamic>>> getFriends() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);

    List<Map<String, dynamic>> friends = [];
    for (String uid in friendUids) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) friends.add({'uid': doc.id, ...?doc.data()});
    }

    return friends;
  }

  /// ---------------- New function ----------------
  /// Real-time stream of friends
  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Listen to user's document changes
    return _firestore.collection('users').doc(user.uid).snapshots().asyncMap(
      (userDoc) async {
        final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);
        List<Map<String, dynamic>> friends = [];

        for (String uid in friendUids) {
          final doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists) friends.add({'uid': doc.id, ...?doc.data()});
        }

        return friends;
      },
    );
  }

  /// Add friend by UID
  Future<void> addFriend(String friendUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userRef = _firestore.collection('users').doc(currentUser.uid);

    await userRef.update({
      'friends': FieldValue.arrayUnion([friendUid])
    });
  }
}
