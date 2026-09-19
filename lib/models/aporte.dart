class Aporte {
  final int id;
  final int socioId;
  final double monto;
  final String tipo;
  final String? descripcion;
  final String? concepto;
  final String fecha;
  final String estado;

  Aporte({
    required this.id,
    required this.socioId,
    required this.monto,
    required this.tipo,
    this.descripcion,
    this.concepto,
    required this.fecha,
    required this.estado,
  });

  factory Aporte.fromJson(Map<String, dynamic> json) {
    return Aporte(
      id: json['id'] as int,
      socioId: json['socioId'] as int,
      monto: (json['monto'] as num).toDouble(),
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String?,
      concepto: json['concepto'] as String?,
      fecha: json['fecha'] as String,
      estado: json['estado'] as String? ?? 'activo',
    );
  }
}