class Transaccion {
  final String id;
  final String titulo;
  final double monto;
  final DateTime fecha;
  final bool esIngreso; // true: Ingreso, false: Egreso/Gasto

  Transaccion({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.fecha,
    this.esIngreso = false,
  });
}