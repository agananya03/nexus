import 'package:flutter/material.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/loading_button.dart';

const _subjects = [
  'Mathematics',
  'Physics',
  'Chemistry',
  'Computer Science',
  'Electronics',
  'Mechanical',
  'Civil',
  'Other',
];

class PostDoubtScreen extends StatefulWidget {
  const PostDoubtScreen({super.key});
  @override
  State<PostDoubtScreen> createState() => _PostDoubtScreenState();
}

class _PostDoubtScreenState extends State<PostDoubtScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _questionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  String _subject = 'Computer Science';
  int _semester = 1;
  List<String> _tags = [];
  bool _loading = false;

  void _addTag(String raw) {
    final parts = raw.split(RegExp(r'[,\n]'));
    for (final p in parts) {
      final tag = p.trim();
      if (tag.isNotEmpty && !_tags.contains(tag)) {
        setState(() => _tags.add(tag));
      }
    }
    _tagCtrl.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _api.postDoubt(
        question: _questionCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        subject: _subject,
        semester: _semester,
        tags: _tags,
      );
      if (mounted) {
        showAppToast(context, 'Doubt posted!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Error: $e', isError: true);
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
        title: const Text('Ask a Doubt',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              TextFormField(
                controller: _questionCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Question *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: _inputDec('Description (optional)'),
              ),
              const SizedBox(height: 14),

              // Subject dropdown
              DropdownButtonFormField<String>(
                value: _subject,
                dropdownColor: const Color(0xFF1A1D27),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Subject'),
                items: _subjects
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _subject = v!),
              ),
              const SizedBox(height: 14),

              // Semester dropdown
              DropdownButtonFormField<int>(
                value: _semester,
                dropdownColor: const Color(0xFF1A1D27),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Semester'),
                items: List.generate(
                  8,
                  (i) => DropdownMenuItem(
                      value: i + 1, child: Text('Semester ${i + 1}')),
                ),
                onChanged: (v) => setState(() => _semester = v!),
              ),
              const SizedBox(height: 14),

              // Tags input
              TextField(
                controller: _tagCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Add tags (press comma or enter)')
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFF6C63FF)),
                        onPressed: () => _addTag(_tagCtrl.text),
                      ),
                    ),
                onSubmitted: _addTag,
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags
                      .map(
                        (t) => Chip(
                          label: Text(t,
                              style: const TextStyle(color: Colors.white)),
                          backgroundColor:
                              const Color(0xFF6C63FF).withOpacity(0.2),
                          side: const BorderSide(
                              color: Color(0xFF6C63FF), width: 0.5),
                          deleteIcon:
                              const Icon(Icons.close, size: 14, color: Colors.white54),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 28),
              LoadingButton(
                label: 'Post Doubt',
                isLoading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF6C63FF), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1D27),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}
