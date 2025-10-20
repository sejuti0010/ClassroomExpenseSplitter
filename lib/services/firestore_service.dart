// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<DocumentReference> createGroup(String name, String createdBy) {
    return _db.collection('groups').add({
      'name': name,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'members': [createdBy],
    });
  }

  Future<void> addMember(String groupId, String memberUid, Map<String, dynamic> memberData) async {
    await _db.collection('groups').doc(groupId).collection('members').doc(memberUid).set(memberData);
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([memberUid]),
    });
  }

  Future<void> addExpense(String groupId, Map<String, dynamic> expenseData) {
    return _db.collection('groups').doc(groupId).collection('expenses').add(expenseData);
  }

  Stream<QuerySnapshot> streamAllGroups() {
    return _db.collection('groups')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamGroups(String userId) {
    return _db.collection('groups')
        .where('members', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamGroupMembers(String groupId) {
    return _db.collection('groups').doc(groupId).collection('members').snapshots();
  }

  Stream<QuerySnapshot> streamGroupExpenses(String groupId) {
    return _db.collection('groups').doc(groupId).collection('expenses').orderBy('date', descending: true).snapshots();
  }
}