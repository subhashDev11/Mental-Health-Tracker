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
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeTabDesktop extends StatelessWidget {
  const HomeTabDesktop({super.key, required this.onJumpPage});

  final Function(int v) onJumpPage;

  String getFormattedDate() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalService = Provider.of<JournalService>(context);
    final recentJournals = journalService.journals.take(2).toList();
    final user = context.watch<AuthService>().user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _DesktopHeader(user: user),
              const SizedBox(height: 30),

              // Main Content Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 1200;

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 3 : 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isWideScreen ? 1.1 : 1.3,
                    ),
                    children: [
                      // Mood Card
                      _DesktopMoodSection(onJumpPage: onJumpPage),

                      // Quote Card
                      _DesktopQuoteSection(),

                      // Recent Journals
                      _DesktopJournalsSection(
                        recentJournals: recentJournals,
                        onJumpPage: onJumpPage,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final dynamic user;

  const _DesktopHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/logo.png',
          height: 80,
        ),
        Row(
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 30),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: Row(
                children: [
                  Text(
                    user?.name ?? user?.email ?? "User",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundImage: user?.profileImage != null
                        ? CachedNetworkImageProvider(user!.profileImage!)
                        : const AssetImage('assets/avatar.jpg') as ImageProvider,
                    radius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopMoodSection extends StatelessWidget {
  final Function(int) onJumpPage;

  const _DesktopMoodSection({required this.onJumpPage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Mood",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => onJumpPage(1),
                  child: const Text("View History"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: context.read<MoodService>().fetchTodayMood(),
                builder: (context, snapshot) {
                  final mood = context.watch<MoodService>().todayMood;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }

                  if (mood == null) {
                    return const Center(
                      child: AddMoodCard(),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mood.value?.getMoodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: mood.value?.getMoodColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              mood.value?.getMoodEmoji ?? "",
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          mood.value?.moodLabel ?? "",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mood.note?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              mood.note!,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MoodEntryScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mood.value?.getMoodColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Update Mood"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopQuoteSection extends StatelessWidget {
  const _DesktopQuoteSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Quote",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Quote?>(
                future: fetchDailyQuote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.data != null) {
                    final quote = snapshot.data;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 36,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '"${quote?.content}"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "- ${quote?.author}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              // Refresh quote logic
                            },
                            tooltip: 'Refresh Quote',
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text("Failed to load quote"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

class _DesktopJournalsSection extends StatelessWidget {
  final List<Journal> recentJournals;
  final Function(int) onJumpPage;

  const _DesktopJournalsSection({
    required this.recentJournals,
    required this.onJumpPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Journals",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => onJumpPage(2),
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recentJournals.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: recentJournals.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final journal = recentJournals[index];
                    return _DesktopJournalCard(journal: journal);
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: EmptyJournalCard(),
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  // Navigate to new journal entry
                },
                child: const Text("New Journal Entry"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopJournalCard extends StatelessWidget {
  final Journal journal;

  const _DesktopJournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Navigate to journal detail
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    journal.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _getJournalDate(journal.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              journal.content.length > 200
                  ? '${journal.content.substring(0, 200)}...'
                  : journal.content,
              style: theme.textTheme.bodyLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (journal.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: journal.tags
                    .map(
                      (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                    .toList(),
              ),
            ],
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
      return DateFormat('MMM d, h:mm a').format(createdAt);
    } catch (e) {
      return replace ?? "";
    }
  }
}