// lib/screens/group/add_expense_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/member.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  const AddExpenseScreen({super.key, required this.groupId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _paidById;
  final Set<String> _selectedParticipants = {};
  final fs = FirestoreService();
  bool _saving = false;

  Future<void> _save() async {
    final title = _titleCtl.text.trim();
    final amount = double.tryParse(_amountCtl.text.trim()) ?? 0.0;
    if (title.isEmpty || amount <= 0 || _paidById == null || _selectedParticipants.isEmpty) return;
    setState(() => _saving = true);
    try {
      await fs.addExpense(widget.groupId, {
        'title': title,
        'amount': amount,
        'paidById': _paidById,
        'participantIds': _selectedParticipants.toList(),
        'date': Timestamp.fromDate(_date),
        'note': _noteCtl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _amountCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _amountCtl, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
                stream: fs.streamGroupMembers(widget.groupId),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const CircularProgressIndicator();
                  final members = snap.data!.docs.map((d) => MemberModel.fromDoc(d)).toList();
                  if (members.isEmpty) return const Text('Add members first');
                  // paid by dropdown
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _paidById,
                        hint: const Text('Paid by'),
                        items: members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                        onChanged: (v) => setState(() => _paidById = v),
                      ),
                      const SizedBox(height: 8),
                      const Text('Participants:'),
                      Wrap(
                        spacing: 8,
                        children: members.map((m) {
                          final selected = _selectedParticipants.contains(m.id);
                          return FilterChip(
                            label: Text(m.name),
                            selected: selected,
                            onSelected: (on) => setState(() {
                              if (on) _selectedParticipants.add(m.id); else _selectedParticipants.remove(m.id);
                            }),
                          );
                        }).toList(),
                      )
                    ],
                  );
                }),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Date: ${DateFormat.yMMMd().format(_date)}'),
                const SizedBox(width: 12),
                TextButton(onPressed: () async {
                  final dt = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (dt != null) setState(() => _date = dt);
                }, child: const Text('Pick')),
              ],
            ),
            TextField(controller: _noteCtl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'))
          ],
        ),
      ),
    );
  }
}
