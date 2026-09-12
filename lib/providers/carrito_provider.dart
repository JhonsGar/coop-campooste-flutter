import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';

class CarritoProvider extends ChangeNotifier {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  void agregarProducto(Producto producto, {int cantidad = 1}) {
    final existing = _items.firstWhere(
          (item) => item.producto.id == producto.id,
      orElse: () => CarritoItem(producto: producto, cantidad: 0),
    );

    if (existing.cantidad > 0) {
      existing.cantidad += cantidad;
    } else {
      _items.add(CarritoItem(producto: producto, cantidad: cantidad));
    }
    notifyListeners();
  }

  void removerProducto(int productoId) {
    _items.removeWhere((item) => item.producto.id == productoId);
    notifyListeners();
  }

  void actualizarCantidad(int productoId, int nuevaCantidad) {
    final item = _items.firstWhere((item) => item.producto.id == productoId);
    if (nuevaCantidad <= 0) {
      removerProducto(productoId);
    } else {
      item.cantidad = nuevaCantidad;
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}