import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_lite/models/note.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Monthly Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NoteList(data: data, category: 'today', onEdit: (note) => _showAddEditDialog(context, data, note: note)),
          _NoteList(data: data, category: 'monthly', onEdit: (note) => _showAddEditDialog(context, data, note: note)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditDialog(context, data),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, DataProvider data, {Note? note}) {
    final textCtrl = TextEditingController(text: note?.text);
    String category = note?.category ?? 'today';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: textCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            if (note == null)
              StatefulBuilder(
                builder: (context, setState) => DropdownButton<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'today', child: Text('Today')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly Plans')),
                  ],
                  onChanged: (v) => setState(() => category = v!),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = Note(
                id: note?.id,
                text: textCtrl.text,
                category: note?.category ?? category,
                createdAt: note?.createdAt ?? DateTime.now(),
              );
              if (note == null) {
                await data.addNote(newNote);
              } else {
                await data.updateNote(newNote);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  final DataProvider data;
  final String category;
  final void Function(Note note) onEdit;

  const _NoteList({required this.data, required this.category, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: data.noteStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data!.where((n) => n.category == category).toList();
        if (notes.isEmpty) {
          return const Center(child: Text('No notes here'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (_, index) {
            final note = notes[index];
            return Card(
              child: ListTile(
                title: Text(note.text),
                subtitle: Text(DateFormat.yMMMd().add_Hm().format(note.createdAt)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(note),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete note?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await data.deleteNote(note.id!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}