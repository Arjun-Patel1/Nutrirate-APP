import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/ui_components.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService().getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet. Tap ❤️ on a product!",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: GradeBadge(
                    grade: item['grade'] ?? '?',
                    isLarge: false,
                  ),
                  title: Text(
                    item['product_name'] ??
                        'Unknown',
                  ),
                  subtitle: Text(
                    "Barcode: ${item['barcode']}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await DatabaseService()
                          .toggleFavorite(
                        item['barcode'],
                        item['product_name'],
                        item['grade'],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
