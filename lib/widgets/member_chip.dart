// lib/widgets/member_chip.dart
import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberChip extends StatelessWidget {
  final MemberModel member;
  const MemberChip({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = member.name.isNotEmpty
        ? member.name.trim().split(' ').map((s) => s.isEmpty ? '' : s[0]).take(2).join()
        : member.email.substring(0, 2).toUpperCase();
    return Column(
      children: [
        CircleAvatar(child: Text(initials), radius: 20),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(member.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        )
      ],
    );
  }
}
