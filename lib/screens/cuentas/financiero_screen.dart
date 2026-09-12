import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../financiero/registrar_socio_screen.dart';
import '../financiero/aporte_screen.dart';
import '../financiero/retiro_screen.dart';
import '../financiero/prestamo_screen.dart';
import '../financiero/aprobaciones_screen.dart';
import '../financiero/reportes_screen.dart';

class FinancieroScreen extends StatelessWidget {
  const FinancieroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final rol = user?.rol ?? '';
    final esAdmin = rol == 'Administrador';
    final esCajero = rol == 'Cajero' || esAdmin;
    final esSecretario = rol == 'Secretario' || esAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financiero'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ============ OPERACIONES DE CAJA ============
          if (esCajero) ...[
            _sectionTitle('Operaciones de Caja'),
            _card(context, Icons.person_add, 'Inscribir Nuevo Socio',
                'Registrar un socio en el sistema', Colors.blue,
                    () => _go(context, const RegistrarSocioScreen())),
            _card(context, Icons.savings, 'Registrar Aporte / Depósito',
                'Aumentar el saldo de un socio', Colors.green,
                    () => _go(context, const AporteScreen())),
            _card(context, Icons.money_off, 'Solicitar Retiro',
                'Requiere aprobación del administrador', Colors.orange,
                    () => _go(context, const RetiroScreen())),
          ],

          // ============ PRÉSTAMOS ============
          if (esSecretario) ...[
            _sectionTitle('Préstamos'),
            _card(context, Icons.request_quote, 'Solicitar Préstamo',
                'Crear una nueva solicitud', Colors.purple,
                    () => _go(context, const PrestamoScreen())),
          ],

          // ============ SOLO ADMIN ============
          if (esAdmin) ...[
            _sectionTitle('Administración'),
            _card(context, Icons.approval, 'Aprobaciones Pendientes',
                'Retiros y préstamos por aprobar', Colors.red,
                    () => _go(context, const AprobacionesScreen())),
            _card(context, Icons.analytics, 'Reporte de Ganancias y Capital',
                'Ver resumen financiero de la cooperativa', Colors.teal,
                    () => _go(context, const ReportesScreen())),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );

  Widget _card(BuildContext ctx, IconData icon, String title, String sub,
      Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _go(BuildContext ctx, Widget screen) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen));
  }
}