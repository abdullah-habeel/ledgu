import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Load all friends of user
  Future<List<Map<String, dynamic>>> getFriends() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
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

  /// Calculate total Will Receive & Will Pay (amounts)
  Future<Map<String, double>> getDashboardTotals() async {
    final user = _auth.currentUser;
    if (user == null) return {'willReceive': 0, 'willPay': 0};

    double willReceive = 0;
    double willPay = 0;

    final txSnapshot = await _firestore
        .collection('transactions')
        .orderBy('time', descending: true)
        .get();

    for (var doc in txSnapshot.docs) {
      final data = doc.data();
      final from = data['from'] ?? '';
      final to = data['to'] ?? '';
      final toList = List<String>.from(data['toList'] ?? []);
      final groupId = data['groupId'] ?? '';
      final amount = (data['amount'] ?? 0).toDouble();

      if (groupId.isEmpty) {
        if (from == user.uid) {
          willReceive += amount;
        } else if (to == user.uid || toList.contains(user.uid)) {
          willPay += amount;
        }
      } else {
        final membersCount = toList.isNotEmpty ? toList.length : 1;
        final perPerson = amount / membersCount;

        if (from == user.uid) {
          willReceive += perPerson * (membersCount - 1);
        } else if (toList.contains(user.uid)) {
          willPay += perPerson;
        }
      }
    }

    return {'willReceive': willReceive, 'willPay': willPay};
  }

  /// Pending & ToPay — count of people
  Future<Map<String, int>> getPendingAndToPay() async {
    final user = _auth.currentUser;
    if (user == null) return {'pending': 0, 'toPay': 0};

    Set<String> pendingSet = {}; // people who owe me
    Set<String> toPaySet = {};   // people I owe

    final txSnapshot = await _firestore
        .collection('transactions')
        .orderBy('time', descending: true)
        .get();

    for (var doc in txSnapshot.docs) {
      final data = doc.data();
      final from = data['from'] ?? '';
      final to = data['to'] ?? '';
      final toList = List<String>.from(data['toList'] ?? []);
      final groupId = data['groupId'] ?? '';

      if (groupId.isEmpty) {
        if (from == user.uid) {
          if (to.isNotEmpty) pendingSet.add(to);
          for (var t in toList) pendingSet.add(t);
        } else if (to == user.uid || toList.contains(user.uid)) {
          toPaySet.add(from);
        }
      } else {
        if (from == user.uid) {
          for (var t in toList) {
            if (t != user.uid) pendingSet.add(t);
          }
        } else if (toList.contains(user.uid)) {
          toPaySet.add(from);
        }
      }
    }

    return {'pending': pendingSet.length, 'toPay': toPaySet.length};
  }
}
