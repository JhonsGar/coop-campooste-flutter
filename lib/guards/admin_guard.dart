import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Si el usuario NO es admin, redirigimos o mostramos mensaje de error
    if (!authProvider.esAdmin) {
      // Usamos WidgetsBinding para diferir la redirección hasta después de la fase de renderizado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          // Opción 1: Redirigir a una pantalla previa o al home/dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');

          // Opcional: Mostrar un SnackBar avisando del problema
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acceso denegado: Se requieren permisos de administrador.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      // Mientras se procesa la redirección, mostramos un indicador de carga o pantalla vacía
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si es admin, renderiza la pantalla destino
    return child;
  }
}