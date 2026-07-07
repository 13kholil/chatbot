import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/sirup_api_service.dart';
import 'chat_screen.dart';
import 'tender_screen.dart';
import 'penyedia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    TenderScreen(),
    PenyediaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SirupApiService>().fetchStats();
      context.read<SirupApiService>().fetchPackages(refresh: true);
      context.read<SirupApiService>().fetchPenyedia(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatService = context.watch<ChatService>();
    final sirupService = context.watch<SirupApiService>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Badge(
              isLabelVisible: false,
              child: Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: const Badge(
              isLabelVisible: false,
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: sirupService.packages.isNotEmpty,
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Tender',
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business),
            label: 'Penyedia',
          ),
        ],
      ),
    );
  }
}
