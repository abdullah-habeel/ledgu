import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Stream of groups where current user is a member
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroupsStream() {
    if (currentUserId == null) {
      // return empty stream if not logged in
      return const Stream.empty();
    }
    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots();
  }

  Future<void> sendMoneyToFriend(String friendUid, double amount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('transactions').add({
      'from': currentUser.uid,
      'to': friendUid,
      'amount': amount,
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMoneyToGroup(String groupId, List<String> members, double amount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('transactions').add({
      'from': currentUser.uid,
      'toList': members,
      'groupId': groupId,
      'amount': amount,
      'time': FieldValue.serverTimestamp(),
    });
  }
}
