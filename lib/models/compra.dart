import 'detalle_compra.dart';

class Compra {
  final int id;
  final int socioId; // o adminId
  final DateTime fecha;
  final double total;
  final String estado; // 'pendiente', 'completada', 'cancelada'
  final String? metodoPago;
  final String? referencia;
  List<DetalleCompra>? detalles; // opcional, para cargar en cascada

  Compra({
    required this.id,
    required this.socioId,
    required this.fecha,
    required this.total,
    required this.estado,
    this.metodoPago,
    this.referencia,
    this.detalles,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'socioId': socioId,
    'fecha': fecha.toIso8601String(),
    'total': total,
    'estado': estado,
    'metodoPago': metodoPago,
    'referencia': referencia,
    'detalles': detalles?.map((d) => d.toJson()).toList(),
  };

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
    id: json['id'],
    socioId: json['socioId'],
    fecha: DateTime.parse(json['fecha']),
    total: (json['total'] as num).toDouble(),
    estado: json['estado'],
    metodoPago: json['metodoPago'],
    referencia: json['referencia'],
    detalles: json['detalles'] != null
        ? (json['detalles'] as List).map((d) => DetalleCompra.fromJson(d)).toList()
        : null,
  );
}