import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';
import 'internship_detail_screen.dart';

class InternshipListScreen extends StatefulWidget {
  const InternshipListScreen({super.key});

  @override
  State<InternshipListScreen> createState() => _InternshipListScreenState();
}

class _InternshipListScreenState extends State<InternshipListScreen> {
  final ApiService _api = ApiService();
  final _locationCtrl = TextEditingController();
  String? _selectedDomain;
  List<dynamic> _listings = [];
  bool _loading = false;

  final _domains = [
    'All',
    'Software',
    'Design',
    'Marketing',
    'Data Science',
    'Finance',
    'Hardware',
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getInternships(
        domain: (_selectedDomain == null || _selectedDomain == 'All')
            ? null
            : _selectedDomain,
        location: _locationCtrl.text.trim(),
      );
      setState(() => _listings = data);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _isDeadlineSoon(String? deadlineStr) {
    if (deadlineStr == null) return false;
    try {
      final deadline = DateTime.parse(deadlineStr);
      return deadline.difference(DateTime.now()).inDays < 7;
    } catch (_) {
      return false;
    }
  }

  String _formatDeadline(String? deadlineStr) {
    if (deadlineStr == null) return '';
    try {
      final dt = DateTime.parse(deadlineStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return deadlineStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text(
          'Internships',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter row
          Container(
            color: const Color(0xFF1A1D27),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDomain ?? 'All',
                    dropdownColor: const Color(0xFF1A1D27),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Domain'),
                    items: _domains
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDomain = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _locationCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Location'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                  ),
                  child: const Text('Search',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : _listings.isEmpty
                    ? const Center(
                        child: Text('No internships found',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _listings.length,
                        itemBuilder: (ctx, i) {
                          final item = _listings[i] as Map<String, dynamic>;
                          final soon = _isDeadlineSoon(item['deadline']);
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => InternshipDetailScreen(
                                    internshipId: item['listing_id']),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1D27),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['company'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['role'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _chip(item['domain'] ?? '',
                                          const Color(0xFF6C63FF)),
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹ ${item['stipend'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'By ${_formatDeadline(item['deadline'])}',
                                        style: TextStyle(
                                          color: soon
                                              ? Colors.redAccent
                                              : Colors.white54,
                                          fontSize: 12,
                                          fontWeight: soon
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
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
        filled: true,
        fillColor: const Color(0xFF0F1117),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12)),
      );
}
