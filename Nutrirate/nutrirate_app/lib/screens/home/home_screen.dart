import 'package:flutter/material.dart';
import 'dashboard_screen.dart';      // Import Dashboard
import 'diet_chatbot_screen.dart';   // Import Chatbot
import '../profile/profile_screen.dart'; // Import Profile

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  
  // These are the 3 Main Tabs
  final _pages = [
    const DashboardScreen(),   // Tab 0: Home Grid
    const DietChatbotScreen(), // Tab 1: AI Chat
    const ProfileScreen(),     // Tab 2: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.chat), label: "AI Coach"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}