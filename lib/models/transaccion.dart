class Transaccion {
  final int id;
  final int cuentaId;
  final int socioId;
  final String tipo;
  final double monto;
  final double saldoAnterior;
  final double saldoNuevo;
  final String? descripcion;
  final String? referencia;
  final String estado;
  final String fechaTransaccion;

  Transaccion({
    required this.id,
    required this.cuentaId,
    required this.socioId,
    required this.tipo,
    required this.monto,
    required this.saldoAnterior,
    required this.saldoNuevo,
    this.descripcion,
    this.referencia,
    required this.estado,
    required this.fechaTransaccion,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'] as int,
      cuentaId: json['cuentaId'] as int,
      socioId: json['socioId'] as int,
      tipo: json['tipo'] as String,
      monto: (json['monto'] as num).toDouble(),
      saldoAnterior: (json['saldo_anterior'] as num?)?.toDouble() ?? 0,
      saldoNuevo: (json['saldo_nuevo'] as num?)?.toDouble() ?? 0,
      descripcion: json['descripcion'] as String?,
      referencia: json['referencia'] as String?,
      estado: json['estado'] as String? ?? 'completada',
      fechaTransaccion: json['fecha_transaccion'] as String,
    );
  }

  bool get esIngreso => tipo == 'deposito' || tipo == 'interes' || tipo == 'aportacion';
}