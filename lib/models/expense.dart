import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String paidById;
  final List<String> participantIds;
  final DateTime date;
  final String note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.participantIds,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'paidById': paidById,
    'participantIds': participantIds,
    'date': Timestamp.fromDate(date.toUtc()),
    'note': note,
  };

  factory ExpenseModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    DateTime dt = DateTime.now();
    if (d['date'] is Timestamp) dt = (d['date'] as Timestamp).toDate();
    return ExpenseModel(
      id: doc.id,
      title: d['title'] ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0.0,
      paidById: d['paidById'] ?? '',
      participantIds: List<String>.from(d['participantIds'] ?? []),
      date: dt,
      note: d['note'] ?? '',
    );
  }
}
