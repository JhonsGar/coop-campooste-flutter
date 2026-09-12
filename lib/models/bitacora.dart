class Bitacora {
  final int id;
  final int? socioId; // quien realizó la acción (puede ser null para sistema)
  final String accion; // 'login', 'compra', 'actualizacion', etc.
  final DateTime fecha;
  final String? detalles;
  final String? ip;

  Bitacora({
    required this.id,
    this.socioId,
    required this.accion,
    required this.fecha,
    this.detalles,
    this.ip,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'socioId': socioId,
    'accion': accion,
    'fecha': fecha.toIso8601String(),
    'detalles': detalles,
    'ip': ip,
  };

  factory Bitacora.fromJson(Map<String, dynamic> json) => Bitacora(
    id: json['id'],
    socioId: json['socioId'],
    accion: json['accion'],
    fecha: DateTime.parse(json['fecha']),
    detalles: json['detalles'],
    ip: json['ip'],
  );
}