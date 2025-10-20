import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'createdBy': createdBy,
    'createdAt': createdAt.toUtc(),
  };

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (ts is Timestamp) createdAt = ts.toDate();
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: createdAt,
    );
  }
}
