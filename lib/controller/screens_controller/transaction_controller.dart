import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get username by UID
  Future<String> getUserName(String uid) async {
    if (uid.isEmpty) return "Unknown";
    final doc = await _firestore.collection("users").doc(uid).get();
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
      'serverTime': FieldValue.serverTimestamp(),
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
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final from = data['from'] ?? '';
        final to = data['to'] ?? '';
        if ((from == currentUser.uid && to == friendUid) ||
            (from == friendUid && to == currentUser.uid)) {
          data['id'] = doc.id;
          data['fromName'] = await getUserName(from);
          data['toName'] = await getUserName(to);
          list.add(data);
        }
      }
      return list;
    });
  }

  /// Group transactions
  Stream<List<Map<String, dynamic>>> getGroupTransactions(String groupId) {
    return _firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final fromUid = data['from'] ?? '';
        final toList = List<String>.from(data['toList'] ?? []);
        data['fromName'] = await getUserName(fromUid);

        if (toList.isNotEmpty) {
          final names = await Future.wait(toList.map((uid) => getUserName(uid)));
          data['toName'] = names.join(", ");
        } else {
          final toSingle = data['to'] ?? '';
          data['toName'] = await getUserName(toSingle);
        }
        list.add(data);
      }
      return list;
    });
  }

  /// Stream of all transactions (friend + group) for history page
  Stream<List<Map<String, dynamic>>> getAllTransactionsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('transactions')
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final from = data['from'] ?? '';
        final toList = List<String>.from(data['toList'] ?? []);
        final toSingle = data['to'] ?? '';

        data['fromName'] = await getUserName(from);

        if (toList.isNotEmpty) {
          final names = await Future.wait(toList.map((uid) => getUserName(uid)));
          data['toName'] = names.join(", ");
        } else {
          data['toName'] = await getUserName(toSingle);
        }

        data['id'] = doc.id;
        list.add(data);
      }
      return list;
    });
  }
}
