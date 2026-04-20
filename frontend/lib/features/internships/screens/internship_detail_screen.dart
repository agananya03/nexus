import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/app_toast.dart';

class InternshipDetailScreen extends StatefulWidget {
  final String internshipId;
  const InternshipDetailScreen({super.key, required this.internshipId});

  @override
  State<InternshipDetailScreen> createState() =>
      _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _api.getInternshipById(widget.internshipId);
      setState(() => _data = d);
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load details: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  String _format(String? dt) {
    if (dt == null) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dt));
    } catch (_) {
      return dt;
    }
  }

  Future<void> _applyNow() async {
    final link = _data?['apply_link'] ?? '';
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showAppToast(context, 'Could not open the link', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Internship Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _data == null
              ? const Center(
                  child: Text('Not found',
                      style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Company'),
                      _value(_data!['company']),
                      const SizedBox(height: 16),
                      _label('Role'),
                      Text(
                        _data!['role'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _row(Icons.location_on, _data!['location']),
                      const SizedBox(height: 8),
                      _row(Icons.currency_rupee, _data!['stipend']),
                      const SizedBox(height: 8),
                      _row(Icons.category_outlined, _data!['domain']),
                      const SizedBox(height: 8),
                      _row(Icons.calendar_today,
                          'Deadline: ${_format(_data!['deadline'])}'),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _applyNow,
                          icon: const Icon(Icons.open_in_new,
                              color: Colors.white),
                          label: const Text('Apply Now',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(color: Colors.white54, fontSize: 12));
  Widget _value(dynamic v) => Text(
        v?.toString() ?? '—',
        style:
            const TextStyle(color: Colors.white, fontSize: 16),
      );
  Widget _row(IconData icon, dynamic v) => Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 8),
          Text(v?.toString() ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      );
}
