import 'package:flutter/material.dart';

class Loan {
  final int id;
  final double montoAprobado;
  final double tasaInteres;
  final int plazoMeses;
  final double cuotaMensual;
  final double saldoPendiente;
  final DateTime fechaAprobacion;
  final DateTime? fechaDesembolso;
  final String estado;
  final String tipoPrestamo;

  Loan({
    required this.id,
    required this.montoAprobado,
    required this.tasaInteres,
    required this.plazoMeses,
    required this.cuotaMensual,
    required this.saldoPendiente,
    required this.fechaAprobacion,
    this.fechaDesembolso,
    required this.estado,
    required this.tipoPrestamo,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? 0,
      montoAprobado: (json['monto_aprobado'] ?? 0).toDouble(),
      tasaInteres: (json['tasa_interes'] ?? 0).toDouble(),
      plazoMeses: json['plazo_meses'] ?? 0,
      cuotaMensual: (json['cuota_mensual'] ?? 0).toDouble(),
      saldoPendiente: (json['saldo_pendiente'] ?? 0).toDouble(),
      fechaAprobacion: DateTime.tryParse(json['fecha_aprobacion'] ?? '') ?? DateTime.now(),
      fechaDesembolso: json['fecha_desembolso'] != null
          ? DateTime.tryParse(json['fecha_desembolso'])
          : null,
      estado: json['estado'] ?? 'solicitado',
      tipoPrestamo: json['tipo_prestamo'] ?? 'personal',
    );
  }

  String get tipoLabel {
    switch (tipoPrestamo) {
      case 'personal':
        return 'Personal';
      case 'electrodomesticos':
        return 'Electrodomésticos';
      case 'escolar':
        return 'Escolar';
      case 'vivienda':
        return 'Vivienda';
      default:
        return tipoPrestamo;
    }
  }

  String get estadoLabel {
    switch (estado) {
      case 'solicitado':
        return 'Solicitado';
      case 'aprobado':
        return 'Aprobado';
      case 'desembolsado':
        return 'Desembolsado';
      case 'pagado':
        return 'Pagado';
      case 'vencido':
        return 'Vencido';
      default:
        return estado;
    }
  }

  Color get estadoColor {
    switch (estado) {
      case 'solicitado':
        return Colors.orange;
      case 'aprobado':
        return Colors.blue;
      case 'desembolsado':
        return Colors.green;
      case 'pagado':
        return Colors.grey;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}