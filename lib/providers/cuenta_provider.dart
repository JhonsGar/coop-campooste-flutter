import 'package:flutter/material.dart';
import '../models/cuenta.dart';
import '../models/transaccion.dart';
import '../services/cuenta_service.dart';

class CuentaProvider extends ChangeNotifier {
  final CuentaService _service = CuentaService();
  List<Cuenta> _cuentas = [];
  bool _isLoading = false;
  String? _error;

  List<Cuenta> get cuentas => _cuentas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get saldoTotal =>
      _cuentas.fold(0.0, (sum, c) => sum + c.saldo);

  Future<void> loadCuentas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cuentas = await _service.getMisCuentas();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Transaccion>> getTransacciones(int cuentaId) async {
    return await _service.getTransacciones(cuentaId);
  }

  Future<bool> depositar(int cuentaId, double monto, String? descripcion) async {
    try {
      await _service.depositar(cuentaId, monto, descripcion);
      await loadCuentas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> retirar(int cuentaId, double monto, String? descripcion) async {
    try {
      await _service.retirar(cuentaId, monto, descripcion);
      await loadCuentas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> crearCuenta(int socioId, String tipoCuenta) async {
    try {
      await _service.crearCuenta(socioId, tipoCuenta);
      await loadCuentas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}