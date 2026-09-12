import 'package:flutter/material.dart';

class Movement {
  final int id;
  final int cuentaId;
  final String tipoMovimiento;
  final double monto;
  final double saldoAnterior;
  final double saldoNuevo;
  final String descripcion;
  final String referencia;
  final DateTime fechaTransaccion;

  Movement({
    required this.id,
    required this.cuentaId,
    required this.tipoMovimiento,
    required this.monto,
    required this.saldoAnterior,
    required this.saldoNuevo,
    required this.descripcion,
    required this.referencia,
    required this.fechaTransaccion,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id'] ?? 0,
      cuentaId: json['cuenta_id'] ?? 0,
      tipoMovimiento: json['tipo_movimiento'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      saldoAnterior: (json['saldo_anterior'] ?? 0).toDouble(),
      saldoNuevo: (json['saldo_nuevo'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      referencia: json['referencia'] ?? '',
      fechaTransaccion: DateTime.tryParse(json['fecha_transaccion'] ?? '') ?? DateTime.now(),
    );
  }

  String get tipoLabel {
    switch (tipoMovimiento) {
      case 'deposito':
        return 'Depósito';
      case 'retiro':
        return 'Retiro';
      case 'transferencia':
        return 'Transferencia';
      case 'pago_prestamo':
        return 'Pago de Préstamo';
      case 'interes':
        return 'Interés';
      default:
        return tipoMovimiento;
    }
  }

  bool get isIngreso =>
      tipoMovimiento == 'deposito' ||
          tipoMovimiento == 'interes' ||
          tipoMovimiento == 'transferencia';

  IconData get icon {
    return isIngreso ? Icons.arrow_upward : Icons.arrow_downward;
  }

  Color get color {
    return isIngreso ? Colors.green : Colors.red;
  }
}