import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://127.0.0.1:5000/api';
  }

  static String? authToken;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('authToken');
    } catch (e) {
      authToken = null;
    }
  }

  static Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
    return headers;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'erro', 'mensagem': 'Falha na conexão com o servidor'};
    }
  }

  // --- AUTENTICAÇÃO ---
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final data = await _post('/auth/login', {'email': email, 'senha': senha});
    if (data['status'] == 'sucesso') {
      authToken = data['data']?['token'];
      try {
        final prefs = await SharedPreferences.getInstance();
        if (authToken != null) await prefs.setString('authToken', authToken!);
      } catch (e) {}
    }
    return data;
  }

  static Future<Map<String, dynamic>> cadastrar(
    String nome,
    String email,
    String senha,
  ) async {
    return _post('/auth/cadastro', {
      'nome': nome,
      'email': email,
      'senha': senha,
    });
  }

  static Future<Map<String, dynamic>> recuperarSenha(String email) async {
    return _post('/usuarios/recuperar-senha', {'email': email});
  }

  static Future<void> logout() async {
    authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
    } catch (e) {}
  }

  // --- DASHBOARD ---
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // --- GRUPOS ---
  static Future<List<dynamic>> getGrupos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grupos'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> salvarGrupo(
    String nome, {
    String? descricao,
    int? id,
  }) async {
    try {
      final url = id == null ? '$baseUrl/grupos' : '$baseUrl/grupos/$id';
      final body = <String, dynamic>{'nome': nome};
      if (descricao != null && descricao.isNotEmpty) {
        body['descricao'] = descricao;
      }
      final response = await (id == null
          ? http.post(
              Uri.parse(url),
              headers: _headers(),
              body: jsonEncode(body),
            )
          : http.put(
              Uri.parse(url),
              headers: _headers(),
              body: jsonEncode(body),
            ));

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'ok': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'status': decoded['status'],
        'mensagem':
            decoded['mensagem'] ?? decoded['message'] ?? 'Erro desconhecido',
      };
    } catch (e) {
      return {
        'ok': false,
        'statusCode': 0,
        'status': 'erro',
        'mensagem': 'Falha na conexão com o servidor',
      };
    }
  }

  static Future<bool> deletarGrupo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/grupos/$id'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- DESPESAS ---
  static Future<List<dynamic>> getDespesas(int grupoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/despesas/grupo/$grupoId'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> salvarDespesa(
    Map<String, dynamic> dados, {
    int? id,
  }) async {
    try {
      final url = id == null ? '$baseUrl/despesas' : '$baseUrl/despesas/$id';
      final response = await (id == null
          ? http.post(
              Uri.parse(url),
              headers: _headers(),
              body: jsonEncode(dados),
            )
          : http.put(
              Uri.parse(url),
              headers: _headers(),
              body: jsonEncode(dados),
            ));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletarDespesa(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/despesas/$id'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getSaldos(int grupoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saldos/grupo/$grupoId'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- PARTICIPANTES ---
  static Future<List<dynamic>> getParticipantes(int grupoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/participantes/grupo/$grupoId'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> adicionarParticipante(int grupoId, int usuarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/participantes'),
        headers: _headers(),
        body: jsonEncode({'grupo_id': grupoId, 'usuario_id': usuarioId}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removerParticipante(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/participantes/$id'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['data'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<bool> atualizarPerfil(
    String nome,
    String email, {
    String? senha,
  }) async {
    try {
      final body = {'nome': nome, 'email': email};
      if (senha != null && senha.isNotEmpty) {
        body['senha'] = senha;
      }
      final response = await http.put(
        Uri.parse('$baseUrl/auth/atualizar'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletarConta() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        authToken = null;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('authToken');
        } catch (e) {}
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> criarSaldo(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saldos'),
        headers: _headers(),
        body: jsonEncode(dados),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> atualizarSaldo(
    int id,
    double saldo, {
    int? usuarioId,
  }) async {
    try {
      final Map<String, dynamic> body = {'saldo': saldo};
      if (usuarioId != null) {
        body['usuario_id'] = usuarioId;
      }
      final response = await http.put(
        Uri.parse('$baseUrl/saldos/$id'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletarSaldo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/saldos/$id'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
