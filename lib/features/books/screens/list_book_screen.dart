import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/api_service.dart';

class ListBookScreen extends StatefulWidget {
  const ListBookScreen({super.key});
  @override
  State<ListBookScreen> createState() => _ListBookScreenState();
}

class _ListBookScreenState extends State<ListBookScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _editionCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _condition = 'Good';
  File? _imageFile;
  bool _loading = false;

  final _conditions = ['Excellent', 'Good', 'Fair'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final fd = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'author': _authorCtrl.text.trim(),
        'edition': _editionCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'condition': _condition,
        'price': _priceCtrl.text.trim(),
        if (_imageFile != null)
          'image': await MultipartFile.fromFile(
            _imageFile!.path,
            filename: 'book_image.jpg',
          ),
      });
      await _api.createBook(fd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book listed successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('List a Book',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D27),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        style: BorderStyle.solid),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_imageFile!,
                              fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Color(0xFF6C63FF), size: 48),
                            SizedBox(height: 8),
                            Text('Tap to add photo',
                                style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
              _field(_titleCtrl, 'Title'),
              const SizedBox(height: 12),
              _field(_authorCtrl, 'Author'),
              const SizedBox(height: 12),
              _field(_editionCtrl, 'Edition'),
              const SizedBox(height: 12),
              _field(_subjectCtrl, 'Subject'),
              const SizedBox(height: 12),
              _field(_priceCtrl, 'Price (₹)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // Condition dropdown
              DropdownButtonFormField<String>(
                value: _condition,
                dropdownColor: const Color(0xFF1A1D27),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Condition'),
                items: _conditions
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _condition = v!),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Listing',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDec(label),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1D27),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      );
}
