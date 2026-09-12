import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  // ---------------------------------------------------------------------------
  // 1. FECHAS Y HORAS
  // ---------------------------------------------------------------------------

  /// Formatea una fecha a `DD/MM/AAAA`
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha con hora: `DD/MM/AAAA 14:30`
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formatea para mostrar fechas relativas o legibles: `06 de Sep, 2026`
  static String formatDateReadable(DateTime date, {String locale = 'es'}) {
    return DateFormat("dd 'de' MMM, yyyy", locale).format(date);
  }

  // ---------------------------------------------------------------------------
  // 2. MONEDAS Y NÚMEROS
  // ---------------------------------------------------------------------------

  /// Formatea números a moneda: `$1,250.00` o `1.250,00 €` según el locale
  static String formatCurrency(
      num amount, {
        String symbol = '\$',
        String locale = 'en_US',
        int decimalDigits = 2,
      }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Formatea números grandes para ser legibles: `1500` -> `1,500`
  static String formatCompactNumber(num number) {
    return NumberFormat.compact().format(number);
  }

  // ---------------------------------------------------------------------------
  // 3. TEXTO Y CADENAS
  // ---------------------------------------------------------------------------

  /// Capitaliza la primera letra de un texto: `juan` -> `Juan`
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  /// Formatea un número de teléfono genérico (ej. 10 dígitos -> `(123) 456-7890`)
  static String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    }
    return phone;
  }

  // ---------------------------------------------------------------------------
  // 4. INPUT FORMATTERS PARA FORMULARIOS (TextFields)
  // ---------------------------------------------------------------------------

  /// Permite solo la entrada de dígitos numéricos
  static TextInputFormatter digitsOnly() {
    return FilteringTextInputFormatter.digitsOnly;
  }

  /// Convierte automáticamente todo el texto ingresado a mayúsculas
  static TextInputFormatter upperCase() {
    return _UpperCaseTextFormatter();
  }
}

/// Formateador personalizado de Input forzando Mayúsculas
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}