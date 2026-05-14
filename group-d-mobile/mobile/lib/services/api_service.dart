import 'package:dio/dio.dart';

import '../app/env.dart';

class ApiService {
  ApiService(this.dio);

  final Dio dio;

  static String get baseUrl => Env.apiBaseUrl;

  static BaseOptions baseOptions({String? accessToken}) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Future<Object?> getAny(String path) async {
    final res = await dio.get<Object?>(path);
    return unwrapAny(res.data);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final data = await getAny(path);
    if (data is Map<String, dynamic>) return data;

    throw ApiException(
      status: 'invalid_response',
      message: 'Expected object response for $path',
    );
  }

  dynamic unwrapAny(Object? body) {
    if (body == null) return null;
    if (body is! Map<String, dynamic>) return body;
    if (body['status'] == 'success') return body['data'];
    if (!body.containsKey('status')) return body;

    throw ApiException(
      status: body['status']?.toString() ?? 'error',
      message: body['message']?.toString() ?? 'Unknown error',
    );
  }

  Map<String, dynamic> unwrap(Map<String, dynamic>? body) {
    if (body == null) return const {};
    final data = unwrapAny(body);
    return data is Map<String, dynamic> ? data : const {};
  }
}

class ApiException implements Exception {
  ApiException({required this.status, required this.message});

  final String status;
  final String message;

  @override
  String toString() => 'ApiException($status): $message';
}
