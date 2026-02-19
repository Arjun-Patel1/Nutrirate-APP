import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // --- 1. LOG HISTORY ---
  Future<void> logScan(String barcode, String name, String grade) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('history').insert({
        'user_id': user.id,
        'barcode': barcode,
        'product_name': name,
        'grade': grade,
      });
    } catch (e) {
      print("Error logging scan: $e");
    }
  }

  // --- 2. FAVORITES SYSTEM ---
  
  // Toggle (Add/Remove) Favorite
  Future<bool> toggleFavorite(String barcode, String name, String grade) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('barcode', barcode)
        .maybeSingle();

    if (existing != null) {
      await _supabase.from('favorites').delete().eq('id', existing['id']);
      return false; // Removed
    } else {
      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'barcode': barcode,
        'product_name': name,
        'grade': grade,
      });
      return true; // Added
    }
  }

  // Get Stream for Favorites Screen
  Stream<List<Map<String, dynamic>>> getFavoritesStream() {
    final user = _supabase.auth.currentUser;
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', user?.id ?? '')
        .order('created_at', ascending: false);
  }

  // --- 3. USER STATS (Calculator & Dashboard) ---

  // Update Stats (When you calculate calories)
  Future<void> updateUserStats({
    required int age, 
    required String gender, 
    required int height, 
    required int weight, 
    required String activity, 
    required int calories,
    String? goal,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'age': age,
      'gender': gender,
      'height_cm': height,
      'weight_kg': weight,
      'activity_level': activity,
      'daily_calorie_goal': calories,
    });
  }

  // Get Stats (For the Dashboard Progress Circle) <--- THIS WAS MISSING
  Future<Map<String, dynamic>?> getUserStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
        
    return data;
  }
}
