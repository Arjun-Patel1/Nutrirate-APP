import 'package:flutter/material.dart';
import '../../widgets/calorie_progress_widget.dart';
import '../scan/scanner_screen.dart';
import '../search/search_screen.dart';
import '../add_product/add_product_screen.dart';
import '../profile/calorie_calculator_screen.dart';
import 'diet_chatbot_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NutriRate Home"), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Progress Circle
            const CalorieProgressWidget(),
            const SizedBox(height: 25),

            const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. The Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _DashTile(
                  icon: Icons.qr_code_scanner, 
                  title: "Scan Food", 
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                ),
                _DashTile(
                  icon: Icons.search, 
                  title: "Search DB", 
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
                _DashTile(
                  icon: Icons.camera_alt, 
                  title: "AI Add Food", 
                  color: Colors.purple, 
                  isPremium: true, // Shows Lock
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                ),
                _DashTile(
                  icon: Icons.chat_bubble, 
                  title: "AI Chatbot", 
                  color: Colors.green,
                  isPremium: true, // Shows Lock
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietChatbotScreen())),
                ),
                _DashTile(
                  icon: Icons.calculate, 
                  title: "Calculator", 
                  color: Colors.red,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen())),
                ),
                _DashTile(
                  icon: Icons.diamond, 
                  title: "Premium", 
                  color: Colors.amber,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Gateway coming soon!")));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isPremium;

  const _DashTile({required this.icon, required this.title, required this.color, required this.onTap, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(icon, size: 40, color: color),
                if (isPremium)
                  const Positioned(
                    right: 0, top: 0,
                    child: Icon(Icons.lock, size: 14, color: Colors.grey),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            if (isPremium)
              const Text("PRO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}