import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../services/api_service.dart';

class MoodService with ChangeNotifier {
  List<Mood> _moods = [];
  Mood? _todayMood;
  Mood? get todayMood => _todayMood;

  bool _isLoading = false;

  List<Mood> get moods => _moods;

  bool get isLoading => _isLoading;

  Future<void> fetchMoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.get(
        '/api/mood/moods_added_by_me',
      );
      if(response.data['moods']!=null) {
        _moods =
            (response.data['moods'] as List)
                .map((item) => Mood.fromJson(item))
                .toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayMood() async {
    try {
      final response = await ApiService.instance.get(
        '/api/mood/today_mood',
      );
      if(response.data!=null) {
        _todayMood = Mood.fromJson(response.data as Map<String,dynamic>);
      }
    } finally {
      notifyListeners();
    }
  }


  Future<void> addMood(int value, String? note) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.post('/api/mood/addMood', {
        'mood': value,
        'note': note,
      });
      await fetchMoods();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMood(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.delete('/api/mood/deleteById/$id');
      await fetchMoods();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
