import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notes_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String initialTitle;
  final String initialContent;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialTitle = '',
    this.initialContent = '',
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isGettingSuggestion = false;
  List<String> _aiSuggestions = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final notesService = Provider.of<NotesService>(context, listen: false);
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.noteId != null) {
        await notesService.updateNote(context, widget.noteId!, title, content);
      } else {
        await notesService.createNote(context, title, content);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNote();
    }
  }

  Future<void> _deleteNote() async {
    if (widget.noteId == null) return;

    setState(() => _isDeleting = true);
    try {
      final notesService = Provider.of<NotesService>(context, listen: false);
      await notesService.deleteNote(context, widget.noteId!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _fetchAISuggestion() async {
    setState(() {
      _isGettingSuggestion = true;
      _aiSuggestions = [];
    });

    try {
      final notesService = Provider.of<NotesService>(context, listen: false);
      final suggestion = await notesService.getSuggestionFromGemini(
        _contentController.text,
      );

      // Parse the response to get multiple suggestions
      final suggestions = suggestion
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() => _aiSuggestions = suggestions);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Error: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingSuggestion = false);
    }
  }

  // void _applySuggestion(String suggestion) {
  //   final currentText = _contentController.text;
  //   final newText = currentText.isEmpty
  //       ? suggestion
  //       : '$currentText\n$suggestion';
  //   _contentController.text = newText;
  //   setState(() {
  //     _aiSuggestions = []; // Clear suggestions after selection
  //   });
  // }
  void _applySuggestion(String suggestion) {
    _contentController.text =
        suggestion;
    setState(() {
      _aiSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.noteId != null;

    return WillPopScope(
      onWillPop: () async => !_isSaving && !_isDeleting,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Note' : 'Create Note'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            if (isEditing)
              IconButton(
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete),
                onPressed: _isDeleting ? null : _confirmDelete,
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  maxLines: 15,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter your note content',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    icon: _isGettingSuggestion
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isGettingSuggestion
                          ? 'Generating...'
                          : 'Suggest with AI',
                    ),
                    onPressed: _isGettingSuggestion ? null : _fetchAISuggestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_aiSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Suggestions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _aiSuggestions.map((suggestion) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _applySuggestion(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveNote,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Note',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
