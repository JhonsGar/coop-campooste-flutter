// lib/utils/impresion_utils.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:coop_campooste/models/carrito_item.dart';
import '../utils/formatters.dart';

class ImpresionUtils {
  /// Genera un ticket de impresión en formato de bytes (para impresoras térmicas o vista previa)
  static Future<Uint8List> generarTicket(
      List<CarritoItem> items,
      double total,
      String cliente,
      String vendedor,
      ) async {
    // Creamos un documento PDF simple que simula un ticket
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Tamaño de ticket térmico
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'TICKET DE COMPRA',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Cliente: $cliente'),
              pw.Text('Vendedor: $vendedor'),
              pw.Text('Fecha: ${DateTime.now().toString()}'),
              pw.Divider(),
              pw.Text('Productos:'),
              ...items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.producto.nombre} x${item.cantidad}'),
                    pw.Text(Formatters.formatCurrency(item.subtotal)),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    Formatters.formatCurrency(total),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('¡Gracias por su compra!'),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF más elaborado (factura) con los datos del pedido
  static Future<Uint8List> generarPDF(
      List<CarritoItem> items,
      double total,
      String cliente,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'FACTURA',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Cliente: $cliente'),
              pw.Text('Fecha: ${DateTime.now().toLocal()}'),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Precio Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.producto.nombre)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item.cantidad}', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(Formatters.formatCurrency(item.producto.precio), textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(Formatters.formatCurrency(item.subtotal), textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL: ',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    Formatters.formatCurrency(total),
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text('Documento generado electrónicamente'),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}