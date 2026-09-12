class Aporte {
  final int id;
  final int socioId;
  final DateTime fecha;
  final double monto;
  final String tipo; // 'ordinario', 'extraordinario'
  final String? referencia;

  Aporte({
    required this.id,
    required this.socioId,
    required this.fecha,
    required this.monto,
    required this.tipo,
    this.referencia,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'socioId': socioId,
    'fecha': fecha.toIso8601String(),
    'monto': monto,
    'tipo': tipo,
    'referencia': referencia,
  };

  factory Aporte.fromJson(Map<String, dynamic> json) => Aporte(
    id: json['id'],
    socioId: json['socioId'],
    fecha: DateTime.parse(json['fecha']),
    monto: (json['monto'] as num).toDouble(),
    tipo: json['tipo'],
    referencia: json['referencia'],
  );
}