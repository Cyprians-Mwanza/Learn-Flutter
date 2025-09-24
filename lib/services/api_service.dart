import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/posts"),
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "FlutterApp",
        },
      );

      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((note) => Note.fromJson(note)).toList();
      } else {
        throw Exception(
            "Failed to load notes. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching notes: $e");
      throw Exception("Error fetching notes: $e");
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts"),
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "FlutterApp",
        },
        body: json.encode(note.toJson()),
      );

      if (response.statusCode == 201) {
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            "Failed to create note. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error creating note: $e");
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/posts/${note.id}"),
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "FlutterApp",
        },
        body: json.encode(note.toJson()),
      );

      if (response.statusCode == 200) {
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            "Failed to update note. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating note: $e");
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/posts/$id"),
        headers: {
          "User-Agent": "FlutterApp",
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to delete note. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting note: $e");
    }
  }
}
