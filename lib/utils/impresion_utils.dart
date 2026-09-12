// lib/utils/impresion_utils.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'dart:typed_data';
import '../models/carrito_item.dart';

class ImpresionUtils {
  static Future<Uint8List> generarTicket(
      List<CarritoItem> items,
      double total,
      String cliente,
      String vendedor,
      ) async {
    // ✅ CORRECCIÓN FINAL: usar load() en lugar del constructor antiguo
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text('COOP CAMPOOSTE',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text('Tel: 555-1234', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Fecha: ${DateTime.now().toLocal()}',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Cliente: $cliente', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Vendedor: $vendedor', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

    bytes += generator.row([
      PosColumn(text: 'Cant', width: 1, styles: const PosStyles(align: PosAlign.center)),
      PosColumn(text: 'Producto', width: 5),
      PosColumn(text: 'Precio', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);

    for (var item in items) {
      bytes += generator.row([
        PosColumn(text: '${item.cantidad}', width: 1, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: item.producto.nombre, width: 5),
        PosColumn(
          text: '\$${item.subtotal.toStringAsFixed(2)}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true, align: PosAlign.right)),
      PosColumn(
        text: '\$${total.toStringAsFixed(2)}',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.text('¡Gracias por su compra!', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }

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
                child: pw.Text('COOP CAMPOOSTE',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Fecha: ${DateTime.now().toLocal()}'),
              pw.Text('Cliente: $cliente'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Precio', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.producto.nombre)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item.cantidad}')),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${item.subtotal.toStringAsFixed(2)}'),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}