class NoteModel {
  final String noteId;
  final String title;
  final String subject;
  final int semester;
  final String? branch;
  final String fileUrl;
  final String uploaderId;
  final String createdAt;

  NoteModel({
    required this.noteId,
    required this.title,
    required this.subject,
    required this.semester,
    this.branch,
    required this.fileUrl,
    required this.uploaderId,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId: json['note_id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      semester: json['semester'] as int,
      branch: json['branch'] as String?,
      fileUrl: json['file_url'] as String,
      uploaderId: json['uploader_id'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
