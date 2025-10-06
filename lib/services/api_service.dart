import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
const String baseUrl = "https://jsonplaceholder.typicode.com";


Future<List<Note>> fetchNotes() async {
  final response = await http.get(
    Uri.parse("$baseUrl/posts"),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'FlutterApp',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return (jsonData as List)
        .map((item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();

  } else {
    throw Exception('Failed to load notes');
  }
}


Future<Note> fetchNoteById(int id) async {
  final response = await http.get(
    Uri.parse("$baseUrl/posts/$id"),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'FlutterApp',
    },
  );


  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return Note.fromJson(jsonData);
  } else {
    throw Exception('Failed to load note');
  }
}


Future<Note> addNote(String title, String body) async {
  final response = await http.post(
    Uri.parse("$baseUrl/posts"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'title': title,
      'body': body,
      'userId': 1,
    }),
  );

  if (response.statusCode == 201) {
    return Note.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to add note');
  }
}

Future<Note> updateNote(int id, String title, String body) async {
  final response = await http.put(
    Uri.parse("$baseUrl/posts/$id"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'id': id,
      'title': title,
      'body': body,
      'userId': 1,
    }),
  );

  if (response.statusCode == 200) {
    return Note.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update note');
  }
}

Future<void> deleteNote(int id) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/posts/$id"),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete note');
  }
}
