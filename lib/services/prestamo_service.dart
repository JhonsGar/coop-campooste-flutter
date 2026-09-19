import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prestamo.dart';
import '../utils/constants.dart';

class PrestamoService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  Future<List<Prestamo>> getMisPrestamos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/prestamos/mis-prestamos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Prestamo.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar préstamos (${response.statusCode})');
  }

  Future<Prestamo> solicitarPrestamo({
    required int socioId,
    required double monto,
    required double tasaInteres,
    required int plazoMeses,
    required String tipoPrestamo,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/prestamos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'socioId': socioId,
        'monto_solicitado': monto,
        'tasa_interes': tasaInteres,
        'plazo_meses': plazoMeses,
        'tipo_prestamo': tipoPrestamo,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Prestamo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Error al solicitar préstamo');
  }

  Future<void> pagarCuota(int cuotaId) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/prestamos/cuotas/$cuotaId/pagar'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al pagar cuota (${response.statusCode})');
    }
  }
}