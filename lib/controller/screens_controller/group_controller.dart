import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroupsStream() {
    if (currentUserId == null) return const Stream.empty();
    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
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

  Future<void> sendMoneyToGroup(
    String groupId,
    List<String> members,
    double amount,
  ) async {
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

  Future<void> createGroup(
    String name,
    String info,
    List<String> memberUids,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final members = [currentUser.uid, ...memberUids];

    final groupDocRef = await _firestore.collection('groups').add({
      "name": name,
      "info": info,
      "members": members,
      "createdBy": currentUser.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await groupDocRef.update({"id": groupDocRef.id});
  }

  Future<void> editGroup({
    required String groupId,
    String? name,
    String? info,
    List<String>? memberUids,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (info != null) updateData['info'] = info;
    if (memberUids != null) {
      final members = [currentUser.uid, ...memberUids];
      updateData['members'] = members;
    }

    if (updateData.isNotEmpty) {
      await _firestore.collection('groups').doc(groupId).update(updateData);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();

    final txSnapshot = await _firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .get();

    for (var doc in txSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Map<String, dynamic>>> loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final friendUids = List<String>.from(userDoc['friends'] ?? []);
    List<Map<String, dynamic>> temp = [];

    for (String uid in friendUids) {
      final friendDoc = await _firestore.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        temp.add({'uid': friendDoc.id, ...friendDoc.data()!});
      }
    }

    return temp;
  }

  /// ✅ NEW FUNCTION — GET USER NAME BY UID
  Future<String> getUserName(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (!doc.exists) return uid; // fallback to UID
    return doc['name'] ?? uid;
  }
}