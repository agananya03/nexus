import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnswerCard extends StatelessWidget {
  final Map<String, dynamic> answer;
  final VoidCallback onUpvote;

  const AnswerCard({
    super.key,
    required this.answer,
    required this.onUpvote,
  });

  String _timeAgo(String? dt) {
    if (dt == null) return '';
    try {
      final d = DateTime.parse(dt);
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'just now';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final upvotes = answer['upvotes'] as int? ?? 0;
    final hasUpvoted = answer['user_has_upvoted'] as bool? ?? false;
    final isAccepted = answer['is_accepted'] as bool? ?? false;
    final name = answer['answered_by_name'] as String? ?? 'Unknown';
    final content = answer['content'] as String? ?? '';
    final timeAgo = _timeAgo(answer['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAccepted
            ? Colors.green.withOpacity(0.07)
            : const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted
              ? Colors.green.withOpacity(0.4)
              : const Color(0xFF6C63FF).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answerer + time
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Color(0xFF6C63FF), fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: Colors.white87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              Text(timeAgo,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
              if (isAccepted) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 18),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Content
          Text(content,
              style: const TextStyle(
                  color: Colors.white70, height: 1.6, fontSize: 14)),

          const SizedBox(height: 12),

          // Upvote row
          Row(
            children: [
              GestureDetector(
                onTap: onUpvote,
                child: Row(
                  children: [
                    Icon(
                      hasUpvoted
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: hasUpvoted
                          ? const Color(0xFF6C63FF)
                          : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$upvotes',
                      style: TextStyle(
                        color: hasUpvoted
                            ? const Color(0xFF6C63FF)
                            : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
