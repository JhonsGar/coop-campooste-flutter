class Pago {
  final int id;
  final int socioId;
  final double monto;
  final DateTime fecha;
  final String tipo; // 'cuota_prestamo', 'aporte', 'compra', 'servicio'
  final int? referenciaId; // ID del préstamo, compra, etc.
  final String metodoPago; // 'efectivo', 'transferencia', 'tarjeta'
  final String? referenciaExterna;
  final String estado; // 'completado', 'pendiente', 'rechazado'

  Pago({
    required this.id,
    required this.socioId,
    required this.monto,
    required this.fecha,
    required this.tipo,
    this.referenciaId,
    required this.metodoPago,
    this.referenciaExterna,
    required this.estado,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'socioId': socioId,
    'monto': monto,
    'fecha': fecha.toIso8601String(),
    'tipo': tipo,
    'referenciaId': referenciaId,
    'metodoPago': metodoPago,
    'referenciaExterna': referenciaExterna,
    'estado': estado,
  };

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
    id: json['id'],
    socioId: json['socioId'],
    monto: (json['monto'] as num).toDouble(),
    fecha: DateTime.parse(json['fecha']),
    tipo: json['tipo'],
    referenciaId: json['referenciaId'],
    metodoPago: json['metodoPago'],
    referenciaExterna: json['referenciaExterna'],
    estado: json['estado'],
  );
}