import 'api_service.dart';

class FinancieroService {
  final String token;
  FinancieroService(this.token);

  Future<Map<String, dynamic>> resumen(int socioId) async =>
      await ApiService.get('/financiero/socios/$socioId/resumen', token: token);

  Future<Map<String, dynamic>> estadoCuenta(int socioId) async =>
      await ApiService.get('/financiero/socios/$socioId/estado-cuenta', token: token);

  Future<Map<String, dynamic>> registrarAporte({
    required int socioId,
    required double monto,
    required String tipoCuenta,
    String? descripcion,
  }) async =>
      await ApiService.post('/financiero/aportes', {
        'socioId': socioId,
        'monto': monto,
        'tipoCuenta': tipoCuenta,
        'descripcion': descripcion ?? 'Aporte',
      }, token: token);

  Future<Map<String, dynamic>> registrarDeposito({
    required int socioId,
    required double monto,
    required String tipoCuenta,
    String? descripcion,
  }) async =>
      await ApiService.post('/financiero/depositos', {
        'socioId': socioId,
        'monto': monto,
        'tipoCuenta': tipoCuenta,
        'descripcion': descripcion ?? 'Deposito',
      }, token: token);

  Future<Map<String, dynamic>> solicitarRetiro({
    required int socioId,
    required double monto,
    String? descripcion,
  }) async =>
      await ApiService.post('/financiero/retiros', {
        'socioId': socioId,
        'monto': monto,
        'descripcion': descripcion ?? 'Retiro',
      }, token: token);

  Future<List<dynamic>> retirosPendientes() async =>
      await ApiService.get('/financiero/retiros/pendientes', token: token);

  Future<Map<String, dynamic>> aprobarRetiro(int id) async =>
      await ApiService.post('/financiero/retiros/$id/aprobar', {}, token: token);

  Future<Map<String, dynamic>> rechazarRetiro(int id) async =>
      await ApiService.post('/financiero/retiros/$id/rechazar', {}, token: token);

  Future<Map<String, dynamic>> solicitarPrestamo({
    required int socioId,
    required double monto,
    required int plazoMeses,
    required double tasaInteres,
    String? observaciones,
  }) async =>
      await ApiService.post('/financiero/prestamos', {
        'socioId': socioId,
        'monto': monto,
        'plazoMeses': plazoMeses,
        'tasaInteres': tasaInteres,
        'observaciones': observaciones,
      }, token: token);

  Future<List<dynamic>> prestamosPendientes() async =>
      await ApiService.get('/financiero/prestamos/pendientes', token: token);

  Future<Map<String, dynamic>> aprobarPrestamo(int id, double montoAprobado) async =>
      await ApiService.post('/financiero/prestamos/$id/aprobar',
          {'montoAprobado': montoAprobado}, token: token);

  Future<Map<String, dynamic>> desembolsarPrestamo(int id) async =>
      await ApiService.post('/financiero/prestamos/$id/desembolsar', {}, token: token);

  Future<Map<String, dynamic>> reporteGanancias() async =>
      await ApiService.get('/financiero/reportes/ganancias-capital', token: token);

  Future<List<dynamic>> transacciones({int? socioId}) async {
    final query = socioId != null ? '?socioId=$socioId' : '';
    final res = await ApiService.get('/financiero/transacciones$query', token: token);
    return res is List ? res : [];
  }
}