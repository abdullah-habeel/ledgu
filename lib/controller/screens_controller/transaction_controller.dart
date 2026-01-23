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
    return (doc.data()?['fullName']?.toString() ?? uid);
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
      'time': time,
      'serverTime': FieldValue.serverTimestamp(),
    });
  }

  /// -------------------- Friend Transactions (fixed) --------------------
  Future<List<Map<String, dynamic>>> getFriendTransactionsPaginated({
    required String friendUid,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    Query query = _firestore
        .collection('transactions')
        .orderBy('time', descending: true);

    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.limit(limit).get();
    List<Map<String, dynamic>> list = [];

    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      final from = data['from']?.toString() ?? '';
      final to = data['to']?.toString() ?? '';
      final toList = List<String>.from(data['toList'] ?? []);

      // Include transaction if it's between current user and friend
      if ((from == currentUser.uid && (to == friendUid || toList.contains(friendUid))) ||
          (from == friendUid && (to == currentUser.uid || toList.contains(currentUser.uid)))) {

        data['id'] = doc.id;
        data['docSnapshot'] = doc;
        data['fromName'] = await getUserName(from);

        if (toList.isNotEmpty) {
          final names = await Future.wait(toList.map((uid) => getUserName(uid)));
          data['toName'] = names.join(", ");
        } else {
          data['toName'] = await getUserName(to);
        }

        list.add(data);
      }
    }
    return list;
  }

  /// -------------------- Group Transactions --------------------
  Future<List<Map<String, dynamic>>> getGroupTransactionsPaginated({
    required String groupId,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .orderBy('time', descending: true);

    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.limit(limit).get();
    List<Map<String, dynamic>> list = [];

    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      final fromUid = data['from']?.toString() ?? '';
      final toList = List<String>.from(data['toList'] ?? []);

      data['fromName'] = await getUserName(fromUid);

      if (toList.isNotEmpty) {
        final names = await Future.wait(toList.map((uid) => getUserName(uid)));
        data['toName'] = names.join(", ");
      } else {
        final toSingle = data['to']?.toString() ?? '';
        data['toName'] = await getUserName(toSingle);
      }

      data['id'] = doc.id;
      data['docSnapshot'] = doc;
      list.add(data);
    }
    return list;
  }

  /// -------------------- All Transactions (history) --------------------
  Future<List<Map<String, dynamic>>> getAllTransactionsPaginated({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    Query query =
        _firestore.collection('transactions').orderBy('time', descending: true);

    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.limit(limit).get();
    List<Map<String, dynamic>> list = [];

    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      final from = data['from']?.toString() ?? '';
      final toSingle = data['to']?.toString() ?? '';
      final toList = List<String>.from(data['toList'] ?? []);

      data['fromName'] = await getUserName(from);
      if (toList.isNotEmpty) {
        final names = await Future.wait(toList.map((uid) => getUserName(uid)));
        data['toName'] = names.join(", ");
      } else {
        data['toName'] = await getUserName(toSingle);
      }

      data['id'] = doc.id;
      data['docSnapshot'] = doc;

      // Include only if current user is involved
      if (from == currentUser.uid ||
          toSingle == currentUser.uid ||
          toList.contains(currentUser.uid)) {
        list.add(data);
      }
    }

    return list;
  }
}
