import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketService {
  static Future<void> imprimirReciboOperacion({
    required String tipoOperacion,
    required String socioNombre,
    required double monto,
    required String atendidopor,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Rollo Térmico Estándar 80mm
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // Sintaxis correcta
              children: [
                pw.Center(
                  child: pw.Text(
                    'COOPERATIVA CAMPOOSTE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Comprobante de Caja',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.SizedBox(height: 6),

                // Separador de línea limpia para ticket térmico
                pw.Divider(thickness: 0.5),

                pw.Text(
                  'Concepto: $tipoOperacion',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Socio: $socioNombre',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Monto: RD\$ ${monto.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Atendido por: $atendidopor',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Fecha: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(fontSize: 8),
                ),

                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),

                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su pago!',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}