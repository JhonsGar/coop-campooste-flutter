import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/socio.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Socio? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  String _rolSimulado = 'Administrador';

  // ==================== GETTERS ====================
  Socio? get currentUser => _currentUser;
  Socio? get usuario => _currentUser;
  String get usuarioNombre => _currentUser?.nombreCompleto ?? 'Usuario';
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get error => _errorMessage;
  String? get errorMessage => _errorMessage;

  // ==================== ROLES ====================
  String get rolActual {
    if (_currentUser?.rol != null && _currentUser!.rol!.isNotEmpty) {
      return _currentUser!.rol!;
    }
    return _rolSimulado;
  }

  bool get esAdmin {
    if (_currentUser != null) {
      return _currentUser!.esAdmin;
    }
    final rolNorm = _rolSimulado.toLowerCase();
    return rolNorm == 'administrador' || rolNorm == 'admin';
  }

  bool get esCajero {
    if (_currentUser != null) {
      return _currentUser!.esCajero;
    }
    final rolNorm = _rolSimulado.toLowerCase();
    return rolNorm == 'cajero' || esAdmin;
  }

  void cambiarRolSimulado(String nuevoRol) {
    _rolSimulado = nuevoRol;
    notifyListeners();
  }

  // ==================== REGISTER ====================
  Future<bool> register({
    required String cedula,
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        cedula: cedula,
        nombreCompleto: nombreCompleto,
        email: email,
        telefono: telefono,
        direccion: direccion,
        password: password,
      );
      _currentUser = response.socio;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarSocio({
    required String cedula,
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String rol,
    required String password,
  }) async {
    final nombreCompleto = '$nombre $apellido'.trim();
    return await register(
      cedula: cedula,
      nombreCompleto: nombreCompleto,
      email: email,
      telefono: telefono,
      direccion: 'Barahona, Rep. Dom.',
      password: password,
    );
  }

  // ==================== LOGIN ====================
  Future<bool> login({
    required String cedula,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        cedula: cedula,
        password: password,
      );

      _token = response.accessToken;
      _currentUser = response.socio;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(AppConstants.keyToken, _token!);
      }
      if (_currentUser != null) {
        await prefs.setString(
          AppConstants.keyUser,
          jsonEncode(_currentUser!.toJson()),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUser);
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  // ==================== LOAD TOKEN ====================
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    if (token != null && token.isNotEmpty) {
      _token = token;
      final userStr = prefs.getString(AppConstants.keyUser);
      if (userStr != null) {
        try {
          final Map<String, dynamic> userMap =
          jsonDecode(userStr) as Map<String, dynamic>;
          _currentUser = Socio.fromJson(userMap);
        } catch (e) {
          await prefs.remove(AppConstants.keyUser);
          debugPrint('Error al deserializar socio guardado: $e');
        }
      }
      notifyListeners();
    }
  }

  // ==================== UPDATE USER ====================
  void updateCurrentUser(Socio socio) async {
    _currentUser = socio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyUser,
      jsonEncode(_currentUser!.toJson()),
    );
    notifyListeners();
  }

  void setCurrentUser(Socio socio) {
    updateCurrentUser(socio);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}