import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});