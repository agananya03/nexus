import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../../shared/widgets/app_toast.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _event;
  List<dynamic> _rsvps = [];
  bool _loading = true;
  bool _rsvpd = false;
  bool _rsvpLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ev = await _api.getEventById(widget.eventId);
      final rsvps = await _api.getEventRsvps(widget.eventId);
      final currentUserId = ref.read(authProvider).value?.userId;
      setState(() {
        _event = ev;
        _rsvps = rsvps;
        _rsvpd = rsvps.any((r) => r['user_id'] == currentUserId);
      });
    } catch (e) {
      if (mounted) showAppToast(context, 'Failed to load details: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleRsvp() async {
    setState(() => _rsvpLoading = true);
    try {
      await _api.toggleRsvp(widget.eventId);
      await _load();
    } catch (e) {
      if (mounted) {
        showAppToast(context, e.toString(), isError: true);
      }
    } finally {
      setState(() => _rsvpLoading = false);
    }
  }

  String _format(String? dt) {
    if (dt == null) return '—';
    try {
      return DateFormat('EEEE, dd MMM yyyy • hh:mm a')
          .format(DateTime.parse(dt));
    } catch (e) {
      return dt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Event Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _event == null
              ? const Center(
                  child: Text('Event not found',
                      style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + category badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _event!['title'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      const Color(0xFF6C63FF).withOpacity(0.5)),
                            ),
                            child: Text(_event!['category'] ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF6C63FF), fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _row(Icons.calendar_today, _format(_event!['date'])),
                      const SizedBox(height: 8),
                      _row(Icons.location_on, _event!['venue']),
                      const SizedBox(height: 8),
                      _row(Icons.person_outline, _event!['organizer']),
                      const SizedBox(height: 8),
                      _row(Icons.group, '${_event!['rsvp_count'] ?? 0} / ${_event!['rsvp_limit'] ?? '∞'} RSVPs'),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      const Text('About',
                          style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(_event!['description'] ?? '',
                          style: const TextStyle(
                              color: Colors.white70, height: 1.6)),

                      // RSVP button
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _rsvpLoading ? null : _toggleRsvp,
                          icon: Icon(
                            _rsvpd ? Icons.check_circle : Icons.event_available,
                            color: Colors.white,
                          ),
                          label: _rsvpLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _rsvpd ? "RSVP'd ✓" : 'RSVP',
                                  style: const TextStyle(color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _rsvpd
                                ? Colors.green.shade700
                                : const Color(0xFF6C63FF),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      // Attendees list
                      if (_rsvps.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        Text('Attendees (${_rsvps.length})',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const SizedBox(height: 8),
                        ..._rsvps.map((r) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6C63FF)
                                    .withOpacity(0.2),
                                child: Text(
                                  (r['name'] as String? ?? '?')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xFF6C63FF)),
                                ),
                              ),
                              title: Text(r['name'] ?? '',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.87))),
                              subtitle: Text(r['email'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _row(IconData icon, dynamic v) => Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(v?.toString() ?? '',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      );
}
