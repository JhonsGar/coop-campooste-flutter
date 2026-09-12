 class User {
  final int id;
  final String cedula;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String direccion;
  final DateTime fechaIngreso;
  final String estado;

  User({
    required this.id,
    required this.cedula,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.fechaIngreso,
    required this.estado,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      cedula: json['cedula'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaIngreso: DateTime.tryParse(json['fecha_ingreso'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedula': cedula,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'estado': estado,
    };
  }
}