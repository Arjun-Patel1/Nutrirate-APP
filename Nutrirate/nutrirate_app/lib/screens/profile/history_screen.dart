import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/ui_components.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Real-time stream from Supabase
    final stream = Supabase.instance.client
        .from('history')
        .stream(primaryKey: ['id'])
        .order('scanned_at', ascending: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Scan History")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text("No scans yet."));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: GradeBadge(grade: item['grade'] ?? '?', isLarge: false),
                title: Text(item['product_name'] ?? 'Unknown'),
                subtitle: Text("Scanned: ${item['scanned_at'].toString().substring(0, 10)}"),
              );
            },
          );
        },
      ),
    );
  }
}