
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddGroupScreen extends StatefulWidget {
  final String createdBy;
  const AddGroupScreen({super.key, required this.createdBy});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _nameCtl = TextEditingController();
  final fs = FirestoreService();
  bool _loading = false;

  Future<void> _create() async {
    final name = _nameCtl.text.trim();
    final createdBy = widget.createdBy.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a group name')));
      return;
    }
    if (createdBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: createdBy UID is empty. Are you logged in?')));
      debugPrint('AddGroupScreen: createdBy is empty. widget.createdBy="${widget.createdBy}"');
      return;
    }

    setState(() => _loading = true);
    try {
      final docRef = await fs.createGroup(name, createdBy);
      debugPrint('Group created: ${docRef.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created: ${docRef.id}')));
      Navigator.pop(context);
    } on ArgumentError catch (e) {
      debugPrint('ArgumentError createGroup: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid input: ${e.message}')));
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException createGroup: code=${e.code} message=${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase error: ${e.message ?? e.code}')));
    } catch (e, st) {
      debugPrint('Unknown createGroup error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating group: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Group name')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _create,
              child: _loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
