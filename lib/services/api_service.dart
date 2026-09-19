import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<Map<String, String>> _headers(String? token) async {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint, {String? token}) async {
    final r = await http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: await _headers(token),
    );
    return _handle(r);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final r = await http.post(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: await _headers(token),
      body: jsonEncode(body),
    );
    return _handle(r);
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final r = await http.patch(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: await _headers(token),
      body: jsonEncode(body),
    );
    return _handle(r);
  }

  // Método DELETE agregado
  static Future<dynamic> delete(String endpoint, {String? token}) async {
    final r = await http.delete(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: await _headers(token),
    );
    return _handle(r);
  }

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? '{}' : r.body;
    final data = jsonDecode(body);
    if (r.statusCode >= 200 && r.statusCode < 300) return data;
    final msg = (data['message'] is List)
        ? (data['message'] as List).join(', ')
        : (data['message'] ?? 'Error ${r.statusCode}');
    throw Exception(msg);
  }
}