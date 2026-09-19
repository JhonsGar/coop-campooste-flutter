import 'package:flutter/material.dart';
import '../models/prestamo.dart';
import '../services/prestamo_service.dart';

class PrestamoProvider extends ChangeNotifier {
  final PrestamoService _service = PrestamoService();
  List<Prestamo> _prestamos = [];
  bool _isLoading = false;

  List<Prestamo> get prestamos => _prestamos;
  bool get isLoading => _isLoading;

  Future<void> loadPrestamos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prestamos = await _service.getMisPrestamos();
    } catch (e) {
      debugPrint('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> solicitarPrestamo({
    required int socioId,
    required double monto,
    required double tasaInteres,
    required int plazoMeses,
    required String tipoPrestamo,
  }) async {
    try {
      await _service.solicitarPrestamo(
        socioId: socioId,
        monto: monto,
        tasaInteres: tasaInteres,
        plazoMeses: plazoMeses,
        tipoPrestamo: tipoPrestamo,
      );
      await loadPrestamos();
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> pagarCuota(int cuotaId) async {
    try {
      await _service.pagarCuota(cuotaId);
      await loadPrestamos();
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  double calcularCuotaMensual(double monto, double tasaAnual, int plazoMeses) {
    final tasaMensual = tasaAnual / 100 / 12;
    if (tasaMensual == 0) return monto / plazoMeses;
    return (monto * tasaMensual) / (1 - (1 / (1 + tasaMensual)) * plazoMeses);
  }
}