import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import 'event_detail_screen.dart';

const _categories = ['All', 'Hackathon', 'Fest', 'Workshop', 'Sports'];

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});
  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final ApiService _api = ApiService();
  String _category = 'All';
  List<dynamic> _events = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getEvents(
          category: _category == 'All' ? null : _category);
      setState(() => _events = data);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String? dt) {
    if (dt == null) return '';
    try {
      return DateFormat('EEE dd MMM').format(DateTime.parse(dt));
    } catch (_) {
      return dt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Events',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            color: const Color(0xFF1A1D27),
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _categories.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _category = cat);
                    _fetch();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.4)),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Events list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF)))
                : _events.isEmpty
                    ? const Center(
                        child: Text('No upcoming events',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _events.length,
                        itemBuilder: (ctx, i) {
                          final ev = _events[i] as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(
                                    eventId: ev['event_id']),
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(ev['title'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      _badge(ev['category'] ?? ''),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: Color(0xFF6C63FF), size: 14),
                                      const SizedBox(width: 4),
                                      Text(_formatDate(ev['date']),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.location_on,
                                          color: Color(0xFF6C63FF), size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                          child: Text(ev['venue'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${ev['rsvp_count'] ?? 0} going',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
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

  Widget _badge(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.5)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF6C63FF), fontSize: 11)),
      );
}
