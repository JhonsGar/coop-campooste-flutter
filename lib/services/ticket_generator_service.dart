import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class TicketGeneratorService {
  /// Genera los bytes ESC/POS para un recibo de caja de la cooperativa.
  static Future<List<int>> generarTicketDepositoRetiro({
    required String titulo, // Ej: "COMPROBANTE DE DEPÓSITO" o "COMPROBANTE DE RETIRO"
    required String nombreSocio,
    required String cedula,
    required String tipoOperacion,
    required double monto,
    required double nuevoSaldo,
    String? concepto,
  }) async {
    // Cargar perfil estándar de la impresora
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Resetear configuración de la impresora
    bytes += generator.reset();

    // ENCABEZADO
    bytes += generator.text(
      'COOP CAMPOOSTE',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Cooperativa Agropecuaria y de Servicios Multiples',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      titulo,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.feed(1);

    // SEPARADOR
    bytes += generator.hr();

    // DATOS DE LA TRANSACCIÓN
    final fecha = DateTime.now();
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    bytes += generator.text('Fecha: $fechaFormateada');
    bytes += generator.text('Socio: $nombreSocio');
    bytes += generator.text('Cedula: $cedula');
    bytes += generator.text('Operacion: $tipoOperacion');
    if (concepto != null && concepto.isNotEmpty) {
      bytes += generator.text('Concepto: $concepto');
    }

    bytes += generator.hr();

    // MONTOS Y BALANCES
    bytes += generator.row([
      PosColumn(
        text: 'MONTO OPERACION:',
        width: 7,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'RD\$ ${monto.toStringAsFixed(2)}',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'NUEVO BALANCE:',
        width: 7,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'RD\$ ${nuevoSaldo.toStringAsFixed(2)}',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();
    bytes += generator.feed(1);

    // PIE DE PÁGINA
    bytes += generator.text(
      '*** GRACIAS POR CONFIAR EN NOSOTROS ***',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);

    // COMANDO DE CORTE DE PAPEL
    bytes += generator.cut();

    return bytes;
  }
}