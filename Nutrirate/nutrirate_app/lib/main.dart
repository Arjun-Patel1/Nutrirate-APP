import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants.dart';
import 'core/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart'; // Import the new Home

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NutriRateApp(),
    ),
  );
}

class NutriRateApp extends StatelessWidget {
  const NutriRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Check if a user session already exists
    final session = Supabase.instance.client.auth.currentSession;
    
    return MaterialApp(
      title: 'NutriRate',
      debugShowCheckedModeBanner: false,
      
      // --- LIGHT THEME ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
      ),

      // --- DARK THEME (FIXED) ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: const Color(0xFF121212), // True Black
        
        // Fix Text Colors for Dark Mode
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        
        // Fix Input Fields (Search Bar / Login)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, 
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E), // Card background
        ),
      ),

      themeMode: themeProvider.themeMode, 
      
      // LOGIC: If session exists, go to Home. If not, go to Login.
      home: session != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}