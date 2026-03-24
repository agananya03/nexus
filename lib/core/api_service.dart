import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // ── Internships ──────────────────────────────────────────────
  Future<List<dynamic>> getInternships({String? domain, String? location}) async {
    final params = <String, dynamic>{};
    if (domain != null && domain.isNotEmpty) params['domain'] = domain;
    if (location != null && location.isNotEmpty) params['location'] = location;
    final res = await _dio.get('/internships/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getInternshipById(String id) async {
    final res = await _dio.get('/internships/$id');
    return res.data as Map<String, dynamic>;
  }

  // ── Events ───────────────────────────────────────────────────
  Future<List<dynamic>> getEvents({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null && category.toLowerCase() != 'all') {
      params['category'] = category;
    }
    final res = await _dio.get('/events/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    final res = await _dio.get('/events/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> toggleRsvp(String eventId) async {
    final res = await _dio.post('/events/$eventId/rsvp');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEventRsvps(String eventId) async {
    final res = await _dio.get('/events/$eventId/rsvps');
    return res.data as List<dynamic>;
  }

  // ── Books ────────────────────────────────────────────────────
  Future<List<dynamic>> getBooks({String? subject, String? condition}) async {
    final params = <String, dynamic>{};
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (condition != null && condition.isNotEmpty) params['condition'] = condition;
    final res = await _dio.get('/books/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getBookById(String id) async {
    final res = await _dio.get('/books/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<void> markBookSold(String bookId) async {
    await _dio.put('/books/$bookId/sold');
  }

  Future<Map<String, dynamic>> createBook(FormData formData) async {
    final res = await _dio.post(
      '/books/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data as Map<String, dynamic>;
  }

  // ── Doubt Solver ──────────────────────────────────────────────
  Future<List<dynamic>> getDoubts({String? subject, bool? isResolved}) async {
    final params = <String, dynamic>{};
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (isResolved != null) params['is_resolved'] = isResolved.toString();
    final res = await _dio.get('/doubts/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getDoubtById(String id) async {
    final res = await _dio.get('/doubts/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postDoubt({
    required String question,
    String? description,
    required String subject,
    required int semester,
    required List<String> tags,
  }) async {
    final res = await _dio.post('/doubts/', data: {
      'question': question,
      'description': description,
      'subject': subject,
      'semester': semester,
      'tags': tags,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postAnswer(String doubtId, String content) async {
    final res = await _dio.post('/doubts/$doubtId/answers', data: {
      'content': content,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> toggleUpvote(String answerId) async {
    final res = await _dio.post('/answers/$answerId/upvote');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resolveDoubt(String doubtId, {String? acceptedAnswerId}) async {
    final res = await _dio.put('/doubts/$doubtId/resolve', data: {
      'accepted_answer_id': acceptedAnswerId,
    });
    return res.data as Map<String, dynamic>;
  }
}
