import 'package:better_days/journal/empty_journal_card.dart';
import 'package:better_days/journal/journal_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'journal_card.dart';
import 'journal_service.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  _JournalListScreenState createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalService>(context, listen: false).fetchJournals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalService = Provider.of<JournalService>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JournalCreateScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body:
          journalService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : journalService.journals.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [EmptyJournalCard()],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journalService.journals.length,
                itemBuilder: (context, index) {
                  final journal = journalService.journals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: JournalCard(
                      journal: journal,
                      onDelete: () {
                        journalService.deleteJournal(journal.id);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
