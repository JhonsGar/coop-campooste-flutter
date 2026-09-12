class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final String categoria;
  final double precio;
  final double? costo;
  final int stock;
  final String? imagenUrl;
  final String? proveedor;
  final String estado;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.precio,
    this.costo,
    required this.stock,
    this.imagenUrl,
    this.proveedor,
    required this.estado,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      precio: (json['precio'] as num).toDouble(),
      costo: json['costo'] != null ? (json['costo'] as num).toDouble() : null,
      stock: json['stock'],
      imagenUrl: json['imagen_url'],
      proveedor: json['proveedor'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'costo': costo,
      'stock': stock,
      'imagen_url': imagenUrl,
      'proveedor': proveedor,
      'estado': estado,
    };
  }
}