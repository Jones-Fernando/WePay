import '../models/despesa_model.dart';
import 'api_client.dart';

class DespesaService {
  final ApiClient _client = ApiClient();

  Future<List<DespesaModel>> listarPorGrupo(int grupoId) async {
    try {
      final response = await _client.dio.get('/despesas/grupo/$grupoId');
      return (response.data['data'] as List)
          .map((d) => DespesaModel.fromJson(d))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> criar(DespesaModel despesa) async {
    try {
      final response = await _client.dio.post(
        '/despesas',
        data: despesa.toJson(),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> atualizar(int id, DespesaModel despesa) async {
    try {
      final response = await _client.dio.put(
        '/despesas/$id',
        data: despesa.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletar(int id) async {
    try {
      final response = await _client.dio.delete('/despesas/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
