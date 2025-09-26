import 'package:flutter/material.dart';
import 'models/note.dart';
import 'services/api_service.dart';
import 'utils/validations.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _notesFuture;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _notesFuture = fetchNotes();
  }

  Future<void> _refreshNotes() async {
    final fetched = await fetchNotes();
    setState(() {
      _notes = fetched;
    });
  }

  void _addNoteDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: ValidationUtils.validateTitle,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextFormField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  maxLines: 3,
                  validator: ValidationUtils.validateBody,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    final newNote = await addNote(
                      titleController.text,
                      bodyController.text,
                    );
                    setState(() {
                      _notes.insert(0, newNote);
                    });
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note added')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add note: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editNoteDialog(Note note, int index) {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);
    final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: ValidationUtils.validateTitle,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextFormField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  maxLines: 3,
                  validator: ValidationUtils.validateBody,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editFormKey.currentState?.validate() ?? false) {
                  // Check if there are actual changes
                  if (!ValidationUtils.hasChanges(
                    note.title,
                    note.body,
                    titleController.text,
                    bodyController.text,
                  )) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No changes made')),
                    );
                    return;
                  }

                  try {
                    final updated = await updateNote(
                      note.id,
                      titleController.text,
                      bodyController.text,
                    );

                    setState(() {
                      _notes[index] = updated;
                    });
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note updated')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update note: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNoteHandler(Note note, int index) async {
    setState(() {
      _notes.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notes.insert(index, note);
            });
          },
        ),
      ),
    );

    try {
      await deleteNote(note.id);
    } catch (e) {
      setState(() {
        _notes.insert(index, note);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _notes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _notes.isEmpty) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (_notes.isEmpty && snapshot.hasData) {
            _notes = snapshot.data!;
          }

          if (_notes.isEmpty) {
            return const Center(child: Text('No notes found'));
          }

          return RefreshIndicator(
            onRefresh: _refreshNotes,
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        '${note.id}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _editNoteDialog(note, index),
                            child: const Icon(Icons.edit, color: Colors.blue, size: 22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _showDeleteConfirmation(note, index),
                            child: const Icon(Icons.delete, color: Colors.red, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNoteDialog,
        label: const Text("Add Notes"),
      ),
    );
  }

  void _showDeleteConfirmation(Note note, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNoteHandler(note, index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}