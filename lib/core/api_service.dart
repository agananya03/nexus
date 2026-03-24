import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String message = 'Something went wrong';
        if (e.response != null && e.response?.data != null) {
          if (e.response!.data is Map && e.response!.data.containsKey('detail')) {
             message = e.response!.data['detail'].toString();
          }
        }
        final customError = DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: message,
        );
        return handler.next(customError);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    return response.data;
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post(path, data: body);
    return response.data;
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _dio.put(path, data: body);
    return response.data;
  }

  Future<dynamic> delete(String path) async {
    final response = await _dio.delete(path);
    return response.data;
  }

  Future<dynamic> postMultipart(String path, Map<String, String> fields, {String? filePath, String? fileField}) async {
    final formData = FormData.fromMap(fields);
    if (filePath != null && fileField != null) {
      final fileName = filePath.split('/').last;
      formData.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(filePath, filename: fileName),
      ));
    }
    
    final response = await _dio.post(path, data: formData);
    return response.data;
  }
}

final apiService = ApiService();
