import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme_provider.dart';
import '../auth/login_screen.dart';
import 'history_screen.dart';
import 'calorie_calculator_screen.dart';
import 'favorites_screen.dart'; 

// ... (keep your existing imports)

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- 1. USER CARD ---
          Card(
            elevation: 2, // Slightly subtler elevation
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 40, color: Colors.green),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? "Guest User",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Free Plan",
                            style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- 2. FEATURES SECTION ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text("My Health", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          ),
          
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text("Favorites"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          const Divider(height: 1, indent: 50), // Clean divider with indent
          
          ListTile(
            leading: const Icon(Icons.history, color: Colors.purple),
            title: const Text("Scan History"),
            subtitle: const Text("View past products"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          const Divider(height: 1, indent: 50),

          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.orange),
            title: const Text("Calorie Calculator"),
            subtitle: const Text("Set daily goals"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen())),
          ),

          const SizedBox(height: 30),

          // --- 3. SETTINGS SECTION ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text("App Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}