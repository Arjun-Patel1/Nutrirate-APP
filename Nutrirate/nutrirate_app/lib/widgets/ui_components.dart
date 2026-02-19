import 'package:flutter/material.dart';

// 1. Grade Badge (A/B/C/D/E)
class GradeBadge extends StatelessWidget {
  final String grade;
  final bool isLarge;
  const GradeBadge({super.key, required this.grade, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    String g = grade.toUpperCase();
    Color c = (['A', 'B'].contains(g)) ? Colors.green : (g == 'C' ? Colors.orange : Colors.red);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 20 : 12, vertical: isLarge ? 10 : 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c, width: 2),
      ),
      child: Text(
        isLarge ? "Grade $g" : g,
        style: TextStyle(fontSize: isLarge ? 24 : 16, fontWeight: FontWeight.bold, color: c),
      ),
    );
  }
}

// 2. Product Card (For Lists)
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  
  const ProductCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item['brand'] ?? "Unknown Brand"),
        trailing: GradeBadge(grade: item['grade']),
        onTap: onTap,
      ),
    );
  }
}