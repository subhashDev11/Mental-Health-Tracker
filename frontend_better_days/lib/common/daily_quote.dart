import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quote_service.dart';

class DailyQuote extends StatelessWidget {
  const DailyQuote({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: QuoteService()..fetchDailyQuote(),
      child: DailyQuoteWidget(),
    );
  }
}

class DailyQuoteWidget extends StatelessWidget {
  const DailyQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteService = Provider.of<QuoteService>(context);

    return Card(
      color: Colors.indigo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Inspiration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (quoteService.quote != null) ...[
              Text(
                '"${quoteService.quote!.content}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- ${quoteService.quote!.author}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ] else ...[
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
