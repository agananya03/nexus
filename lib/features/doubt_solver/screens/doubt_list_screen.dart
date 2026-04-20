import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/app_toast.dart';
import 'doubt_detail_screen.dart';
import 'post_doubt_screen.dart';

class DoubtListScreen extends StatefulWidget {
  const DoubtListScreen({super.key});
  @override
  State<DoubtListScreen> createState() => _DoubtListScreenState();
}

class _DoubtListScreenState extends State<DoubtListScreen> {
  final ApiService _api = ApiService();
  final _subjectCtrl = TextEditingController();
  bool _showResolved = false;
  List<dynamic> _doubts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getDoubts(
        subject: _subjectCtrl.text.trim(),
        isResolved: _showResolved,
      );
      setState(() => _doubts = data);
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load doubts: $e', isError: true);
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
        title: const Text('Doubt Solver',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ask Doubt', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PostDoubtScreen()));
          _fetch();
        },
      ),
      body: Column(
        children: [
          // Controls
          Container(
            color: const Color(0xFF1A1D27),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                // Open / Resolved toggle
                Row(
                  children: [
                    _toggleChip('Open', !_showResolved, () {
                      setState(() => _showResolved = false);
                      _fetch();
                    }),
                    const SizedBox(width: 8),
                    _toggleChip('Resolved', _showResolved, () {
                      setState(() => _showResolved = true);
                      _fetch();
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                // Subject filter
                TextField(
                  controller: _subjectCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Filter by subject…',
                    hintStyle: const TextStyle(color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                      onPressed: _fetch,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF6C63FF), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF6C63FF)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F1117),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _fetch(),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF)))
                : _doubts.isEmpty
                    ? const EmptyState(
                        icon: Icons.help_outline,
                        title: 'No doubts found',
                        subtitle: 'Modify your filters or ask a new doubt.',
                      )
                    : RefreshIndicator(
                        onRefresh: _fetch,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _doubts.length,
                          itemBuilder: (ctx, i) {
                            final d = _doubts[i] as Map<String, dynamic>;
                            final resolved = d['is_resolved'] == true;
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) => DoubtDetailScreen(
                                      doubtId: d['doubt_id']),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1D27),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: resolved
                                          ? Colors.green.withOpacity(0.3)
                                          : const Color(0xFF6C63FF)
                                              .withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Question
                                    Text(
                                      d['question'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _chip(d['subject'] ?? '',
                                            const Color(0xFF6C63FF)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sem ${d['semester']}',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.chat_bubble_outline,
                                            color: Colors.white38, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${d['answer_count'] ?? 0}',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12),
                                        ),
                                        if (resolved) ...[
                                          const SizedBox(width: 8),
                                          _chip('Resolved', Colors.green),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF6C63FF)
                : const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.4)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : Colors.white54,
                  fontWeight: active
                      ? FontWeight.bold
                      : FontWeight.normal)),
        ),
      );

  Widget _chip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child:
            Text(label, style: TextStyle(color: color, fontSize: 11)),
      );
}
