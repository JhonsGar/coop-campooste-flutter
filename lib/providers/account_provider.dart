import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../models/account.dart';
import '../models/movement.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  List<Account> _accounts = [];
  final Map<int, List<Movement>> _movementsByAccount = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtiene los movimientos de una cuenta específica guardados en memoria
  List<Movement> getMovementsForAccount(int accountId) {
    return _movementsByAccount[accountId] ?? [];
  }

  /// Carga todas las cuentas vinculadas a un socio específico desde NestJS
  Future<void> loadAccountsBySocio(int socioId) async {
    _setLoading(true);
    _clearError();

    try {
      _accounts = await _accountService.getAccountsBySocio(socioId);
    } catch (e) {
      _error = 'Error al cargar las cuentas: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _setLoading(false);
    }
  }

  /// Carga los movimientos asociados a una cuenta en específico
  Future<void> loadMovements(int accountId) async {
    _setLoading(true);
    _clearError();

    try {
      final movements = await _accountService.getMovements(accountId);
      _movementsByAccount[accountId] = movements;
    } catch (e) {
      _error = 'Error al cargar movimientos: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _setLoading(false);
    }
  }

  /// Crear una nueva libreta / cuenta de ahorro para un socio
  Future<bool> crearCuenta({
    required int socioId,
    required String tipoCuenta,
    required double saldoInicial,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final exito = await _accountService.crearCuenta(
        socioId: socioId,
        tipoCuenta: tipoCuenta,
        saldoInicial: saldoInicial,
      );

      if (exito) {
        await loadAccountsBySocio(socioId);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al crear la cuenta: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registrar un nuevo Aporte o Retiro (Transacción de Caja)
  Future<bool> registrarTransaccion({
    required int accountId,
    required int socioId,
    required double monto,
    required String tipo, // 'APORTE' o 'RETIRO'
    String concepto = 'Operación por caja',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final exito = await _accountService.registrarTransaccion(
        accountId: accountId,
        monto: monto,
        tipo: tipo,
        concepto: concepto,
      );

      if (exito) {
        // Recargar la lista de cuentas y los movimientos de la cuenta afectada
        await loadAccountsBySocio(socioId);
        await loadMovements(accountId);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error en la transacción: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Busca una cuenta por su ID de forma segura
  Account? getAccountById(int id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  /// Balance total de aportes/ahorros combinados
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.saldo);
  }

  // --- Helpers Privados ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}