import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants.dart';
import '../../services/database_service.dart';

class DietChatbotScreen extends StatefulWidget {
  const DietChatbotScreen({super.key});

  @override
  State<DietChatbotScreen> createState() => _DietChatbotScreenState();
}

class _DietChatbotScreenState extends State<DietChatbotScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot', 
      'text': 'Namaste! I am your NutriRate AI Nutritionist. Ask me for a diet plan or about any Indian dish!'
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _msgCtrl.clear();
    });

    try {
      // 1. Get User Stats
      final stats = await DatabaseService().getUserStats();
      String contextStr = "User Profile: ";
      if (stats != null) {
        contextStr += "Age: ${stats['age']}, Weight: ${stats['weight_kg']}kg, "
            "Goal: ${stats['daily_calorie_goal']} kcal.";
        // Note: If you add 'diet_type' to your database later, append it here!
      }

      // 2. Initialize Model
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview', 
        apiKey: AppConstants.geminiApiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        ]
      );

      // 3. Create the Indian Coach Prompt
      final content = [
        Content.text("""
        You are an expert, empathetic Indian Clinical Nutritionist and Health Coach for the NutriRate app.
        
        CONTEXT: $contextStr
        (Assume an Indian dietary context. If the user specifies a diet like Pure Vegetarian, Jain, or Eggitarian in their question, you MUST respect it perfectly.)
        
        USER QUESTION: "$text"
        
        TASK:
        Write a natural, conversational response (2-3 sentences maximum).
        1. Respect dietary constraints perfectly. Do not suggest eggs to a Pure Vegetarian or meat to a Jain.
        2. Analyze if the food fits their specific health goals and calorie targets from the context above.
        3. Mention basic macros or Glycemic Index if relevant to the Indian foods they asked about.
        4. Keep the tone warm, coaching, and culturally respectful to Indian cuisine.
        """)
      ];
      
      final response = await model.generateContent(content);

      setState(() {
        _messages.add({
          'role': 'bot', 
          'text': response.text?.trim() ?? "I'm having trouble thinking right now."
        });
      });

    } catch (e) {
      print("❌ GEMINI ERROR: $e");
      
      setState(() {
        _messages.add({
          'role': 'bot', 
          'text': "Connection Error: Please check your internet or API key."
        });
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Coach"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : null,
                        bottomLeft: !isUser ? const Radius.circular(0) : null,
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.green),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Ask about your diet...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}