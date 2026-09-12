import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompraService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> realizarCompra({
    required List<Map<String, dynamic>> items,
    required String metodoPago,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final response = await http.post(
      Uri.parse('$baseUrl/compras'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'metodo_pago': metodoPago,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al realizar compra');
    }
  }

  Future<List> getMisCompras() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final response = await http.get(
      Uri.parse('$baseUrl/compras/mis-compras'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar compras');
    }
  }
}