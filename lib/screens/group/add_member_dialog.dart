// lib/screens/group/add_member_screen.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupId;
  const AddMemberScreen({super.key, required this.groupId});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final fs = FirestoreService();
  bool _loading = false;

  Future<void> _add() async {
    if (_nameCtl.text.trim().isEmpty || _emailCtl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await fs.addMember(
        widget.groupId,
        _emailCtl.text.trim(), // using email as unique id
        {
          'name': _nameCtl.text.trim(),
          'email': _emailCtl.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _add, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add')),
        ]),
      ),
    );
  }
}
