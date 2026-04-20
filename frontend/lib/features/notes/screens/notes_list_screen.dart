import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../notifiers/notes_notifier.dart';
import '../models/note_model.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/empty_state.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  final _subjectController = TextEditingController();
  int? _selectedSemester;
  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    ref.read(notesProvider.notifier).fetchNotes(
          subject: _subjectController.text.trim(),
          semester: _selectedSemester,
        );
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showAppToast(context, 'Could not open file.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Notes', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/upload'),
        child: const Icon(Icons.upload_file),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Filter by Subject',
                      hintStyle: const TextStyle(color: Colors.white38),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white54),
                        onPressed: _applyFilter,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      filled: true,
                      fillColor: const Color(0xFF1A1D27),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  hint: const Text('Sem', style: TextStyle(color: Colors.white54)),
                  dropdownColor: const Color(0xFF1A1D27),
                  style: const TextStyle(color: Colors.white),
                  value: _selectedSemester,
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('All')),
                    ..._semesters.map((s) => DropdownMenuItem(value: s, child: Text('$s'))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedSemester = val);
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: notesState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (notes) {
                if (notes.isEmpty) {
                  return const EmptyState(
                      icon: Icons.note_alt_outlined,
                      title: 'No notes found',
                      subtitle: 'Be the first to upload!');
                }
                return RefreshIndicator(
                  onRefresh: () async => _applyFilter(),
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final isOwner = currentUser?.userId == note.uploaderId;
                      return Card(
                        color: const Color(0xFF1A1D27),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(label: Text(note.subject), backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2), labelStyle: const TextStyle(color: Color(0xFF6C63FF)), side: BorderSide.none, visualDensity: VisualDensity.compact),
                                  Chip(label: Text('Sem ${note.semester}'), backgroundColor: Colors.white12, labelStyle: const TextStyle(color: Colors.white70), side: BorderSide.none, visualDensity: VisualDensity.compact),
                                  if (note.branch != null)
                                    Chip(label: Text(note.branch!), backgroundColor: Colors.white12, labelStyle: const TextStyle(color: Colors.white70), side: BorderSide.none, visualDensity: VisualDensity.compact),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOwner)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => ref.read(notesProvider.notifier).deleteNote(note.noteId),
                                ),
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.blue),
                                onPressed: () => _openFile(note.fileUrl),
                              ),
                            ],
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
