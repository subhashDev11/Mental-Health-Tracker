import 'package:better_days/dashboard/custom_app_bar.dart';
import 'package:better_days/journal/empty_journal_card.dart';
import 'package:better_days/journal/journal_service.dart';
import 'package:better_days/models/journal.dart';
import 'package:better_days/models/mood.dart';
import 'package:better_days/mood/add_mood_card.dart';
import 'package:better_days/mood/mood_entry_screen.dart';
import 'package:better_days/mood/mood_service.dart';
import 'package:better_days/services/api_service.dart';
import 'package:better_days/services/auth_service.dart';
import 'package:better_days/services/quote_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onJumpPage});

  final Function(int v) onJumpPage;

  String getFormattedDate() {
    return DateFormat('EEEE, MMM d, y').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final journalService = Provider.of<JournalService>(context);

    final recentJournals = journalService.journals.take(2).toList();
    final user = context.watch<AuthService>().user;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome,",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(
                        text:
                        "${user?.name ?? user?.email}",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  getFormattedDate(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),

            // Today's Mood Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Mood",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onJumpPage(1),
                      child: const Text("View History"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TodayMoodCard(),
              ],
            ),
            // Daily Quote Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Quote",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _QuoteCard(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Journals",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onJumpPage(2),
                      child: const Text("View All"),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                if (recentJournals.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...recentJournals.map(
                            (journal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _JournalCard(journal: journal),
                        ),
                      ),
                    ],
                  )
                else
                  Center(child: EmptyJournalCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMoodCard extends StatelessWidget {
  const _TodayMoodCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: context.read<MoodService>().fetchTodayMood(),
      builder: (context, snapshot) {
        final mood = context.watch<MoodService>().todayMood;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade200,
            child: SizedBox(height: 80, width: double.infinity),
          );
        }

        if (mood == null) {
          return AddMoodCard();
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: mood.value?.getMoodColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    // color: moodData[mood.value]!["color"]!.withOpacity(0.2),
                    color: mood.value?.getMoodColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      mood.value?.getMoodEmoji ?? "",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.value?.moodLabel ?? "",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (mood.note?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            mood.note!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Quote?>(
      future: fetchDailyQuote(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final quote = snapshot.data;
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${quote?.content}"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "- ${quote?.author}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Future<Quote?> fetchDailyQuote() async {
    Quote? quote;
    try {
      final response = await ApiService.instance.get(
        '/api/daily_quote/daily-quote',
      );
      if (response.data != null) {
        quote = Quote.fromJson(response.data);
      }
      return quote;
    } catch (e) {
      return null;
    }
  }
}

class _JournalCard extends StatelessWidget {
  final Journal journal;

  const _JournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              journal.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (journal.content.isNotEmpty)
              Text(
                journal.content.length > 100
                    ? '${journal.content.substring(0, 100)}...'
                    : journal.content,
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _getJournalDate(journal.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (journal.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children:
                        journal.tags
                            .take(2)
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.1),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getJournalDate(DateTime? createdAt, {String? replace}) {
    if (createdAt == null) {
      return replace ?? "";
    }
    try {
      return DateFormat('MMM d, h:mm a').format(journal.createdAt!);
    } catch (e) {
      return replace ?? "";
    }
  }
}
