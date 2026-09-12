class Rol {
  final int id;
  final String nombre; // 'admin', 'socio', 'tesorero', etc.
  final String? descripcion;

  Rol({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
  };

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
  );
}