class Prestamo {
  final int id;
  final int socioId;
  final String? numeroPrestamo;
  final double montoSolicitado;
  final double? montoAprobado;
  final double tasaInteres;
  final int plazoMeses;
  final double? cuotaMensual;
  final double? saldoPendiente;
  final String estado;
  final String tipoPrestamo;
  final String? fechaSolicitud;
  final String? fechaAprobacion;
  final String? fechaDesembolso;
  final List<Cuota> cuotas;

  Prestamo({
    required this.id,
    required this.socioId,
    this.numeroPrestamo,
    required this.montoSolicitado,
    this.montoAprobado,
    required this.tasaInteres,
    required this.plazoMeses,
    this.cuotaMensual,
    this.saldoPendiente,
    required this.estado,
    required this.tipoPrestamo,
    this.fechaSolicitud,
    this.fechaAprobacion,
    this.fechaDesembolso,
    this.cuotas = const [],
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'] as int,
      socioId: json['socioId'] as int,
      numeroPrestamo: json['numero_prestamo'] as String?,
      montoSolicitado: (json['monto_solicitado'] as num).toDouble(),
      montoAprobado: json['monto_aprobado'] != null
          ? (json['monto_aprobado'] as num).toDouble()
          : null,
      tasaInteres: (json['tasa_interes'] as num).toDouble(),
      plazoMeses: json['plazo_meses'] as int,
      cuotaMensual: json['cuota_mensual'] != null
          ? (json['cuota_mensual'] as num).toDouble()
          : null,
      saldoPendiente: json['saldo_pendiente'] != null
          ? (json['saldo_pendiente'] as num).toDouble()
          : null,
      estado: json['estado'] as String,
      tipoPrestamo: json['tipo_prestamo'] as String,
      fechaSolicitud: json['fecha_solicitud'] as String?,
      fechaAprobacion: json['fecha_aprobacion'] as String?,
      fechaDesembolso: json['fecha_desembolso'] as String?,
      cuotas: (json['cuotas'] as List<dynamic>?)
          ?.map((c) => Cuota.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// ============================================================
// CLASE CUOTA (incluida en el mismo archivo)
// ============================================================
class Cuota {
  final int id;
  final int prestamoId;
  final int numeroCuota;
  final String fechaVencimiento;
  final double montoCapital;
  final double montoInteres;
  final double montoTotal;
  final String estado;
  final String? fechaPago;

  Cuota({
    required this.id,
    required this.prestamoId,
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.montoCapital,
    required this.montoInteres,
    required this.montoTotal,
    required this.estado,
    this.fechaPago,
  });

  factory Cuota.fromJson(Map<String, dynamic> json) {
    return Cuota(
      id: json['id'] as int,
      prestamoId: json['prestamoId'] as int,
      numeroCuota: json['numero_cuota'] as int,
      fechaVencimiento: json['fecha_vencimiento'] as String,
      montoCapital: (json['monto_capital'] as num).toDouble(),
      montoInteres: (json['monto_interes'] as num).toDouble(),
      montoTotal: (json['monto_total'] as num).toDouble(),
      estado: json['estado'] as String,
      fechaPago: json['fecha_pago'] as String?,
    );
  }

  bool get estaPagada => estado == 'pagada';
}