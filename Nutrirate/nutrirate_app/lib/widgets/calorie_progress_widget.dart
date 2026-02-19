import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class CalorieProgressWidget extends StatefulWidget {
  const CalorieProgressWidget({super.key});

  @override
  State<CalorieProgressWidget> createState() => _CalorieProgressWidgetState();
}

class _CalorieProgressWidgetState extends State<CalorieProgressWidget> {
  int _consumed = 0;
  int _goal = 2000;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 1. Get Goal from Profile
    final profile = await DatabaseService().getUserStats();
    if (profile != null && profile['daily_calorie_goal'] != null) {
      setState(() => _goal = profile['daily_calorie_goal']);
    }

    // 2. Get Today's History Log
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final history = await supabase
        .from('history')
        .select('product_name, grade') // We'd need a real calories column in history ideally
        .eq('user_id', user.id)
        .gte('scanned_at', '$todayStr 00:00:00');
    
    // Mock Calculation: Since history doesn't store calories yet, 
    // we'll estimate 250 kcal per scan for this visual demo.
    int total = history.length * 250; 

    setState(() {
      _consumed = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    double progress = _consumed / _goal;
    if (progress > 1.0) progress = 1.0;
    int left = _goal - _consumed;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    color: left < 0 ? Colors.red : Colors.green,
                  ),
                ),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Calories Today", style: TextStyle(color: Colors.grey)),
                  Text("$_consumed / $_goal kcal", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    left >= 0 ? "$left left" : "${left.abs()} over limit!",
                    style: TextStyle(color: left >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}