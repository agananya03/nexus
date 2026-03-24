import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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
        String errorMessage = 'An error occurred';
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('detail')) {
            errorMessage = data['detail'];
          }
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: errorMessage,
            type: e.type,
            response: e.response));
      },
    ));
  }

  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    final response = await _dio.post(path, data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    if (response.data is List) {
      return {'data': response.data};
    }
    return response.data;
  }

  Future<Map<String, dynamic>> put(String path, dynamic body) async {
    final response = await _dio.put(path, data: body);
    return response.data;
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _dio.delete(path);
    return response.data;
  }

  Future<Map<String, dynamic>> postMultipart(String path, Map<String, String> fields, {String? filePath, String? fileField}) async {
    final formData = FormData.fromMap(fields);
    if (filePath != null && fileField != null) {
      formData.files.add(MapEntry(
        fileField,
        await MultipartFile.fromFile(filePath),
      ));
    }
    final response = await _dio.post(path, data: formData);
    return response.data;
  }
}

final apiService = ApiService();
