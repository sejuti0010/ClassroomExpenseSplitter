// lib/screens/report/summary_report_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/member.dart';
import '../../models/expense.dart';
import '../../utils/balance_util.dart';

class SummaryReportScreen extends StatelessWidget {
  final String groupId;
  final String groupName;
  const SummaryReportScreen({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: Text('$groupName — Summary')),
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.streamGroupMembers(groupId),
        builder: (ctx, memSnap) {
          if (!memSnap.hasData) return const Center(child: CircularProgressIndicator());
          final members = memSnap.data!.docs.map((d) => MemberModel.fromDoc(d)).toList();
          return StreamBuilder<QuerySnapshot>(
            stream: fs.streamGroupExpenses(groupId),
            builder: (ctx2, expSnap) {
              if (!expSnap.hasData) return const Center(child: CircularProgressIndicator());
              final expenses = expSnap.data!.docs.map((d) => ExpenseModel.fromDoc(d)).toList();
              final balances = calculateBalances(expenses, members);
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  ...members.map((m) {
                    final bal = balances[m.id] ?? 0.0;
                    return Card(
                      child: ListTile(
                        title: Text(m.name),
                        subtitle: Text(m.email),
                        trailing: Text('৳ ${bal.toStringAsFixed(2)}', style: TextStyle(color: bal >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
