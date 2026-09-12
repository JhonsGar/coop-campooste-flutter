class DetalleCompra {
  final int id;
  final int compraId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleCompra({
    required this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'compraId': compraId,
    'productoId': productoId,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'subtotal': subtotal,
  };

  factory DetalleCompra.fromJson(Map<String, dynamic> json) => DetalleCompra(
    id: json['id'],
    compraId: json['compraId'],
    productoId: json['productoId'],
    cantidad: json['cantidad'],
    precioUnitario: (json['precioUnitario'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}