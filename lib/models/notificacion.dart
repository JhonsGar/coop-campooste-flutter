class Notificacion {
  final int id;
  final int socioId;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  bool leida;

  Notificacion({
    required this.id,
    required this.socioId,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'socioId': socioId,
    'titulo': titulo,
    'mensaje': mensaje,
    'fecha': fecha.toIso8601String(),
    'leida': leida,
  };

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
    id: json['id'],
    socioId: json['socioId'],
    titulo: json['titulo'],
    mensaje: json['mensaje'],
    fecha: DateTime.parse(json['fecha']),
    leida: json['leida'] ?? false,
  );
}