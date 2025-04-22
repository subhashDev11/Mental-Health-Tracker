import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/app_button.dart';
import 'mood_service.dart' show MoodService;

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  _MoodEntryScreenState createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int? _selectedMood;
  final _noteController = TextEditingController();
  final List<String> _moodEmojis = ['😭', '😞', '😐', '🙂', '😁'];
  final List<Color> _moodColors = [
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.yellow[100]!,
    Colors.blue[100]!,
    Colors.green[100]!,
  ];

  @override
  Widget build(BuildContext context) {
    final moodService = Provider.of<MoodService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mood Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final moodValue = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = moodValue;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selectedMood == moodValue
                          ? Theme.of(context).primaryColor
                          : _moodColors[index],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _moodEmojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Save Mood',
              onPressed: _selectedMood == null || moodService.isLoading
                  ? null
                  : () {
                moodService.addMood(
                  _selectedMood!,
                  _noteController.text,
                );
                Navigator.pop(context);
              },
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}