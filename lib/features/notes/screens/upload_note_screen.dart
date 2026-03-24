import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../notifiers/notes_notifier.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and select a file')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject *'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Semester *'),
              value: _selectedSemester,
              items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
              onChanged: (val) => setState(() => _selectedSemester = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Branch (Optional)'),
              value: _selectedBranch,
              items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_fileName ?? 'Select File (PDF, Image) *'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              child: _isUploading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Upload Note'),
            ),
          ],
        ),
      ),
    );
  }
}
