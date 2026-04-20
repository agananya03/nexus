import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_service.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/empty_state.dart';

final groupsProvider = FutureProvider.autoDispose.family<List<dynamic>, String?>((ref, subject) async {
  final query = subject != null && subject.isNotEmpty ? {'subject': subject} : null;
  final response = await apiService.get('/groups/', params: query);
  if (response is List) return response;
  return response['data'] ?? [];
});

class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  String? _selectedSubject;
  final List<String> _subjects = ['CS', 'IT', 'Math', 'Physics', 'Design'];

  void _joinGroup(String groupId) async {
    try {
      await apiService.post('/groups/$groupId/join', {});
      ref.invalidate(groupsProvider);
      if (mounted) {
        showAppToast(context, 'Joined group!');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Failed to join: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider(_selectedSubject));

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Study Groups', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1D27),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/groups/create'),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All', style: TextStyle(color: Colors.white)),
                  selected: _selectedSubject == null,
                  selectedColor: const Color(0xFF6C63FF),
                  checkmarkColor: Colors.white,
                  backgroundColor: const Color(0xFF1A1D27),
                  onSelected: (_) => setState(() => _selectedSubject = null),
                ),
                const SizedBox(width: 8),
                ..._subjects.map((sub) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(sub, style: const TextStyle(color: Colors.white)),
                        selected: _selectedSubject == sub,
                        selectedColor: const Color(0xFF6C63FF),
                        checkmarkColor: Colors.white,
                        backgroundColor: const Color(0xFF1A1D27),
                        onSelected: (_) => setState(() => _selectedSubject = sub),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (groups) {
                if (groups.isEmpty) {
                  return const EmptyState(
                    icon: Icons.group_off_outlined,
                    title: 'No groups found',
                    subtitle: 'Create a new group!',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(groupsProvider(_selectedSubject)),
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      
                      return Card(
                        color: const Color(0xFF1A1D27),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          onTap: () => context.push('/groups/chat/${group['group_id']}?name=${Uri.encodeComponent(group['name'])}'),
                          title: Text(group['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Chip(label: Text(group['subject']), backgroundColor: Colors.white12, labelStyle: const TextStyle(color: Colors.white70), side: BorderSide.none, visualDensity: VisualDensity.compact),
                              Text('${group['member_count']} / ${group['max_members']} members', style: const TextStyle(color: Colors.white54)),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _joinGroup(group['group_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              minimumSize: const Size(80, 36),
                            ),
                            child: const Text('Join'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
