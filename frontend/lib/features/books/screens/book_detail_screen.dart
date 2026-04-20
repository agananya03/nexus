import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/app_toast.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _book;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _api.getBookById(widget.bookId);
      setState(() => _book = d);
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load details: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _contactSeller() async {
    final phone = _book?['seller_phone'];
    final email = _book?['seller_email'];

    if (phone != null && phone.isNotEmpty) {
      // WhatsApp deep link
      final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (email != null && email.isNotEmpty) {
      final uri = Uri(scheme: 'mailto', path: email);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }

    if (mounted) {
      showAppToast(context, 'No contact info available', isError: true);
    }
  }

  Color _conditionColor(String? condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.amberAccent;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Book Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _book == null
              ? const Center(
                  child: Text('Not found',
                      style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large image
                      _book!['image_url'] != null
                          ? CachedNetworkImage(
                              imageUrl: _book!['image_url'],
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 240,
                                color: const Color(0xFF1A1D27),
                                child: const Icon(Icons.book,
                                    color: Colors.white24, size: 60),
                              ),
                            )
                          : Container(
                              height: 240,
                              color: const Color(0xFF1A1D27),
                              child: const Icon(Icons.book,
                                  color: Colors.white24, size: 60),
                            ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _book!['title'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'by ${_book!['author'] ?? ''}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 15),
                            ),
                            const SizedBox(height: 16),

                            _infoRow('Edition', _book!['edition']),
                            _infoRow('Subject', _book!['subject']),
                            const SizedBox(height: 4),

                            // Condition badge
                            Row(
                              children: [
                                const Text('Condition: ',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _conditionColor(
                                            _book!['condition'])
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: _conditionColor(
                                                _book!['condition'])
                                            .withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _book!['condition'] ?? '',
                                    style: TextStyle(
                                        color: _conditionColor(
                                            _book!['condition']),
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              '₹ ${(_book!['price'] as num?)?.toStringAsFixed(0) ?? ''}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),

                            // Seller info
                            const Text('Seller',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(_book!['seller_name'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(_book!['seller_email'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13)),

                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _contactSeller,
                                icon: const Icon(Icons.message_outlined,
                                    color: Colors.white),
                                label: const Text('Contact Seller',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(color: Colors.white54)),
              TextSpan(
                  text: value?.toString() ?? '—',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
}
