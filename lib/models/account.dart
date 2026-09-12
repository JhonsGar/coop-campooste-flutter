import 'package:flutter/material.dart';

class Account {
  final int id;
  final String numeroCuenta;
  final String tipoCuenta;
  final double saldo;
  final double tasaInteres;
  final DateTime fechaApertura;
  final String estado;

  Account({
    required this.id,
    required this.numeroCuenta,
    required this.tipoCuenta,
    required this.saldo,
    required this.tasaInteres,
    required this.fechaApertura,
    required this.estado,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      numeroCuenta: json['numero_cuenta'] ?? '',
      tipoCuenta: json['tipo_cuenta'] ?? '',
      saldo: (json['saldo'] ?? 0).toDouble(),
      tasaInteres: (json['tasa_interes'] ?? 0).toDouble(),
      fechaApertura: DateTime.tryParse(json['fecha_apertura'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? 'activa',
    );
  }

  String get tipoLabel {
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

  IconData get icon {
    switch (tipoCuenta) {
      case 'ahorro_retirable':
        return Icons.savings;
      case 'ahorro_inversion':
        return Icons.trending_up;
      case 'aportacion':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
  }
}