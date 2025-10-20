import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../group/add_group_screen.dart';
import '../group/group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  final String currentUserId;
  const GroupListScreen({super.key, required this.currentUserId});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final fs = FirestoreService();
  int _reloadToggle = 0;

  void _forceReload() => setState(() => _reloadToggle++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        key: ValueKey(_reloadToggle), // allow forced rebuilds
        stream: widget.currentUserId.trim().isEmpty
            ? fs.streamAllGroups()
            : fs.streamGroups(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Error loading groups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'), onPressed: _forceReload),
                ]),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('No groups yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddGroupScreen(createdBy: widget.currentUserId)),
                  ),
                  child: const Text('Create group'),
                ),
              ]),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final name = (doc.data() as Map?)?['name'] ?? 'Unnamed';
              final id = doc.id;
              final tsValue = ((doc.data() as Map?)?['createdAt']);
              String dateStr = '';
              if (tsValue != null) {
                try {
                  if (tsValue is Timestamp) {
                    dateStr = tsValue.toDate().toLocal().toString().split(' ').first;
                  } else if (tsValue is int) {
                    dateStr = DateTime.fromMillisecondsSinceEpoch(tsValue).toLocal().toString().split(' ').first;
                  } else {
                    dateStr = tsValue.toString();
                  }
                } catch (e) {
                  dateStr = tsValue.toString();
                }
              }
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(name.toString()),
                  subtitle: Text('ID: $id • Created: $dateStr'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: id, groupName: name.toString())),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddGroupScreen(createdBy: widget.currentUserId)),
        ),
      ),
    );
  }
}
