import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrestamoProvider>().loadPrestamos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrestamoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Préstamos'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoSolicitar(authProvider, provider),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => provider.loadPrestamos(),
        child: provider.prestamos.isEmpty
            ? const Center(child: Text('No tienes préstamos'))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.prestamos.length,
          itemBuilder: (context, index) {
            final p = provider.prestamos[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(
                  _getIconForEstado(p.estado),
                  color: _getColorForEstado(p.estado),
                ),
                title: Text(
                  'Préstamo #${p.numeroPrestamo ?? p.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${p.tipoPrestamo} - ${p.estado}',
                ),
                trailing: Text(
                  Formatters.formatCurrency(p.montoSolicitado),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  _buildInfoRow('Monto solicitado',
                      Formatters.formatCurrency(p.montoSolicitado)),
                  if (p.montoAprobado != null)
                    _buildInfoRow('Monto aprobado',
                        Formatters.formatCurrency(p.montoAprobado!)),
                  _buildInfoRow('Tasa de interés', '${p.tasaInteres}%'),
                  _buildInfoRow('Plazo', '${p.plazoMeses} meses'),
                  if (p.cuotaMensual != null)
                    _buildInfoRow('Cuota mensual',
                        Formatters.formatCurrency(p.cuotaMensual!)),
                  if (p.saldoPendiente != null)
                    _buildInfoRow('Saldo pendiente',
                        Formatters.formatCurrency(p.saldoPendiente!),
                        color: Colors.red),
                  if (p.cuotas.isNotEmpty) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Calendario de Cuotas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...p.cuotas.map((cuota) => ListTile(
                      dense: true,
                      leading: Icon(
                        cuota.estaPagada
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: cuota.estaPagada
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text('Cuota #${cuota.numeroCuota}'),
                      subtitle: Text('Vence: ${cuota.fechaVencimiento}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Formatters.formatCurrency(cuota.montoTotal)),
                          if (!cuota.estaPagada)
                            IconButton(
                              icon: const Icon(Icons.payment,
                                  color: Colors.blue),
                              onPressed: () async {
                                final success =
                                await provider.pagarCuota(cuota.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Cuota pagada'
                                          : 'Error al pagar'),
                                      backgroundColor: success
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  IconData _getIconForEstado(String estado) {
    switch (estado) {
      case 'solicitado':
        return Icons.hourglass_empty;
      case 'aprobado':
        return Icons.check_circle_outline;
      case 'desembolsado':
        return Icons.account_balance_wallet;
      case 'pagado':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'solicitado':
        return Colors.orange;
      case 'aprobado':
        return Colors.blue;
      case 'desembolsado':
        return Colors.green;
      case 'pagado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _mostrarDialogoSolicitar(AuthProvider authProvider, PrestamoProvider provider) {
    final montoController = TextEditingController();
    final plazoController = TextEditingController(text: '12');
    String tipoSeleccionado = 'personal';
    double tasaInteres = 12.0;
    double cuotaEstimada = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Solicitar Préstamo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de préstamo'),
                  items: const [
                    DropdownMenuItem(value: 'personal', child: Text('Personal')),
                    DropdownMenuItem(
                        value: 'electrodomesticos', child: Text('Electrodomésticos')),
                    DropdownMenuItem(value: 'escolar', child: Text('Escolar')),
                    DropdownMenuItem(value: 'vivienda', child: Text('Vivienda')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      tipoSeleccionado = value!;
                      tasaInteres = value == 'personal'
                          ? 12.0
                          : value == 'electrodomesticos'
                          ? 8.0
                          : 10.0;
                    });
                  },
                ),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
                  onChanged: (value) {
                    final monto = double.tryParse(value) ?? 0;
                    final plazo = int.tryParse(plazoController.text) ?? 12;
                    setStateDialog(() {
                      cuotaEstimada =
                          provider.calcularCuotaMensual(monto, tasaInteres, plazo);
                    });
                  },
                ),
                TextField(
                  controller: plazoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Plazo (meses)'),
                  onChanged: (value) {
                    final monto = double.tryParse(montoController.text) ?? 0;
                    final plazo = int.tryParse(value) ?? 12;
                    setStateDialog(() {
                      cuotaEstimada =
                          provider.calcularCuotaMensual(monto, tasaInteres, plazo);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Tasa de interés: $tasaInteres%'),
                      const SizedBox(height: 4),
                      Text(
                        'Cuota mensual estimada: ${Formatters.formatCurrency(cuotaEstimada)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final monto = double.tryParse(montoController.text) ?? 0;
                final plazo = int.tryParse(plazoController.text) ?? 0;
                if (monto <= 0 || plazo <= 0) return;

                final socioId = authProvider.currentUser?.id ?? 0;
                final success = await provider.solicitarPrestamo(
                  socioId: socioId,
                  monto: monto,
                  tasaInteres: tasaInteres,
                  plazoMeses: plazo,
                  tipoPrestamo: tipoSeleccionado,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Préstamo solicitado. Espera aprobación.'
                          : 'Error al solicitar préstamo'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Solicitar'),
            ),
          ],
        ),
      ),
    );
  }
}