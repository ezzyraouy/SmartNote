import 'package:flutter/material.dart';

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Create Note'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: contentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Pour plus tard : enregistrer la note
                      Navigator.pop(context);
                    },
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
