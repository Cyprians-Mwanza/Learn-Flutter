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
      title: 'Notes App',
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
  final ApiService api = ApiService();
  late Future<List<Note>> notes;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      notes = api.fetchNotes();
    });
  }

  // Show dialog for creating or editing note
  Future<void> _showNoteDialog({Note? note}) async {
    final TextEditingController titleController =
    TextEditingController(text: note?.title ?? "");
    final TextEditingController bodyController =
    TextEditingController(text: note?.body ?? "");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? "Add Note" : "Edit Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Enter your Title"),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: "Enter your Body"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) return;

                try {
                  if (note == null) {
                    // Create
                    await api.createNote(
                        Note(id: 0, title: title, body: body));
                  } else {
                    // Update
                    await api.updateNote(
                        Note(id: note.id, title: title, body: body));
                  }
                  _refreshNotes();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(Note note) async {
    try {
      await api.deleteNote(note.id);
      _refreshNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting note: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: FutureBuilder<List<Note>>(
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    "Failed to load notes.\n${snapshot.error}\nPull down to retry."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _refreshNotes(),
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No notes found")),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async => _refreshNotes(),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final note = snapshot.data![index];
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.body),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showNoteDialog(note: note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
