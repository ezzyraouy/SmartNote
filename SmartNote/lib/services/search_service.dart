import 'package:algolia/algolia.dart';
import 'package:flutter/foundation.dart';
import './auth_service.dart';
import '../models/note.dart';

class SearchService with ChangeNotifier {
  late Algolia _algolia;
  List<Note> _results = [];
  List<Note> get results => _results;

  SearchService(String appId, String apiKey) {
    _algolia = Algolia.init(
      applicationId: appId,
      apiKey: apiKey,
    );
  }

  Future<void> search(String query, int userId) async {
    final index = _algolia.instance.index('notes');

    // Use query() instead of deprecated search()
    AlgoliaQuery algoliaQuery = index.query(query);

    // Add userId filter if needed (adjust field name as per your Algolia records)
    algoliaQuery = algoliaQuery.facetFilter('userId:$userId');

    // Perform the search and get hits
    AlgoliaQuerySnapshot snap = await algoliaQuery.getObjects();

    final hits = snap.hits;

    _results = hits.map((hit) {
      final data = hit.data;

      // Parse dates safely, fallback to current date if missing
      DateTime createdAt;
      DateTime updatedAt;

      try {
        createdAt = DateTime.parse(data['createdAt']);
      } catch (_) {
        createdAt = DateTime.now();
      }
      try {
        updatedAt = DateTime.parse(data['updatedAt']);
      } catch (_) {
        updatedAt = DateTime.now();
      }

      return Note(
        id: hit.objectID,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }).toList();

    notifyListeners();
  }
}
