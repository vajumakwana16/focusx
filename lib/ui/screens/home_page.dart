import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/save_data_dialog.dart';
import '../widgets/analytics_card.dart';
import '../widgets/habit_preview_card.dart';
import '../widgets/task_preview_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null && user.isAnonymous) {
    //   Future.delayed(const Duration(seconds: 1), () {
    //     showDialog(
    //       context: context,
    //       builder: (_) => const SaveDataDialog(),
    //     );
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusX'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AnalyticsCard(),
          SizedBox(height: 16),
          TaskPreviewCard(),
          SizedBox(height: 16),
          HabitPreviewCard(),
        ],
      ),
    );
  }
}