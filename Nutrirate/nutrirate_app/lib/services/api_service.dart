import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiService {
  // Fetch Product by Barcode
  static Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/scan/$barcode'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
    } catch (e) {
      print("API Error: $e");
    }
    return null;
  }

  // Search Product by Name
  static Future<List<dynamic>> searchProduct(String query) async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/search?query=$query'));
      if (response.statusCode == 200) {
        return json.decode(response.body)['results'];
      }
    } catch (e) {
      print("Search Error: $e");
    }
    return [];
  }
}