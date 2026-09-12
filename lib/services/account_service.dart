import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/account.dart';
import '../models/movement.dart';
import '../utils/constants.dart';

class AccountService {
  final _storage = const FlutterSecureStorage();

  /// Obtiene el token JWT guardado en la sesión
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Encabezados comunes para peticiones autenticadas
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 1. Carga las cuentas asociadas a un socio específico
  Future<List<Account>> getAccountsBySocio(int socioId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/cuentas/socio/$socioId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Account.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener cuentas: $e');
    }
  }

  /// 2. Carga el historial de movimientos/transacciones de una cuenta
  Future<List<Movement>> getMovements(int accountId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/cuentas/$accountId/transacciones'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Movement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar movimientos: $e');
    }
  }

  /// 3. Crea una nueva libreta / cuenta de ahorro para un socio
  Future<bool> crearCuenta({
    required int socioId,
    required String tipoCuenta, // 'AHORRO_RETIRABLE' o 'AHORRO_INVERSION'
    required double saldoInicial,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/cuentas'),
        headers: headers,
        body: jsonEncode({
          'socioId': socioId,
          'tipoCuenta': tipoCuenta,
          'saldoInicial': saldoInicial,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear la cuenta: $e');
    }
  }

  /// 4. Registra un Aporte o Retiro en la caja
  Future<bool> registrarTransaccion({
    required int accountId,
    required double monto,
    required String tipo, // 'APORTE' o 'RETIRO'
    String concepto = 'Operación por caja',
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/cuentas/$accountId/transacciones'),
        headers: headers,
        body: jsonEncode({
          'monto': monto,
          'tipo': tipo,
          'concepto': concepto,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('No se pudo conectar con el servidor: $e');
    }
  }
}