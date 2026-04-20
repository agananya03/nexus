import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../notifiers/notes_notifier.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/loading_button.dart';

class UploadNoteScreen extends ConsumerStatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  ConsumerState<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends ConsumerState<UploadNoteScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  int? _selectedSemester;
  String? _selectedBranch;
  String? _filePath;
  String? _fileName;
  bool _isUploading = false;

  final List<String> _branches = ['CS', 'IT', 'EC', 'ME', 'CE'];
  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _selectedSemester == null ||
        _filePath == null) {
      showAppToast(context, 'Please fill all required fields and select a file', isError: true);
      return;
    }

    setState(() => _isUploading = true);
    try {
      await ref.read(notesProvider.notifier).uploadNote(
            _titleController.text.trim(),
            _subjectController.text.trim(),
            _selectedSemester!,
            _selectedBranch,
            _filePath!,
          );
      if (mounted) {
        showAppToast(context, 'Note uploaded successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Upload failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Upload Note', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1D27),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_titleController, 'Title *'),
            const SizedBox(height: 16),
            _buildTextField(_subjectController, 'Subject *'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: _inputDec('Semester *'),
              dropdownColor: const Color(0xFF1A1D27),
              style: const TextStyle(color: Colors.white),
              value: _selectedSemester,
              items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
              onChanged: (val) => setState(() => _selectedSemester = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: _inputDec('Branch (Optional)'),
              dropdownColor: const Color(0xFF1A1D27),
              style: const TextStyle(color: Colors.white),
              value: _selectedBranch,
              items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickFile,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
                side: const BorderSide(color: Color(0xFF6C63FF)),
              ),
              icon: const Icon(Icons.attach_file),
              label: Text(_fileName ?? 'Select File (PDF, Image) *'),
            ),
            const SizedBox(height: 32),
            LoadingButton(
              label: 'Upload Note',
              isLoading: _isUploading,
              onPressed: _upload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDec(label),
    );
  }

  InputDecoration _inputDec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1A1D27),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}
