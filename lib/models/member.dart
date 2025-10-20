// lib/models/member_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String email;

  MemberModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MemberModel(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
    );
  }
}
