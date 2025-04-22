import 'package:flutter/material.dart';
import '../models/journal.dart';
import '../common/app_button.dart';

class JournalCard extends StatelessWidget {
  final Journal journal;
  final VoidCallback? onDelete;

  const JournalCard({super.key, required this.journal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    journal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    journal.formattedDate,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(journal.content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            if (journal.createdBy != null && journal.createdBy!['name']!=null)
              Align(
                alignment: Alignment.topRight,
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "- ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "${journal.createdBy!['name']}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            if (journal.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topRight,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      journal.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.indigo[50],
                              labelStyle: const TextStyle(
                                color: Colors.indigo,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topRight,
                child: AppButton(
                  text: 'Delete',
                  variant: ButtonVariant.danger,
                  size: ButtonSize.small,
                  onPressed: onDelete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
