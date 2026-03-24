import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_service.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group created!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Study Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _maxMembers,
                decoration: const InputDecoration(labelText: 'Max Members'),
                items: _memberOptions.map((m) => DropdownMenuItem(value: m, child: Text('\$m'))).toList(),
                onChanged: (val) => setState(() => _maxMembers = val ?? 50),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createGroup,
                child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
