import 'api_client.dart';

class DashboardService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> buscarSaldosGerais() async {
    try {
      final response = await _client.dio.get('/dashboard');
      return response.data['data'] ?? {};
    } catch (e) {
      return {'receber': 0.0, 'pagar': 0.0};
    }
  }
}
