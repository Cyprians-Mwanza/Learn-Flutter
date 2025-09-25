import 'package:flutter/material.dart';
import 'models/note.dart';
import 'services/api_service.dart';

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

  // Add Note
  void _addNoteDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update Note
  void _editNoteDialog(Note note, int index) {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete Note
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
                return Dismissible(
                  key: ValueKey(note.id),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteNoteHandler(note, index),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(child: Text('${note.id}')),
                    onTap: () => _editNoteDialog(note, index),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Floating Action Button (Add Notes)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNoteDialog,
        // icon: const Icon(Icons.add),
        label: const Text("Add Notes"),
      ),
    );
  }
}
