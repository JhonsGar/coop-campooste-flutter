import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'Coop_Campooste';
  static const String appVersion = '1.0.0';

  // ============================================================
  // URL DINÁMICA DEL BACKEND
  // ============================================================
  // - Si la app corre en localhost → usa backend LOCAL
  // - Si la app corre en Render/Vercel/etc → usa backend RENDER
  // ============================================================
  static String get apiBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      // Si estamos en localhost o 127.0.0.1
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3001';
      }
    }
    // En producción (Render, Vercel, etc.)
    return 'https://coop-campooste-backend.onrender.com';
  }

  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  static const String cedulaMask = '###-#######-#';
}