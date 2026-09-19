import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/socio.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'editar_socio_screen.dart';
import 'retiro_cooperativa_screen.dart';

class SocioDetalleScreen extends StatefulWidget {
  final Socio socio;
  const SocioDetalleScreen({super.key, required this.socio});

  @override
  State<SocioDetalleScreen> createState() => _SocioDetalleScreenState();
}

class _SocioDetalleScreenState extends State<SocioDetalleScreen> {
  @override
  Widget build(BuildContext context) {
    final socio = widget.socio;
    return Scaffold(
      appBar: AppBar(
        title: Text(socio.nombreCompleto),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (opcion) => _accionMenu(opcion),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Editar socio'),
                  ],
                ),
              ),
              if (socio.estado != 'retirado')
                const PopupMenuItem(
                  value: 'retirar',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Retirar de cooperativa',
                          style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                ),
              if (socio.estado == 'retirado')
                const PopupMenuItem(
                  value: 'reactivar',
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Reactivar socio',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardDatosPersonales(socio),
          const SizedBox(height: 16),
          _info("Para ver cuentas, préstamos y transacciones, ve al módulo Financiero."),
        ],
      ),
    );
  }

  Future<void> _accionMenu(String opcion) async {
    switch (opcion) {
      case 'editar':
        final actualizado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditarSocioScreen(socio: widget.socio),
          ),
        );
        if (actualizado == true && mounted) {
          Navigator.pop(context, true);
        }
        break;

      case 'retirar':
        final retirado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RetiroCooperativaScreen(socio: widget.socio),
          ),
        );
        if (retirado == true && mounted) {
          Navigator.pop(context, true);
        }
        break;

      case 'reactivar':
        await _confirmarReactivar();
        break;
    }
  }

  Future<void> _confirmarReactivar() async {
    final token = context.read<AuthProvider>().token;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reactivar socio'),
        content: Text(
          '¿Reactivar a ${widget.socio.nombreCompleto}? '
          'Volverá a estar activo en el sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ApiService.post(
        '/socios/${widget.socio.id}/reactivar',
        {},
        token: token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Socio reactivado'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _cardDatosPersonales(Socio s) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Datos personales',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _filaInfo('Cédula', Formatters.cedula(s.cedula)),
            _filaInfo('Email', s.email),
            _filaInfo('Teléfono', Formatters.telefono(s.telefono)),
            _filaInfo('Dirección', s.direccion ?? '-'),
            _filaInfo('Rol', s.rol ?? '-'),
            _filaInfo('Estado', s.estado ?? 'activo'),
          ],
        ),
      ),
    );
  }

  Widget _info(String texto) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text(texto)),
          ],
        ),
      ),
    );
  }

  Widget _filaInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
