import 'producto.dart';

class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({
    required this.producto,
    this.cantidad = 1,
  });

  double get subtotal => producto.precio * cantidad;

  Map<String, dynamic> toJson() => {
    'productoId': producto.id,
    'cantidad': cantidad,
    'producto': producto.toJson(),
  };

  factory CarritoItem.fromJson(Map<String, dynamic> json) => CarritoItem(
    producto: Producto.fromJson(json['producto']),
    cantidad: json['cantidad'],
  );
}