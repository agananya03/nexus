import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/loading_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _collegeController = TextEditingController();
  
  String? _selectedBranch;
  int? _selectedYear;
  int? _selectedSemester;

  final List<String> _branches = ['CS', 'IT', 'EC', 'ME', 'CE'];
  final List<int> _years = [1, 2, 3, 4];
  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).register(
              _nameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _collegeController.text.trim().isEmpty ? null : _collegeController.text.trim(),
              _selectedBranch,
              _selectedYear,
              _selectedSemester,
            );
        final finalState = ref.read(authProvider);
        if (mounted && finalState.hasError) {
          showAppToast(context, 'Registration failed: ${finalState.error}', isError: true);
        } else if (mounted && finalState.value != null) {
          context.go('/internships');
        }
      } catch (e) {
        if (mounted) {
          showAppToast(context, 'Registration failed: ${e.toString()}', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1D27),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Enter a password' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _collegeController,
                  label: 'College Name (Optional)',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _inputDec('Branch'),
                        dropdownColor: const Color(0xFF1A1D27),
                        style: const TextStyle(color: Colors.white),
                        value: _selectedBranch,
                        items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => setState(() => _selectedBranch = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: _inputDec('Year'),
                        dropdownColor: const Color(0xFF1A1D27),
                        style: const TextStyle(color: Colors.white),
                        value: _selectedYear,
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: _inputDec('Semester'),
                  dropdownColor: const Color(0xFF1A1D27),
                  style: const TextStyle(color: Colors.white),
                  value: _selectedSemester,
                  items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
                  onChanged: (val) => setState(() => _selectedSemester = val),
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  label: 'Register',
                  isLoading: isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDec(label),
      validator: validator,
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
