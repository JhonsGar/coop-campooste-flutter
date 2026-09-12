class Socio {
  final int id;
  final String cedula;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? rol;
  final String? estado;

  Socio({
    required this.id,
    required this.cedula,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    this.direccion,
    this.rol,
    this.estado,
  });

  factory Socio.fromJson(Map<String, dynamic> json) {
    // ✅ Extraer el primer rol del array 'roles' que envía el backend
    String? rolExtraido;

    final rolesJson = json['roles'];
    if (rolesJson is List && rolesJson.isNotEmpty) {
      final primerRol = rolesJson.first;
      rolExtraido = primerRol is String ? primerRol : primerRol['nombre'] as String?;
    } else if (json['rol'] is String && (json['rol'] as String).isNotEmpty) {
      // Fallback por si el backend manda 'rol' como string en algún endpoint
      rolExtraido = json['rol'] as String;
    }

    return Socio(
      id: json['id'] as int? ?? 0,
      cedula: json['cedula'] as String? ?? '',
      nombreCompleto: (json['nombreCompleto'] ?? json['nombre_completo']) as String? ?? '',
      email: json['email'] as String? ?? '',
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      rol: rolExtraido ?? 'socio',
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedula': cedula,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'rol': rol,
      'estado': estado,
    };
  }

  bool get esAdmin {
    final rolNormalizado = (rol ?? '').toLowerCase();
    return rolNormalizado == 'admin' || rolNormalizado == 'administrador';
  }

  bool get esCajero {
    final rolNormalizado = (rol ?? '').toLowerCase();
    return rolNormalizado == 'cajero' || esAdmin;
  }

  bool get esSecretario {
    final rolNormalizado = (rol ?? '').toLowerCase();
    return rolNormalizado == 'secretario';
  }
}