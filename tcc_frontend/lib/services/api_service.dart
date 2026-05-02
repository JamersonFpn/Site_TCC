import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8000';

class ApiService {
  static Future<bool> enviarChamado({
    required String nome,
    required String email,
    required String telefone,
    required String descricao,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chamados'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'descricao': descricao,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> login(String usuario, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': usuario, 'senha': senha}),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getChamados() async {
    final response = await http.get(Uri.parse('$baseUrl/api/chamados'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> atualizarStatus(int id, String novoStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/chamados/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status_chamado': novoStatus}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> removerChamado(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/chamados/$id'),
    );
    return response.statusCode == 200;
  }
}