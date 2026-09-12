import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generarRecibo({
    required String titulo,
    required String nombreSocio,
    required String cedula,
    required String tipoOperacion,
    required double monto,
    double? saldoNuevo,
    String? descripcion,
  }) async {
    final doc = pw.Document();
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final fmt = NumberFormat.currency(locale: 'es_DO', symbol: 'RD');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('COOP_CAMPOOSTE',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Center(child: pw.Text('Comprobante de Transaccion')),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('Fecha: $fecha'),
            pw.Text('Tipo: $titulo'),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('Socio: $nombreSocio'),
            pw.Text('Cedula: $cedula'),
            pw.SizedBox(height: 8),
            pw.Text('Operacion: $tipoOperacion'),
            if (descripcion != null) pw.Text('Descripcion: $descripcion'),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MONTO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(fmt.format(monto),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            if (saldoNuevo != null) ...[
              pw.SizedBox(height: 8),
              pw.Text('Saldo nuevo: ${fmt.format(saldoNuevo)}'),
            ],
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Center(child: pw.Text('Gracias por su preferencia!')),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'recibo_$fecha.pdf',
    );
  }
}