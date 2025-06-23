// lib/services/notes_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For BuildContext
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/note.dart';
import 'auth_service.dart'; // Import your AuthService

class NotesService with ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000';
  List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> fetchNotes(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _notes.clear();
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notes = data.map((json) => Note.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch notes: ${e.toString()}');
    }
  }

  Future<void> createNote(
    BuildContext context,
    String title,
    String content,
  ) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: _buildHeaders(token),
        body: json.encode({'title': title, 'content': content}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create note: ${response.statusCode}');
      }

      await fetchNotes(context);
    } catch (e) {
      throw Exception('Failed to create note: ${e.toString()}');
    }
  }

  Future<void> updateNote(
    BuildContext context,
    String id,
    String title,
    String content,
  ) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$id'),
        headers: _buildHeaders(token),
        body: json.encode({'title': title, 'content': content}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update note: ${response.statusCode}');
      }

      await fetchNotes(context);
    } catch (e) {
      throw Exception('Failed to update note: ${e.toString()}');
    }
  }

  Future<void> deleteNote(BuildContext context, String id) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: _buildHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }

      await fetchNotes(context);
    } catch (e) {
      throw Exception('Failed to delete note: ${e.toString()}');
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<String> getSuggestionFromGemini(String content) async {
    const apiKey = 'AIzaSyD4pGDZNkEuQGIB--k1iXW_H0eSgnxJFHc';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Improve the following note by suggesting 1 concise, well-phrased alternatives. The suggestions should refine the original content in tone, clarity, and detail. Return ONLY the improved versions, each on a new line, without bullet points or explanations. Example input: 'I will go to the gym' →\n'I will go to the gym at 7am'\n'I plan to workout at the gym today'\n'Gym session scheduled for this evening'.\nOriginal text: $content",
              },
            ],
          },
        ],
      }),
    );

    final data = json.decode(response.body);
    return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        'No suggestions available.';
  }
}
