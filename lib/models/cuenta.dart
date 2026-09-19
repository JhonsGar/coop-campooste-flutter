class Cuenta {
  final int id;
  final int socioId;
  final String numeroCuenta;
  final String tipoCuenta;
  final double saldo;
  final double tasaInteres;
  final String fechaApertura;
  final String estado;

  Cuenta({
    required this.id,
    required this.socioId,
    required this.numeroCuenta,
    required this.tipoCuenta,
    required this.saldo,
    required this.tasaInteres,
    required this.fechaApertura,
    required this.estado,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    return Cuenta(
      id: json['id'] as int,
      socioId: json['socioId'] as int,
      numeroCuenta: json['numero_cuenta'] as String,
      tipoCuenta: json['tipo_cuenta'] as String,
      saldo: (json['saldo'] as num).toDouble(),
      tasaInteres: (json['tasa_interes'] as num?)?.toDouble() ?? 0,
      fechaApertura: json['fecha_apertura'] as String,
      estado: json['estado'] as String? ?? 'activa',
    );
  }

  String get tipoCuentaLabel {
    switch (tipoCuenta) {
      case 'ahorro_retirable':
        return 'Ahorro Retirable';
      case 'ahorro_inversion':
        return 'Ahorro Inversión';
      case 'aportacion':
        return 'Aportación';
      default:
        return tipoCuenta;
    }
  }
}