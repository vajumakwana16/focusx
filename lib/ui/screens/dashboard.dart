import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/analytics_page.dart';
import 'package:focusx/ui/screens/settings_page.dart';
import 'package:focusx/ui/screens/task/add_edit_task_page.dart';
import 'package:focusx/ui/screens/task/tasks_page.dart';
import '../widgets/modern_bottom_bar.dart';
import 'habit/add_edit_habit_page.dart';
import 'habit/habits_page.dart';
import 'home_page.dart';
import '../../utils/extensions.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int newIndex) {
    setState(() => _index = newIndex);

    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic, // 🔥 smooth slide
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 🔥 floating effect
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // controlled by bar
        children: const [
          HomePage(),
          TasksPage(),
          HabitsPage(),
          AnalyticsPage(),
          SettingsPage(),
        ],
      ),
      floatingActionButtonLocation: .miniEndFloat,
      floatingActionButton: (_index == 1 || _index == 2) ?  FloatingActionButton(
        onPressed: () {
          if(_index == 1) {
            context.next(AddEditTaskPage());
          }else if(_index == 2){
            context.next(AddEditHabitPage());
          }
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: ModernBottomBar(
        index: _index,
        onChanged: _onTabChanged,
      ),
    );
  }
}