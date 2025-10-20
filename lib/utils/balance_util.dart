// lib/utils/balance_util.dart
import '../models/expense.dart';
import '../models/member.dart';

Map<String, double> calculateBalances(List<ExpenseModel> expenses, List<MemberModel> members) {
  final balances = {for (var m in members) m.id: 0.0};

  for (final e in expenses) {
    if (e.participantIds.isEmpty) continue;
    final perHead = e.amount / e.participantIds.length;

    // payer receives amount - his share
    balances[e.paidById] = (balances[e.paidById] ?? 0) + (e.amount - perHead);

    // each other participant owes perHead
    for (final pid in e.participantIds) {
      if (pid == e.paidById) continue;
      balances[pid] = (balances[pid] ?? 0) - perHead;
    }
  }
  return balances;
}
