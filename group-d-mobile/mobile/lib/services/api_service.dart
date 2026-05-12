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

  Future<Map<String, dynamic>> get(String path) async {
    final res = await dio.get<Map<String, dynamic>>(path);
    return unwrap(res.data);
  }

  Map<String, dynamic> unwrap(Map<String, dynamic>? body) {
    if (body == null) return const {};
    if (body['status'] == 'success') {
      return (body['data'] as Map<String, dynamic>?) ?? const {};
    }

    throw ApiException(
      status: body['status']?.toString() ?? 'error',
      message: body['message']?.toString() ?? 'Unknown error',
    );
  }
}

class ApiException implements Exception {
  ApiException({required this.status, required this.message});

  final String status;
  final String message;

  @override
  String toString() => 'ApiException($status): $message';
}
