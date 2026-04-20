import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../../../core/api_service.dart';

class NotesNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() async {
    return _fetchNotesFromApi();
  }

  Future<List<NoteModel>> _fetchNotesFromApi({String? subject, int? semester, String? branch}) async {
    final queryParams = <String, dynamic>{};
    if (subject != null && subject.isNotEmpty) queryParams['subject'] = subject;
    if (semester != null) queryParams['semester'] = semester;
    if (branch != null && branch.isNotEmpty) queryParams['branch'] = branch;
    
    final response = await apiService.get('/notes/', params: queryParams);
    
    late List<dynamic> rawData;
    if (response is List) {
      rawData = response;
    } else if (response.containsKey('data')) {
      rawData = response['data'] as List;
    } else {
      rawData = [];
    }
    return rawData.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<void> fetchNotes({String? subject, int? semester, String? branch}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotesFromApi(
          subject: subject,
          semester: semester,
          branch: branch,
        ));
  }

  Future<void> uploadNote(String title, String subject, int semester, String? branch, String filePath) async {
    final fields = {
      'title': title,
      'subject': subject,
      'semester': semester.toString(),
      if (branch != null && branch.isNotEmpty) 'branch': branch,
    };
    final response = await apiService.postMultipart(
      '/notes/',
      fields,
      filePath: filePath,
      fileField: 'file',
    );
    final newNote = NoteModel.fromJson(response);
    if (state.hasValue) {
      state = AsyncValue.data([newNote, ...state.value!]);
    } else {
      state = AsyncValue.data([newNote]);
    }
  }

  Future<void> deleteNote(String noteId) async {
    await apiService.delete('/notes/$noteId');
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((note) => note.noteId != noteId).toList(),
      );
    }
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<NoteModel>>(() {
  return NotesNotifier();
});
