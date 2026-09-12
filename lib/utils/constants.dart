import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'Coop_Campooste';
  static const String appVersion = '1.0.0';

  // IP de la PC donde corre el backend (para Android fisico)
  static const String _pcIp = '192.168.1.3';
  static const int _backendPort = 3001;

  // Detecta la plataforma automaticamente
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_backendPort';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://$_pcIp:$_backendPort';
      }
      if (Platform.isWindows) {
        return 'http://localhost:$_backendPort';
      }
      if (Platform.isMacOS) {
        return 'http://localhost:$_backendPort';
      }
      if (Platform.isLinux) {
        return 'http://localhost:$_backendPort';
      }
      if (Platform.isIOS) {
        return 'http://$_pcIp:$_backendPort';
      }
    } catch (_) {}
    return 'http://localhost:$_backendPort';
  }

  // Alias para compatibilidad
  static String get baseUrl => apiBaseUrl;

  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  static const String cedulaMask = '###-#######-#';
}