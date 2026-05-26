import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<bool> login(String email, String senha) async {
    try {
      final response = await _client.dio.post(
        '/auth/login',
        data: {'email': email, 'senha': senha},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cadastro(String email, String senha) async {
    try {
      final response = await _client.dio.post(
        '/auth/cadastro',
        data: {'email': email, 'senha': senha},
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recuperarSenha(String email) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/recuperar-senha',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
