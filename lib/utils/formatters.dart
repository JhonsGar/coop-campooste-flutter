import 'package:flutter/services.dart';

class Formatters {
  // ============================================================
  // FORMATEAR CÉDULA: 000-0000000-0
  // ============================================================
  static String cedula(String? valor) {
    if (valor == null || valor.isEmpty) return '—';
    final limpio = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.length != 11) return valor;
    return '${limpio.substring(0, 3)}-${limpio.substring(3, 10)}-${limpio.substring(10)}';
  }

  // ============================================================
  // FORMATEAR TELÉFONO: 000-000-0000
  // ============================================================
  static String telefono(String? valor) {
    if (valor == null || valor.isEmpty) return '—';
    final limpio = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.length != 10) return valor;
    return '${limpio.substring(0, 3)}-${limpio.substring(3, 6)}-${limpio.substring(6)}';
  }

  // ============================================================
  // FORMATEAR MONEDA: RD$ 1,500,000.00
  // ============================================================
  static String formatCurrency(dynamic valor) {
    final n = double.tryParse(valor.toString()) ?? 0;
    final s = n.toStringAsFixed(2);
    final partes = s.split('.');
    final entero = partes[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
    return 'RD\$ $entero.${partes[1]}';
  }

  // Alias para no romper código viejo
  static String rd(dynamic valor) => formatCurrency(valor);

  // ============================================================
  // FORMATEAR FECHA: 14/09/2026 10:30
  // Acepta String, DateTime o cualquier objeto con toString()
  // ============================================================
  static String formatDate(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(fecha.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fecha.toString();
    }
  }

  // ============================================================
  // FORMATEAR FECHA CORTA: 14/09/2026
  // ============================================================
  static String formatDateShort(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(fecha.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return fecha.toString();
    }
  }
}

// ============================================================
// INPUT FORMATTER: cédula (000-0000000-0)
// ============================================================
class CedulaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final limpio = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) return newValue.copyWith(text: '');
    if (limpio.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < limpio.length; i++) {
      if (i == 3 || i == 10) buffer.write('-');
      buffer.write(limpio[i]);
    }
    final formateado = buffer.toString();
    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}

// ============================================================
// INPUT FORMATTER: teléfono (000-000-0000)
// ============================================================
class TelefonoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final limpio = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) return newValue.copyWith(text: '');
    if (limpio.length > 10) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < limpio.length; i++) {
      if (i == 3 || i == 6) buffer.write('-');
      buffer.write(limpio[i]);
    }
    final formateado = buffer.toString();
    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}