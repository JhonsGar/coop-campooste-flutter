import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tienda/checkout_screen.dart';
import 'screens/admin/admin_productos_screen.dart';
import 'screens/admin/gestion_usuarios_screen.dart';  // ✅ NUEVO
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Coop_Campooste',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/admin-productos': (context) => const AdminProductosScreen(),
          '/admin-usuarios': (context) => const GestionUsuariosScreen(),  // ✅ NUEVO
        },
        onGenerateRoute: (settings) {
          return null;
        },
      ),
    );
  }
}