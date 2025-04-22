import 'package:flutter/foundation.dart';
import 'api_service.dart';

class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'],
      author: json['author'],
    );
  }
}

class QuoteService with ChangeNotifier {
  Quote? _quote;
  bool _isLoading = false;

  Quote? get quote => _quote;
  bool get isLoading => _isLoading;

  Future<Quote?> fetchDailyQuote() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.get('/api/daily_quote/daily-quote');
      if (response.data != null) {
        _quote = Quote.fromJson(response.data);
      }
      return _quote;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}