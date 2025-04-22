import 'package:better_days/models/mood.dart';
import 'package:better_days/mood/add_mood_card.dart';
import 'package:better_days/mood/mood_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'mood_chart.dart';
import 'mood_entry_screen.dart';

class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({super.key});

  @override
  State<MoodChartScreen> createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) {
      context.read<MoodService>().fetchMoods();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var moodService = context.watch<MoodService>();

    if (moodService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (moodService.moods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_neutral, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No mood entries yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first mood to see the chart",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    var moodData = moodService.moods;
    // Sort by date (newest first)
    moodData.sort(
      (a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight - 40,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MoodEntryScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Your Mood History',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'See how your mood changes over time',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: MoodChartSyncfusion(moods: moodData.reversed.toList()),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Entries',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (moodData.isEmpty)
              AddMoodCard()
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: moodData.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final mood = moodData[index];
                  return _buildMoodCard(mood);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(Mood mood) {
    final color = mood.value?.getMoodColor;
    final emoji = mood.value?.getMoodEmoji;
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji ?? "", style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood: ${mood.value?.moodLabel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (mood.note != null && mood.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        mood.note!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeFormat.format(mood.date ?? DateTime.now()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  dateFormat.format(mood.date ?? DateTime.now()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
