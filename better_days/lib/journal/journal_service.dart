import 'package:flutter/foundation.dart';
import '../models/journal.dart';
import '../services/api_service.dart';

class JournalService with ChangeNotifier {

  List<Journal> _journals = [];
  bool _isLoading = false;


  List<Journal> get journals => _journals;
  bool get isLoading => _isLoading;

  Future<void> fetchJournals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.get('/api/journal/getAllJournals');
      _journals = (response.data['journals'] as List)
          .map((item) => Journal.fromJson(item))
          .toList();
        } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJournal(String title, String content, List<String> tags) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.post('/api/journal/create', {
        'title': title,
        'content': content,
        'tags': tags,
      });
      await fetchJournals();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJournal(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.delete('/api/journal/delete/$id');
      await fetchJournals();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}