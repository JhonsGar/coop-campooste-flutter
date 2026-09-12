import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoProvider extends ChangeNotifier {
  final ProductoService _service = ProductoService();
  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProductos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await _service.getProductos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarProducto(int id, double nuevoPrecio, {int? nuevoStock}) async {
    try {
      final data = <String, dynamic>{'precio': nuevoPrecio};
      if (nuevoStock != null) data['stock'] = nuevoStock;

      final productoActualizado = await _service.actualizarProducto(id, data);

      final index = _productos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _productos[index] = productoActualizado;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar: $e');
    }
  }
}