import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/calorie_progress_widget.dart'; // Dashboard Widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    final data = await ApiService.searchProduct(query);

    if (mounted) {
      setState(() {
        _results = data;
        _isLoading = false;
      });
    }
  }

  // Show the bottom sheet with details + Favorites Logic
  void _showProductDetails(Map<String, dynamic> item) {
    // Initial state for the heart icon (defaults to false until we check DB, 
    // but for UI speed we default to unchecked or could fetch status async)
    bool isFav = false; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            height: 600,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // --- HEADER: Name + Heart Button ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? "Unknown Product",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () async {
                        // Toggle logic
                        final result = await DatabaseService().toggleFavorite(
                          item['barcode'] ?? 'no-code',
                          item['name'] ?? 'Unknown',
                          item['grade'] ?? '?',
                        );
                        // Update the heart icon color immediately
                        setModalState(() => isFav = result);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // --- GRADE BADGE ---
                GradeBadge(grade: item['grade'] ?? '?', isLarge: true),

                const SizedBox(height: 30),

                // --- NUTRITION GRID ---
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _NutriInfo("Calories", "${item['calories'] ?? 0}", "kcal"),
                    _NutriInfo("Sugar", "${item['sugar'] ?? 0}", "g"),
                    _NutriInfo("Fat", "${item['fat'] ?? 0}", "g"),
                    _NutriInfo("Protein", "${item['protein'] ?? 0}", "g"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _NutriInfo(String label, String value, String unit) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "$value$unit",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Search Database")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- 1. HEALTH DASHBOARD (Progress Circle) ---
              // If you haven't created this file yet, comment this line out
              const CalorieProgressWidget(), 
              
              const SizedBox(height: 20),

              // --- 2. SEARCH BAR ---
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Search 'Maggi', 'Coke'...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
              ),

              const SizedBox(height: 10),

              // --- 3. RESULTS LIST ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              "Type to search...",
                              style: TextStyle(
                                color: isDark ? Colors.grey : Colors.black54,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                item: _results[index],
                                onTap: () async {
                                  // A. Log to History
                                  await DatabaseService().logScan(
                                    _results[index]['barcode'] ?? 'search-result',
                                    _results[index]['name'] ?? 'Unknown',
                                    _results[index]['grade'] ?? '?',
                                  );

                                  // B. Show Details Popup
                                  if (context.mounted) {
                                    _showProductDetails(_results[index]);
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}