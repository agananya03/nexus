import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/loading_button.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _maxMembers = 50;
  bool _isLoading = false;

  final List<int> _memberOptions = [5, 10, 20, 50];

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createGroup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await apiService.post('/groups/', {
          'name': _nameController.text.trim(),
          'subject': _subjectController.text.trim(),
          'description': _descriptionController.text.trim(),
          'max_members': _maxMembers,
        });
        
        if (mounted) {
          showAppToast(context, 'Group created!');
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          showAppToast(context, 'Error: $e', isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Create Study Group', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1D27),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_nameController, 'Group Name *'),
              const SizedBox(height: 16),
              _buildTextField(_subjectController, 'Subject *'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', maxLines: 3, isRequired: false),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _maxMembers,
                dropdownColor: const Color(0xFF1A1D27),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Max Members'),
                items: _memberOptions.map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
                onChanged: (val) => setState(() => _maxMembers = val ?? 50),
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: 'Create Group',
                isLoading: _isLoading,
                onPressed: _createGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: _inputDec(label),
      validator: isRequired ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
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
