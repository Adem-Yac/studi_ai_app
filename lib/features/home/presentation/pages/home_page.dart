import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../chat/presentation/chat_launcher.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../quiz/presentation/pages/quiz_hub_page.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  final Set<int> _visited = {0};

  void goToTab(int index) {
    setState(() {
      _tab = index;
      _visited.add(index);
    });
  }

  void openChatWith(String prompt) {
    ChatLauncher.queue(prompt);
    goToTab(1);
  }

  Widget _tabAt(int index) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return switch (index) {
      0 => HomeTab(
          onOpenChat: openChatWith,
          onOpenTab: goToTab,
        ),
      1 => const ChatPage(),
      2 => DocumentsPage(onOpenChat: openChatWith),
      3 => const QuizHubPage(),
      4 => const ProfilePage(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.scaffoldOf(context),
      body: IndexedStack(
        index: _tab,
        children: [for (var i = 0; i < 5; i++) _tabAt(i)],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _tab,
        onSelect: goToTab,
      ),
    );
  }
}
