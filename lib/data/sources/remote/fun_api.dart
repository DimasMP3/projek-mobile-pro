import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../models/fun_item_model.dart';
import '../../../core/env.dart';

class FunApi {
  final Dio _dio = ApiClient.dio;

  Future<List<FunItem>> fetchFunItems() async {
    final res = await _dio.get('/fun');
    final List data = res.data['data'] as List? ?? [];
    final base = AppEnv.apiBaseUrl; // to resolve asset URL
    return data.map((j) => FunItem.fromJson(j as Map<String, dynamic>, baseUrl: base)).toList();
  }
}

