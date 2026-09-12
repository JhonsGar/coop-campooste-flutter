import 'package:flutter/material.dart';

// Importaciones absolutas desde la raíz del paquete
import 'package:coop_campooste/screens/auth/login_screen.dart';
import 'package:coop_campooste/screens/dashboard/dashboard_screen.dart';
import 'package:coop_campooste/screens/socios/registro_socio_screen.dart';
import 'package:coop_campooste/screens/cuentas/apertura_cuenta_screen.dart';
import 'package:coop_campooste/screens/productos/admin_productos_screen.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/login': (BuildContext context) => const LoginScreen(),
    '/dashboard': (BuildContext context) => const DashboardScreen(),
    '/registro-socio': (BuildContext context) => const RegistroSocioScreen(),
    '/admin-productos': (BuildContext context) => const AdminProductosScreen(),
    '/apertura-cuenta': (BuildContext context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return AperturaCuentaScreen(socioId: args['socioId']);
    },
  };
}