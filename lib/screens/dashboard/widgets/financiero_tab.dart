import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coop_campooste/providers/auth_provider.dart';
import 'package:coop_campooste/utils/theme.dart';

class FinancieroTab extends StatelessWidget {
  const FinancieroTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Se agrega navegación segura (?.toLowerCase()) ante valores nulos
    final String rolActual = user?.rol?.toLowerCase() ?? '';
    final bool esAdmin = rolActual == 'administrador' || rolActual == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financiero'),
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opciones visibles para todos los socios
            _buildOptionCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Mis Cuentas y Libretas',
              subtitle: 'Consulta de saldos y movimientos',
              route: '/cuentas',
            ),

            const SizedBox(height: 12),

            // Opciones exclusivas para perfil Administrador
            if (esAdmin) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Gestión Operativa (Administración)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildOptionCard(
                context,
                icon: Icons.book,
                title: 'Apertura de Libreta',
                subtitle: 'Crear nueva cuenta para un socio',
                route: '/apertura-cuenta',
                arguments: {'socioId': user?.id},
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.point_of_sale,
                title: 'Operaciones de Caja (Aportes / Retiros)',
                subtitle: 'Registrar depósitos o extracciones',
                route: '/transacciones-caja',
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.monetization_on,
                title: 'Solicitud / Aprobación de Préstamos',
                subtitle: 'Gestión de créditos y cuotas',
                route: '/prestamos',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String route,
        Object? arguments,
      }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          // Reemplazado withOpacity por withValues para evitar deprecación
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, route, arguments: arguments);
        },
      ),
    );
  }
}