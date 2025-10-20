// lib/widgets/expense_tile.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final String payerName;
  const ExpenseTile({super.key, required this.expense, required this.payerName});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(expense.date);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(child: Text(payerName.isNotEmpty ? payerName[0] : '?')),
        title: Text(expense.title),
        subtitle: Text('$payerName • $dateStr\n${expense.note}'),
        isThreeLine: expense.note.isNotEmpty,
        trailing: Text('৳ ${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
