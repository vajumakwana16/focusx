import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/analytics/analytics_page.dart';
import 'package:focusx/ui/screens/settings_page.dart';
import 'package:focusx/ui/screens/task/add_edit_task_page.dart';
import 'package:focusx/ui/screens/task/tasks_page.dart';
import 'package:provider/provider.dart';
import '../../provider/dashboard_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_bottom_bar.dart';
import 'habit/add_edit_habit_page.dart';
import 'habit/habits_page.dart';
import 'home_page.dart';
import '../../utils/extensions.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(getTitles(provider.index))),
      drawer: AppDrawer(),
      extendBody: true, // 🔥 floating effect
      body: PageView(
        controller: provider.pageController,
        physics: const NeverScrollableScrollPhysics(), // controlled by bar
        children: const [
          HomePage(),
          TasksPage(),
          HabitsPage(),
          AnalyticsPage(),
          // SettingsPage(),
        ],
      ),
      floatingActionButtonLocation: .miniEndFloat,
      floatingActionButton: (provider.index == 1 || provider.index == 2) ?  FloatingActionButton(
        onPressed: () {
          if(provider.index == 1) {
            context.next(AddEditTaskPage());
          }else if(provider.index == 2){
            context.next(AddEditHabitPage());
          }
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: ModernBottomBar(
        index: provider.index,
        onChanged: (i)=>provider.setIndex(i),
      ),
    );
  }

  String getTitles(int i) {
    switch(i){
      case 0: return 'FocusX';
      case 1: return 'Tasks';
      case 2: return 'Habits';
      case 3: return 'Analytics';
      default: return 'FocusX';
    }
  }
}