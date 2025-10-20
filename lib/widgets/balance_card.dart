// lib/widgets/balance_card.dart
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, size: 28, color: isPositive ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isPositive ? 'You will receive' : 'You owe', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text('৳ ${balance.abs().toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ])
          ],
        ),
      ),
    );
  }
}
