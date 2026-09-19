import 'package:flutter/material.dart';
import '../models/aporte.dart';
import '../services/aporte_service.dart';

class AporteProvider extends ChangeNotifier {
  final AporteService _service = AporteService();
  List<Aporte> _aportes = [];
  Map<String, dynamic> _totales = {};
  bool _isLoading = false;

  List<Aporte> get aportes => _aportes;
  Map<String, dynamic> get totales => _totales;
  bool get isLoading => _isLoading;

  Future<void> loadAportes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _aportes = await _service.getMisAportes();
      _totales = await _service.getMisTotales();
    } catch (e) {
      debugPrint('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearAporte({
    required int socioId,
    required double monto,
    required String tipo,
    String? descripcion,
  }) async {
    try {
      await _service.crearAporte(
        socioId: socioId,
        monto: monto,
        tipo: tipo,
        descripcion: descripcion,
      );
      await loadAportes();
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}