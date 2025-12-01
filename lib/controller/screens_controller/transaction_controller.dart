import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get username by UID
  Future<String> getUserName(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return uid;
    return (doc.data()?['fullName'] ?? uid).toString();
  }

  /// Add transaction
  Future<void> addTransaction({
    required String from,
    String? to,
    List<String>? toList,
    required double amount,
    required DateTime time,
    String? groupId,
  }) async {
    await _firestore.collection('transactions').add({
      'from': from,
      'to': to ?? "",
      'toList': toList ?? [],
      'groupId': groupId ?? "",
      'amount': amount,
      'time': time, // local timestamp
      'serverTime': FieldValue.serverTimestamp(), // optional
    });
  }

  /// Friend transactions
  Stream<List<Map<String, dynamic>>> getFriendTransactions(String friendUid) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('transactions')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data()..['id'] = doc.id;
            return data;
          })
          .where((tx) {
            final from = tx['from'] ?? '';
            final to = tx['to'] ?? '';
            return (from == currentUser.uid && to == friendUid) ||
                (from == friendUid && to == currentUser.uid);
          })
          .toList();
    });
  }

  /// Group transactions
  Stream<List<Map<String, dynamic>>> getGroupTransactions(String groupId) {
    return _firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
