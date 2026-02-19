import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants.dart';
import '../../services/database_service.dart';

class AddProductScreen extends StatefulWidget {
  final String? initialBarcode;
  const AddProductScreen({super.key, this.initialBarcode});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _barcodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _protCtrl = TextEditingController();

  File? _image;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBarcode != null) {
      _barcodeCtrl.text = widget.initialBarcode!;
    }
  }

  // --- 1. THE AI ENGINE (Gemini) ---
  Future<void> _scanLabelWithAI() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo == null) return;

    setState(() {
      _image = File(photo.path);
      _isAnalyzing = true;
    });

    try {
      // Setup Gemini
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview', 
        apiKey: AppConstants.geminiApiKey,
      );

      // The Prompt
      final prompt = TextPart("Look at this nutrition label. Extract these 4 numbers: Calories, Sugar (g), Fat (g), Protein (g). Return ONLY a simple list separated by commas like this: 250, 12, 5, 8. If you can't find a number, put 0.");
      final imagePart = DataPart('image/jpeg', await _image!.readAsBytes());

      // Generate
      final response = await model.generateContent([Content.multi([prompt, imagePart])]);
      final text = response.text?.trim() ?? "";
      
      // Parse "250, 12, 5, 8"
      final parts = text.split(',');
      if (parts.length >= 4) {
        setState(() {
          _calCtrl.text = parts[0].trim();
          _sugarCtrl.text = parts[1].trim();
          _fatCtrl.text = parts[2].trim();
          _protCtrl.text = parts[3].trim();
        });
        _showMessage("AI Data Extracted! Please verify.", color: Colors.green);
      } else {
        throw "Could not read label clearly.";
      }

    } catch (e) {
      _showMessage("AI Error: $e. Please type manually.", color: Colors.red);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // In a real app, this would go to a 'Pending' table. 
    // For this demo, we'll pretend it saves.
    _showMessage("Product Sent for Verification!");
    Navigator.pop(context); 
  }

  void _showMessage(String msg, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- AI BUTTON ---
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                ),
                child: _isAnalyzing 
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: _scanLabelWithAI,
                      child: _image == null 
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                              SizedBox(height: 10),
                              Text("Tap to Scan Nutrition Label\n(Powered by Gemini AI)", textAlign: TextAlign.center, style: TextStyle(color: Colors.blue)),
                            ],
                          )
                        : null,
                    ),
              ),
              const SizedBox(height: 20),
              
              const Text("Product Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              
              TextFormField(controller: _barcodeCtrl, decoration: const InputDecoration(labelText: "Barcode", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
              
              const SizedBox(height: 20),
              const Text("Nutrition (per 100g)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              
              Row(children: [
                Expanded(child: _numInput("Calories", _calCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _numInput("Sugar (g)", _sugarCtrl)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _numInput("Fat (g)", _fatCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _numInput("Protein (g)", _protCtrl)),
              ]),

              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Submit Contribution"),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numInput(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) => v!.isEmpty ? "Req" : null,
    );
  }
}