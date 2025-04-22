import 'package:flutter/material.dart';

import 'mood_entry_screen.dart';

class AddMoodCard extends StatelessWidget {

  const AddMoodCard({super.key, });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MoodEntryScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.add, color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Add today's mood",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
