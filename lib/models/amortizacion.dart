class Amortizacion {
  final int id;
  final int prestamoId;
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final double montoCuota;
  final double capital;
  final double intereses;
  final String estado; // 'pagado', 'pendiente', 'vencido'
  final DateTime? fechaPago;
  final double? montoPagado;

  Amortizacion({
    required this.id,
    required this.prestamoId,
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.montoCuota,
    required this.capital,
    required this.intereses,
    required this.estado,
    this.fechaPago,
    this.montoPagado,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'prestamoId': prestamoId,
    'numeroCuota': numeroCuota,
    'fechaVencimiento': fechaVencimiento.toIso8601String(),
    'montoCuota': montoCuota,
    'capital': capital,
    'intereses': intereses,
    'estado': estado,
    'fechaPago': fechaPago?.toIso8601String(),
    'montoPagado': montoPagado,
  };

  factory Amortizacion.fromJson(Map<String, dynamic> json) => Amortizacion(
    id: json['id'],
    prestamoId: json['prestamoId'],
    numeroCuota: json['numeroCuota'],
    fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
    montoCuota: (json['montoCuota'] as num).toDouble(),
    capital: (json['capital'] as num).toDouble(),
    intereses: (json['intereses'] as num).toDouble(),
    estado: json['estado'],
    fechaPago: json['fechaPago'] != null ? DateTime.parse(json['fechaPago']) : null,
    montoPagado: json['montoPagado'] != null ? (json['montoPagado'] as num).toDouble() : null,
  );
}