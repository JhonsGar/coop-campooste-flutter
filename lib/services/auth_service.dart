import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../utils/constants.dart';

class AuthService {
  Future<AuthResponse> login({
    required String cedula,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cedula': cedula,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(data as Map<String, dynamic>);
    } else {
      final message = data['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      throw Exception(message?.toString() ?? 'Error al iniciar sesión');
    }
  }

  Future<AuthResponse> register({
    required String cedula,
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cedula': cedula,
        'nombre_completo': nombreCompleto,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(data as Map<String, dynamic>);
    } else {
      final message = data['message'];
      if (message is List) {
        throw Exception(message.join(', '));
      }
      throw Exception(message?.toString() ?? 'Error en el registro');
    }
  }
}