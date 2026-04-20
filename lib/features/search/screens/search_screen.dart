import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/app_toast.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  
  List<dynamic> _internships = [];
  List<dynamic> _events = [];
  List<dynamic> _books = [];
  List<dynamic> _doubts = [];
  bool _hasSearched = false;

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await Future.wait([
        apiService.get('/internships/', params: {'search': query}),
        apiService.get('/events/', params: {'search': query}),
        apiService.get('/books/', params: {'search': query}),
        apiService.get('/doubts/', params: {'search': query}),
      ]);

      setState(() {
        _internships = _extractData(results[0]);
        _events = _extractData(results[1]);
        _books = _extractData(results[2]);
        _doubts = _extractData(results[3]);
      });
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Error searching: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _extractData(dynamic response) {
    if (response is List) return response;
    if (response is Map && response['data'] is List) return response['data'];
    return [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
          decoration: InputDecoration(
            hintText: 'Search internships, events, books...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white54),
              onPressed: _performSearch,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : !_hasSearched
              ? const EmptyState(
                  icon: Icons.search,
                  title: 'Search Nexus',
                  subtitle: 'Find internships, events, books and doubts.',
                )
              : _buildResultsView(),
    );
  }

  Widget _buildResultsView() {
    final totalResults = _internships.length + _events.length + _books.length + _doubts.length;

    if (totalResults == 0) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try a different search term.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_internships.isNotEmpty) ...[
          _buildSectionHeader('Internships', _internships.length),
          ..._internships.map((i) => _buildResultTile(
                title: i['title'] ?? 'Internship',
                subtitle: i['company'] ?? 'Company',
                onTap: () => context.push('/internships/${i['internship_id'] ?? i['id']}'),
              )),
          const SizedBox(height: 16),
        ],
        if (_events.isNotEmpty) ...[
          _buildSectionHeader('Events', _events.length),
          ..._events.map((e) => _buildResultTile(
                title: e['title'] ?? 'Event',
                subtitle: e['organizer'] ?? 'Organizer',
                onTap: () => context.push('/events/${e['event_id'] ?? e['id']}'),
              )),
          const SizedBox(height: 16),
        ],
        if (_books.isNotEmpty) ...[
          _buildSectionHeader('Books', _books.length),
          ..._books.map((b) => _buildResultTile(
                title: b['title'] ?? 'Book',
                subtitle: b['author'] ?? 'Author',
                onTap: () => context.push('/books/${b['book_id'] ?? b['id']}'),
              )),
          const SizedBox(height: 16),
        ],
        if (_doubts.isNotEmpty) ...[
          _buildSectionHeader('Doubts', _doubts.length),
          ..._doubts.map((d) => _buildResultTile(
                title: d['question'] ?? 'Doubt',
                subtitle: d['subject'] ?? 'Subject',
                onTap: () => context.push('/doubts/${d['doubt_id'] ?? d['id']}'),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Chip(
            label: Text('$title ($count)', style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFF1A1D27),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
