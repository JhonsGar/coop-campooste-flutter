import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cuenta.dart';
import '../models/transaccion.dart';
import '../utils/constants.dart';

class CuentaService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  Future<List<Cuenta>> getMisCuentas() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cuentas/mis-cuentas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Cuenta.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar cuentas (${response.statusCode})');
  }

  Future<List<Transaccion>> getTransacciones(int cuentaId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cuentas/$cuentaId/transacciones'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Transaccion.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar transacciones (${response.statusCode})');
  }

  Future<Cuenta> crearCuenta(int socioId, String tipoCuenta) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cuentas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'socioId': socioId, 'tipoCuenta': tipoCuenta}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Cuenta.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Error al crear cuenta');
  }

  Future<Transaccion> depositar(int cuentaId, double monto, String? descripcion) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cuentas/$cuentaId/depositar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'monto': monto, 'descripcion': descripcion}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Transaccion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Error al depositar');
  }

  Future<Transaccion> retirar(int cuentaId, double monto, String? descripcion) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cuentas/$cuentaId/retirar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'monto': monto, 'descripcion': descripcion}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Transaccion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Error al retirar');
  }
}
