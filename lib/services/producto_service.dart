import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductoService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<List<Producto>> getProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final response = await http.get(
      Uri.parse('$baseUrl/productos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<Producto> getProducto(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final response = await http.get(
      Uri.parse('$baseUrl/productos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Producto no encontrado');
    }
  }

  Future<Producto> actualizarProducto(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final response = await http.patch(
      Uri.parse('$baseUrl/productos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar producto');
    }
  }
}