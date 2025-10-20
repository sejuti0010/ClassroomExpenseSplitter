// lib/screens/group/group_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore_service.dart';
import '../../models/member.dart';
import '../../models/expense.dart';
import '../../widgets/member_chip.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/balance_card.dart';
import '../../utils/balance_util.dart';
import 'add_member_dialog.dart';
import 'add_expense_dialog.dart';
import '../report/summary_report_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const GroupDetailScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName), actions: [
        IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SummaryReportScreen(groupId: widget.groupId, groupName: widget.groupName)))),
        PopupMenuButton<String>(onSelected: (s) {
          if (s == 'share') {
            final id = widget.groupId;
            Clipboard.setData(ClipboardData(text: id));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group ID copied')));
          }
        }, itemBuilder: (ctx) => const [PopupMenuItem(value: 'share', child: Text('Copy Group ID'))]),
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Members horizontal
          SizedBox(
            height: 110,
            child: StreamBuilder<QuerySnapshot>(
              stream: fs.streamGroupMembers(widget.groupId),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                final members = docs.map((d) => MemberModel.fromDoc(d)).toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return ElevatedButton.icon(icon: const Icon(Icons.person_add), label: const Text('Add'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMemberScreen(groupId: widget.groupId))));
                    }
                    return MemberChip(member: members[i - 1]);
                  },
                );
              },
            ),
          ),

          // Balance summary (computed)
          StreamBuilder<QuerySnapshot>(
            stream: fs.streamGroupMembers(widget.groupId),
            builder: (ctx, memSnap) {
              if (!memSnap.hasData) return const SizedBox();
              final members = memSnap.data!.docs.map((d) => MemberModel.fromDoc(d)).toList();
              return StreamBuilder<QuerySnapshot>(
                stream: fs.streamGroupExpenses(widget.groupId),
                builder: (ctx2, expSnap) {
                  if (!expSnap.hasData) return const SizedBox();
                  final expenses = expSnap.data!.docs.map((d) => ExpenseModel.fromDoc(d)).toList();
                  // compute for first user if present (simple: sum all balances)
                  final balances = calculateBalances(expenses, members);
                  // find current user? we don't have authentication uid here; so show overall totals
                  final totalSpent = expenses.fold(0.0, (p, e) => p + e.amount);
                  final average = members.isEmpty ? 0.0 : totalSpent / members.length;
                  return Column(
                    children: [
                      BalanceCard(balance: balances.isEmpty ? 0.0 : balances.values.fold(0.0, (p, e) => p + e)), // overall weird but shows something
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Total spent: ৳ ${totalSpent.toStringAsFixed(2)}'),
                          Text('Avg: ৳ ${average.toStringAsFixed(2)}'),
                        ]),
                      )
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: fs.streamGroupExpenses(widget.groupId),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No expenses yet'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final expense = ExpenseModel.fromDoc(doc);
                    // need payer name — attempt to fetch from members snapshot synchronously is hard here;
                    // show payer id for now
                    return ExpenseTile(expense: expense, payerName: expense.paidById);
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(groupId: widget.groupId))),
      ),
    );
  }
}
