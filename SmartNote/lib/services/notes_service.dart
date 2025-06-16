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

  Future<void> createNote(BuildContext context, String title, String content) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: _buildHeaders(token),
        body: json.encode({
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create note: ${response.statusCode}');
      }

      await fetchNotes(context);
    } catch (e) {
      throw Exception('Failed to create note: ${e.toString()}');
    }
  }

  Future<void> updateNote(BuildContext context, String id, String title, String content) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$id'),
        headers: _buildHeaders(token),
        body: json.encode({
          'title': title,
          'content': content,
        }),
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
}