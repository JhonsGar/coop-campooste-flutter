import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aporte.dart';
import '../utils/constants.dart';

class AporteService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }

  Future<List<Aporte>> getMisAportes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/aportes/mis-aportes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Aporte.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar aportes (${response.statusCode})');
  }

  Future<Map<String, dynamic>> getMisTotales() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/aportes/mis-totales'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error al cargar totales (${response.statusCode})');
  }

  Future<Aporte> crearAporte({
    required int socioId,
    required double monto,
    required String tipo,
    String? descripcion,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/aportes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'socioId': socioId,
        'monto': monto,
        'tipo': tipo,
        'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Aporte.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final error = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Error al crear aporte');
  }
}