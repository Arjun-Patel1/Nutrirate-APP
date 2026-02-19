import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  
  String _gender = 'Male';
  String _activity = 'Sedentary';
  String _goal = 'Maintain Weight'; // New Feature: Goal Selection
  
  Map<String, int>? _results; // Stores Calories + Macros

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Close keyboard

    double weight = double.parse(_weightCtrl.text);
    double height = double.parse(_heightCtrl.text);
    int age = int.parse(_ageCtrl.text);
    
    // 1. Calculate BMR (Mifflin-St Jeor)
    double bmr = (10 * weight) + (6.25 * height) - (5 * age) + (_gender == 'Male' ? 5 : -161);
    
    // 2. Activity Multiplier
    double tdee = bmr;
    if (_activity == 'Sedentary') tdee = bmr * 1.2;
    if (_activity == 'Lightly Active') tdee = bmr * 1.375;
    if (_activity == 'Moderately Active') tdee = bmr * 1.55;
    if (_activity == 'Very Active') tdee = bmr * 1.725;

    // 3. Goal Adjustment
    int finalCalories = tdee.round();
    if (_goal == 'Lose Weight') finalCalories -= 500; // -500 deficit
    if (_goal == 'Gain Muscle') finalCalories += 300; // +300 surplus

    // 4. Calculate Macros (Standard Split: 30% P / 35% C / 35% F)
    int protein = (finalCalories * 0.30 / 4).round(); // 4 cal per gram
    int carbs   = (finalCalories * 0.35 / 4).round();
    int fat     = (finalCalories * 0.35 / 9).round(); // 9 cal per gram

    setState(() {
      _results = {
        'calories': finalCalories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
    });

    // Save to DB
    DatabaseService().updateUserStats(
      age: age, gender: _gender, height: height.toInt(), weight: weight.toInt(), 
      activity: _activity, calories: finalCalories, goal: _goal
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INPUT SECTION ---
              const Text("Your Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              Row(children: [
                Expanded(child: _input("Age", _ageCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _input("Height (cm)", _heightCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _input("Weight (kg)", _weightCtrl)),
              ]),
              
              const SizedBox(height: 20),
              _sectionLabel("Gender"),
              Row(children: [
                _choiceChip("Male", _gender == "Male", () => setState(() => _gender = "Male")),
                const SizedBox(width: 10),
                _choiceChip("Female", _gender == "Female", () => setState(() => _gender = "Female")),
              ]),

              const SizedBox(height: 20),
              _sectionLabel("Activity Level"),
              _dropdown(
                value: _activity, 
                items: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'],
                onChanged: (v) => setState(() => _activity = v!)
              ),

              const SizedBox(height: 20),
              _sectionLabel("Your Goal"),
              _dropdown(
                value: _goal, 
                items: ['Lose Weight', 'Maintain Weight', 'Gain Muscle'],
                onChanged: (v) => setState(() => _goal = v!)
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _calculate,
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Calculate My Plan", style: TextStyle(fontSize: 16)),
                ),
              ),

              // --- RESULTS SECTION ---
              if (_results != null) ...[
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                
                // Big Calorie Card
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      const Text("DAILY TARGET", style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
                      Text("${_results!['calories']} kcal", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      Text("Goal: $_goal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                const Text("Macronutrients (Daily)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // Macro Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _macroCard("Protein", "${_results!['protein']}g", Colors.blue),
                    _macroCard("Carbs", "${_results!['carbs']}g", Colors.orange),
                    _macroCard("Fats", "${_results!['fat']}g", Colors.red),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (v) => v!.isEmpty ? "Req" : null,
    );
  }

  Widget _sectionLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)));

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? Colors.green : Colors.grey),
    );
  }

  Widget _dropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged
        ),
      ),
    );
  }

  Widget _macroCard(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.5))),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}