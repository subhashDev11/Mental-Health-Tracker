
import 'package:flutter/material.dart';

class EmptyJournalCard extends StatelessWidget {

  const EmptyJournalCard({super.key,});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "No journals yet",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: (){
                Navigator.pushNamed(context, "/create-journal");
              },
              child: const Text("Create your first journal"),
            ),
          ],
        ),
      ),
    );
  }
}
