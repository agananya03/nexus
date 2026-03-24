import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_service.dart';
import '../../../core/theme.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined group!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to join: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider(_selectedSubject));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/groups/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedSubject == null,
                  onSelected: (_) => setState(() => _selectedSubject = null),
                ),
                const SizedBox(width: 8),
                ..._subjects.map((sub) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(sub),
                        selected: _selectedSubject == sub,
                        onSelected: (_) => setState(() => _selectedSubject = sub),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(child: Text('No groups found. Create one!'));
                }
                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        onTap: () => context.push('/groups/chat/${group['group_id']}'),
                        title: Text(group['name'], style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Chip(label: Text(group['subject']), visualDensity: VisualDensity.compact),
                            Text('${group['member_count']} / ${group['max_members']} members'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _joinGroup(group['group_id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(80, 36),
                          ),
                          child: const Text('Join'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
