class Formatters {
  static String formatCurrency(double amount) {
    return 'RD\$ ${amount.toStringAsFixed(2)}';
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}