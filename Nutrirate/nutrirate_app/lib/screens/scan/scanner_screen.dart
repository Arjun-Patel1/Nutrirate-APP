import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../widgets/ui_components.dart';
import '../add_product/add_product_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  void _handleBarcode(String? barcode) async {
    if (barcode == null || !isScanning) return;
    
    setState(() => isScanning = false); // Pause scanning
    
    // 1. Fetch Data
    final data = await ApiService.fetchProduct(barcode);
    
    if (mounted) {
      if (data != null) {
        // 2. SUCCESS: Log to History & Show Result
        await DatabaseService().logScan(
          data['barcode'] ?? barcode, 
          data['name'] ?? 'Unknown Product', 
          data['grade'] ?? '?'
        );
        _showResult(data);
      } else {
        // 3. FAIL: Redirect to Add Product
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Product not found. Please add it!"),
          duration: Duration(seconds: 2),
        ));
        
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => AddProductScreen(initialBarcode: barcode))
        );
        
        setState(() => isScanning = true); 
      }
    }
  }

  void _showResult(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 5, color: Colors.grey[300], margin: const EdgeInsets.only(bottom: 20)),
            Text(item['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(item['brand'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            GradeBadge(grade: item['grade'], isLarge: true),
            const SizedBox(height: 20),
            const Text("Nutrition Data Loaded", style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    ).whenComplete(() => setState(() => isScanning = true));
  }

  void _showManualEntry() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Barcode"),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 11433110587"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (textController.text.isNotEmpty) {
                _handleBarcode(textController.text);
              }
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showManualEntry,
        icon: const Icon(Icons.keyboard),
        label: const Text("Enter Code"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Stack(
        children: [
          // 1. Camera (Hide default overlay)
          MobileScanner(
            controller: controller,
            // overlayBuilder: (ctx, constraints) => Container(), // Hides default box
            onDetect: (capture) => _handleBarcode(capture.barcodes.first.rawValue),
          ),
          
          // 2. Custom Beautiful Overlay
          Center(
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                // Glowing Green Border
                border: Border.all(color: Colors.greenAccent, width: 3), 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                ]
              ),
              child: const Center(
                child: Icon(Icons.qr_code_scanner, color: Colors.white24, size: 80),
              ),
            ),
          ),

          // 3. Top Instruction Text
          Positioned(
            top: 60, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text("Point camera at barcode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}