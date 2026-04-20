import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import '../widgets/answer_card.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../../shared/widgets/app_toast.dart';

class DoubtDetailScreen extends ConsumerStatefulWidget {
  final String doubtId;
  const DoubtDetailScreen({super.key, required this.doubtId});

  @override
  ConsumerState<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends ConsumerState<DoubtDetailScreen> {
  final ApiService _api = ApiService();
  final _answerCtrl = TextEditingController();

  Map<String, dynamic>? _doubt;
  List<dynamic> _answers = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await _api.getDoubtById(widget.doubtId);
      setState(() {
        _doubt = d;
        _answers = List<dynamic>.from(d['answers'] ?? []);
      });
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load details: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _postAnswer() async {
    final content = _answerCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _posting = true);
    try {
      await _api.postAnswer(widget.doubtId, content);
      _answerCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Error: $e', isError: true);
      }
    } finally {
      setState(() => _posting = false);
    }
  }

  Future<void> _markResolved() async {
    try {
      await _api.resolveDoubt(widget.doubtId);
      await _load();
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _onUpvote(String answerId) async {
    try {
      final result = await _api.toggleUpvote(answerId);
      // Optimistically update local state
      setState(() {
        for (final a in _answers) {
          if ((a as Map<String, dynamic>)['answer_id'] == answerId) {
            a['upvotes'] = result['upvotes'];
            a['user_has_upvoted'] = result['status'] == 'added';
            break;
          }
        }
      });
    } catch (_) {}
  }

  String _formatDate(String? dt) {
    if (dt == null) return '';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dt));
    } catch (_) {
      return dt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).value?.userId;
    final isAsker = _doubt?['asked_by'] == currentUserId;
    final isResolved = _doubt?['is_resolved'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Doubt Detail',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(
              children: [
                // Scrollable content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Question
                      Text(
                        _doubt?['question'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Meta
                      Row(
                        children: [
                          _chip(_doubt?['subject'] ?? '',
                              const Color(0xFF6C63FF)),
                          const SizedBox(width: 8),
                          Text('Sem ${_doubt?['semester']}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                          const Spacer(),
                          Text(_formatDate(_doubt?['created_at']),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11)),
                        ],
                      ),

                      // Description
                      if (_doubt?['description'] != null &&
                          (_doubt!['description'] as String).isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          _doubt!['description'],
                          style: const TextStyle(
                              color: Colors.white70, height: 1.6),
                        ),
                      ],

                      // Tags
                      if (_doubt?['tags'] != null &&
                          (_doubt!['tags'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: (_doubt!['tags'] as List)
                              .map((t) => _chip(
                                  t.toString(), Colors.blueAccent))
                              .toList(),
                        ),
                      ],

                      // "Mark as Resolved" button
                      if (isAsker && !isResolved) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _markResolved,
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          label: const Text('Mark as Resolved',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                      if (isResolved) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            const Text('Resolved',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),

                      // Answers header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Answers (${_answers.length})',
                          style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),

                      // Answer cards
                      if (_answers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No answers yet. Be the first!',
                              style: TextStyle(color: Colors.white38)),
                        ),
                      ..._answers.map((a) {
                        final answer = a as Map<String, dynamic>;
                        return AnswerCard(
                          answer: answer,
                          onUpvote: () =>
                              _onUpvote(answer['answer_id']),
                        );
                      }),
                    ],
                  ),
                ),

                // Pinned answer input
                Container(
                  color: const Color(0xFF1A1D27),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _answerCtrl,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Write your answer…',
                            hintStyle: const TextStyle(color: Colors.white38),
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _posting ? null : _postAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _posting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send,
                                color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child:
            Text(label, style: TextStyle(color: color, fontSize: 11)),
      );
}
