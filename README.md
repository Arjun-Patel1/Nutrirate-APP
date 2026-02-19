
## 🥗 NutriRate: AI-Powered Indian Health Coach
NutriRate is a specialized Flutter application designed to bridge the gap between traditional Indian diets and modern health goals. By leveraging Large Language Models (LLMs) and custom nutritional datasets, it provides culturally nuanced, medically aware dietary coaching.

🚀 The Problem Statement
Most global health apps struggle with Indian Nutritional Literacy.

Cultural Inaccuracy: Standard AI models often suggest Western alternatives (e.g., "Eat Kale/Avocado") that are not accessible or common in Indian households.

Macro-Complexity: Indian dishes like Biryani or Dosa vary wildly in nutritional density based on preparation.

Dietary Constraints: Managing health goals while adhering to strict Pure Vegetarian, Jain, or Eggitarian diets requires high-precision coaching.

🧠 The AI/ML Solution
This project solves the "context gap" by implementing a Domain-Specific AI Coach using the following pipeline:

1. Synthetic Data Distillation
I developed a custom Python pipeline in Google Colab that transformed raw Kaggle datasets (Indian Food Nutritional Values) into structured training pairs.

Tools: Python, Pandas, Gemini 1.5 Pro.

Process: Each dish was cross-referenced with health personas (Diabetic, Bodybuilder, Weight Loss) to create 500+ empathetic, clinical responses.

2. Contextual Prompt Engineering
Instead of a generic chatbot, NutriRate uses Augmented Prompting. The app dynamically injects user-specific biometric data (Age, Weight, Daily Calorie Goal) from a database into the LLM context.

Model: Gemini 3 Flash (Preview).

Logic: The AI "understands" the user’s calorie deficit and dietary restrictions before generating a single word.

✨ Key Features
🇮🇳 Culturally Aware Chat: An AI coach that recognizes dishes like Moong Dal Chilla or Paneer Butter Masala and provides specific advice.

📊 Personalized Nutrition: Integrates with a local database to track Age, Weight, and Caloric targets.

🛡️ Dietary Guardrails: The AI is hard-coded to respect religious and lifestyle dietary choices (Veg/Non-Veg).

⚡ Real-time Inference: Optimized Flutter UI with a non-blocking asynchronous chat interface.

🛠️ Tech Stack
Frontend: Flutter (Dart)

AI Engine: Google Gemini SDK

Backend/Database: Supabase / Local Database Service

Data Processing: Python (Pandas), Google Colab

🏗️ Installation & Setup
Clone the repository:

Bash
git clone https://github.com/your-username/nutrirate-app.git
cd nutrirate_app
Handle Secrets:

Create a .env file in the root directory.

Add your GEMINI_API_KEY=your_key_here.

Run the App:

Bash
flutter pub get
flutter run
👨‍💻 Author
Arjun Passionate about building AI solutions for real-world health challenges.

