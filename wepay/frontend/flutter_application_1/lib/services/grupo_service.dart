import '../models/grupo_model.dart';
import 'api_client.dart';

class GrupoService {
  final ApiClient _client = ApiClient();

  Future<List<GrupoModel>> listar() async {
    try {
      final response = await _client.dio.get('/grupos');
      return (response.data as List).map((g) => GrupoModel.fromJson(g)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> criar(GrupoModel grupo) async {
    try {
      final response = await _client.dio.post('/grupos', data: grupo.toJson());
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> atualizar(int id, GrupoModel grupo) async {
    try {
      final response = await _client.dio.put('/grupos/$id', data: grupo.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletar(int id) async {
    try {
      final response = await _client.dio.delete('/grupos/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}