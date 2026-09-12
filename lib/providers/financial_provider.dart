import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'as pw;
import 'package:printing/printing.dart';

class FinancialProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Registrar Inscripciones, Aportes y Retiros
  Future<bool> registrarOperacion({
    required int socioId,
    required String tipoOperacion, // 'INSCRIPCION', 'APORTE', 'RETIRO'
    required double monto,
    required String concepto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulación de interacción con API / NestJS
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al procesar la transacción: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Solicitud y Aprobación de Préstamos
  Future<bool> gestionarPrestamo({
    required int prestamoId,
    required String accion, // 'SOLICITAR', 'APROBAR', 'RECHAZAR'
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al gestionar el préstamo';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método de Impresión de Recibos en Impresoras Térmicas/PDF
  Future<void> imprimirTicket({
    required String titulo,
    required String nombreSocio,
    required String cedula,
    required String tipoOperacion,
    required double monto,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'COOP CAMPOOSTE',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Comprobante de Operación',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(
                borderStyle: pw.BorderStyle.dashed,
                thickness: 1,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Operación: $titulo',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'Socio: $nombreSocio',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Cédula: $cedula',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Tipo: $tipoOperacion',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Monto: RD\$ ${monto.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'Fecha: ${DateTime.now().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(
                borderStyle: pw.BorderStyle.dashed,
                thickness: 1,
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  '*** Transacción Exitosa ***',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Comprobante_${tipoOperacion}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}