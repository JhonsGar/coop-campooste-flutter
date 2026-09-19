import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aporte_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class AportesScreen extends StatefulWidget {
  const AportesScreen({super.key});

  @override
  State<AportesScreen> createState() => _AportesScreenState();
}

class _AportesScreenState extends State<AportesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AporteProvider>().loadAportes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AporteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Aportes'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            // ✅ Ahora pasamos provider y authProvider
            onPressed: () =>
                _mostrarDialogoNuevoAporte(context, provider, authProvider),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => provider.loadAportes(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Resumen Total',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCurrency(
                        (provider.totales['total'] ?? 0).toDouble(),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTotalItem(
                            'Aportaciones',
                            (provider.totales['totalAportaciones'] ?? 0)
                                .toDouble()),
                        _buildTotalItem(
                            'Ahorros',
                            (provider.totales['totalAhorros'] ?? 0)
                                .toDouble()),
                        _buildTotalItem(
                            'Ingresos',
                            (provider.totales['totalIngresos'] ?? 0)
                                .toDouble()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Historial de Aportes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.aportes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay aportes registrados'),
                ),
              )
            else
              ...provider.aportes.map((aporte) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getIconForTipo(aporte.tipo),
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(aporte.tipo.toUpperCase()),
                  subtitle: Text(
                    '${aporte.descripcion ?? "Sin descripción"} - ${aporte.fecha}',
                  ),
                  trailing: Text(
                    Formatters.formatCurrency(aporte.monto),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(String label, double value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(value),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'aportacion':
        return Icons.savings;
      case 'ahorro':
        return Icons.account_balance_wallet;
      case 'ingreso':
        return Icons.attach_money;
      default:
        return Icons.monetization_on;
    }
  }

  // ✅ AHORA recibe el provider como parámetro
  void _mostrarDialogoNuevoAporte(
      BuildContext context,
      AporteProvider provider,
      AuthProvider authProvider,
      ) {
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();
    String tipoSeleccionado = 'aportacion';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nuevo Aporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                      value: 'aportacion', child: Text('Aportación')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) =>
                    setStateDialog(() => tipoSeleccionado = value!),
              ),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final monto = double.tryParse(montoController.text) ?? 0;
                if (monto <= 0) return;

                final socioId = authProvider.currentUser?.id ?? 0;
                // ✅ Usamos el provider que recibimos como parámetro
                final success = await provider.crearAporte(
                  socioId: socioId,
                  monto: monto,
                  tipo: tipoSeleccionado,
                  descripcion: descripcionController.text,
                );

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Aporte registrado' : 'Error al registrar'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}