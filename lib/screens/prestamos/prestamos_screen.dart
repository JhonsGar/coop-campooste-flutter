import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones absolutas por paquete
import 'package:coop_campooste/providers/auth_provider.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final List<Map<String, dynamic>> _prestamos = [
    {'id': 101, 'socio': 'Juan Pérez', 'monto': 50000.0, 'estado': 'PENDIENTE'},
    {'id': 102, 'socio': 'María Gómez', 'monto': 120000.0, 'estado': 'APROBADO'},
    {'id': 103, 'socio': 'Carlos Ruiz', 'monto': 35000.0, 'estado': 'PENDIENTE'},
  ];

  void _aprobarPrestamo(int id) {
    setState(() {
      final p = _prestamos.firstWhere((element) => element['id'] == id);
      p['estado'] = 'APROBADO';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Préstamo #$id APROBADO.')),
    );
  }

  void _rechazarPrestamo(int id) {
    setState(() {
      final p = _prestamos.firstWhere((element) => element['id'] == id);
      p['estado'] = 'RECHAZADO';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Préstamo #$id RECHAZADO.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final esAdmin = auth.esAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('CoopCampoostes - [Rol: ${auth.rolActual}]'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (rol) => auth.cambiarRolSimulado(rol),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Cajero', child: Text('Ver como Cajero')),
              const PopupMenuItem(value: 'Administrador', child: Text('Ver como Administrador')),
            ],
            icon: const Icon(Icons.swap_horiz),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Inscribir Socio'),
                  onPressed: () => abrirDialogoInscripcionSocio(context),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.post_add),
                  label: const Text('Solicitar Préstamo'),
                  onPressed: () {
                    // Acción para solicitar préstamo
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _prestamos.length,
              itemBuilder: (context, index) {
                final item = _prestamos[index];
                final bool esPendiente = item['estado'] == 'PENDIENTE';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['estado'] == 'APROBADO'
                          ? Colors.green.shade100
                          : (item['estado'] == 'RECHAZADO'
                          ? Colors.red.shade100
                          : Colors.orange.shade100),
                      child: Icon(
                        item['estado'] == 'APROBADO'
                            ? Icons.check
                            : (item['estado'] == 'RECHAZADO'
                            ? Icons.close
                            : Icons.hourglass_empty),
                        color: item['estado'] == 'APROBADO'
                            ? Colors.green
                            : (item['estado'] == 'RECHAZADO'
                            ? Colors.red
                            : Colors.orange),
                      ),
                    ),
                    title: Text('${item['socio']}'),
                    subtitle: Text('Monto: RD\$ ${item['monto']} | Estado: ${item['estado']}'),
                    trailing: (esAdmin && esPendiente)
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          tooltip: 'Aprobar (Solo Admin)',
                          onPressed: () => _aprobarPrestamo(item['id'] as int),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                          tooltip: 'Rechazar (Solo Admin)',
                          onPressed: () => _rechazarPrestamo(item['id'] as int),
                        ),
                      ],
                    )
                        : Chip(
                      label: Text(
                        item['estado'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      backgroundColor: item['estado'] == 'APROBADO'
                          ? Colors.green
                          : (item['estado'] == 'RECHAZADO'
                          ? Colors.red
                          : Colors.orange),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on _PrestamosScreenState {
  void abrirDialogoInscripcionSocio(BuildContext context) {}
}