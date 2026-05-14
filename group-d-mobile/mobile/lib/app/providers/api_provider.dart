import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../env.dart';
import 'auth_provider.dart';

/// Dio configuré pour le backend FastAPI du Groupe D.
///
/// MIGRATION HINT
/// ──────────────────────────────────────────────────────────────────────────
/// Dans le monorepo mobile, utiliser `MiraDioClient`
/// (`packages/mira_api_client/lib/src/mira_dio_client.dart`) qui ajoute :
///   - `AuthInterceptor` : refresh JWT 401 + retry transparent
///   - `RetryInterceptor` : 5xx + connection errors backoff
///   - `ErrorInterceptor` : mapping vers `MiraApiException`
///   - `MiraEnvironment` : URLs par env (dev/staging/prod)
/// ──────────────────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  final token = ref.watch(currentAccessTokenProvider);

  final dio = Dio(ApiService.baseOptions(accessToken: token));

  // Log basique (à remplacer par TalkerDioLogger côté mira_chat)
  dio.interceptors.add(LogInterceptor(
    requestBody: false,
    responseBody: false,
    requestHeader: false,
    responseHeader: false,
    error: true,
  ),);

  return dio;
});

/// Helper qui appelle le backend et déballe la réponse JSend
/// `{status: "success", data: {...}}` — convention Hello Mira.
class ApiClient extends ApiService {
  ApiClient(super.dio);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await dio.post<Map<String, dynamic>>(path, data: body);
    return unwrap(res.data);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
