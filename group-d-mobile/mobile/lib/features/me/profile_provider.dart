import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/api_provider.dart';
import 'profile_model.dart';

final profileProvider = FutureProvider<ProfileSummary>((ref) async {
  final data = await ref.read(apiClientProvider).get('/v1/me/profile');
  return ProfileSummary.fromJson(data);
});
