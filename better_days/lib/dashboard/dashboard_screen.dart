import 'package:better_days/common/responsive_widget.dart';
import 'package:better_days/dashboard/custom_app_bar.dart';
import 'package:better_days/journal/journal_list_screen.dart';
import 'package:better_days/journal/journal_service.dart';
import 'package:better_days/mood/mood_list_screen.dart';
import 'package:better_days/mood/mood_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin{

  int selected = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) {
      context.read<MoodService>().fetchMoods();
      context.read<JournalService>().fetchJournals();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = _buildBody();

    return ResponsiveWidget(
      mobView: Scaffold(
        appBar: DashboardAppBar(),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_emotions_outlined),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              label: 'Journal',
            ),
          ],
          currentIndex: selected,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onTap: (i) {
            setState(() {
              selected = i;
            });
          },
        ),
      ),
      deskView: Scaffold(
        appBar: DashboardAppBar(),
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomWebMenu(
                        items: ["Home", "Mood", "journal"],
                        onSelect: (i) {
                          setState(() {
                            selected = i;
                          });
                        },
                        selectedIndex: selected,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1), // optional divider
            Expanded(flex: 7, child: body),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBody() => IndexedStack(
    index: selected,
    children: [
      HomeTab(
        onJumpPage: (i) {
          setState(() {
            selected = i;
          });
        },
      ),
      MoodChartScreen(),
      JournalListScreen(),
    ],
  );

  @override
  bool get wantKeepAlive => true;
}

class CustomWebMenu extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const CustomWebMenu({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.primaryColor.withValues(alpha:0.15)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha:0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                  border: Border.all(
                    color:
                        isSelected ? theme.primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isSelected ? theme.primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.primaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
