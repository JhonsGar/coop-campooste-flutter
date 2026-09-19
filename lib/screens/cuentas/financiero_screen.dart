import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cuenta_provider.dart';
import '../../providers/aporte_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class FinancieroScreen extends StatefulWidget {
  const FinancieroScreen({super.key});

  @override
  State<FinancieroScreen> createState() => _FinancieroScreenState();
}

class _FinancieroScreenState extends State<FinancieroScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CuentaProvider>().loadCuentas();
      context.read<AporteProvider>().loadAportes();
      context.read<PrestamoProvider>().loadPrestamos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final esAdmin = ['Administrador', 'Cajero', 'Secretario']
        .contains(user?.rol ?? 'Socio');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financiero'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Cuentas'),
            Tab(icon: Icon(Icons.savings), text: 'Aportes'),
            Tab(icon: Icon(Icons.credit_card), text: 'Préstamos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CuentasTab(esAdmin: esAdmin),
          _AportesTab(esAdmin: esAdmin),
          _PrestamosTab(esAdmin: esAdmin),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 1: CUENTAS
// ============================================================
class _CuentasTab extends StatelessWidget {
  final bool esAdmin;
  const _CuentasTab({required this.esAdmin});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CuentaProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCuentas(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Saldo Total',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(provider.saldoTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (esAdmin)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear nueva cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _mostrarDialogoCrearCuenta(context, provider),
            ),
          const SizedBox(height: 16),

          if (provider.cuentas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No tienes cuentas registradas')),
            )
          else
            ...provider.cuentas.map((cuenta) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cuenta.tipoCuentaLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(cuenta.numeroCuenta,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saldo: ${Formatters.formatCurrency(cuenta.saldo)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Depositar'),
                            onPressed: () => _mostrarDialogoOperacion(
                                context, provider, cuenta.id, 'depositar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.remove, size: 16),
                            label: const Text('Retirar'),
                            onPressed: () => _mostrarDialogoOperacion(
                                context, provider, cuenta.id, 'retirar'),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('Ver transacciones'),
                      onPressed: () =>
                          _verTransacciones(context, provider, cuenta.id),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  void _mostrarDialogoCrearCuenta(BuildContext context, CuentaProvider provider) {
    String tipoSeleccionado = 'ahorro_retirable';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Crear Cuenta'),
          content: DropdownButtonFormField<String>(
            initialValue: tipoSeleccionado, // ✅ CORREGIDO
            decoration: const InputDecoration(labelText: 'Tipo de cuenta'),
            items: const [
              DropdownMenuItem(
                  value: 'ahorro_retirable', child: Text('Ahorro Retirable')),
              DropdownMenuItem(
                  value: 'ahorro_inversion', child: Text('Ahorro Inversión')),
              DropdownMenuItem(value: 'aportacion', child: Text('Aportación')),
            ],
            onChanged: (v) => setStateDialog(() => tipoSeleccionado = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final socioId = authProvider.currentUser?.id ?? 0;
                final ok = await provider.crearCuenta(socioId, tipoSeleccionado);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Cuenta creada' : 'Error al crear'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoOperacion(BuildContext context, CuentaProvider provider,
      int cuentaId, String operacion) {
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();
    final isDeposito = operacion == 'depositar';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isDeposito ? 'Depositar' : 'Retirar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
            ),
            TextField(
              controller: descripcionController,
              decoration:
              const InputDecoration(labelText: 'Descripción (opcional)'),
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

              final ok = isDeposito
                  ? await provider.depositar(
                  cuentaId, monto, descripcionController.text)
                  : await provider.retirar(
                  cuentaId, monto, descripcionController.text);

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text(ok ? 'Operación exitosa' : 'Error: ${provider.error}'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _verTransacciones(
      BuildContext context, CuentaProvider provider, int cuentaId) async {
    final transacciones = await provider.getTransacciones(cuentaId);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Transacciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: transacciones.isEmpty
                  ? const Center(child: Text('No hay transacciones'))
                  : ListView.builder(
                controller: scrollController,
                itemCount: transacciones.length,
                itemBuilder: (context, index) {
                  final t = transacciones[index];
                  return ListTile(
                    leading: Icon(
                      t.esIngreso
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: t.esIngreso ? Colors.green : Colors.red,
                    ),
                    title: Text(t.tipo.toUpperCase()),
                    subtitle: Text(t.descripcion ?? 'Sin descripción'),
                    trailing: Text(
                      '${t.esIngreso ? '+' : '-'} ${Formatters.formatCurrency(t.monto)}',
                      style: TextStyle(
                        color: t.esIngreso ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB 2: APORTES
// ============================================================
class _AportesTab extends StatelessWidget {
  final bool esAdmin;
  const _AportesTab({required this.esAdmin});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AporteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
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
                  const Text('Total Aportes',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(
                        (provider.totales['total'] ?? 0).toDouble()),
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
                      _buildTotalItem('Ahorros',
                          (provider.totales['totalAhorros'] ?? 0).toDouble()),
                      _buildTotalItem('Ingresos',
                          (provider.totales['totalIngresos'] ?? 0).toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (esAdmin)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Registrar Aporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _mostrarDialogo(
                  context, provider, authProvider.currentUser?.id ?? 0),
            ),
          const SizedBox(height: 16),
          if (provider.aportes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No hay aportes registrados')),
            )
          else
            ...provider.aportes.map((aporte) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_getIconForTipo(aporte.tipo),
                    color: AppTheme.primaryColor),
                title: Text(aporte.tipo.toUpperCase()),
                subtitle: Text(
                    '${aporte.descripcion ?? "Sin descripción"} - ${aporte.fecha}'),
                trailing: Text(
                  Formatters.formatCurrency(aporte.monto),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            )),
        ],
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

  void _mostrarDialogo(
      BuildContext context, AporteProvider provider, int socioId) {
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
                initialValue: tipoSeleccionado, // ✅ CORREGIDO
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                      value: 'aportacion', child: Text('Aportación')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                ],
                onChanged: (v) => setStateDialog(() => tipoSeleccionado = v!),
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
                final ok = await provider.crearAporte(
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
                    content:
                    Text(ok ? 'Aporte registrado' : 'Error al registrar'),
                    backgroundColor: ok ? Colors.green : Colors.red,
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

// ============================================================
// TAB 3: PRÉSTAMOS
// ============================================================
class _PrestamosTab extends StatelessWidget {
  final bool esAdmin;
  const _PrestamosTab({required this.esAdmin});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrestamoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPrestamos(),
      child: Column(
        children: [
          if (esAdmin)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Solicitar Préstamo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
                onPressed: () => _mostrarDialogoSolicitar(
                    context, provider, authProvider.currentUser?.id ?? 0),
              ),
            ),
          Expanded(
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
                    subtitle: Text('${p.tipoPrestamo} - ${p.estado}'),
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
                      _buildInfoRow('Tasa interés', '${p.tasaInteres}%'),
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
                          child: Text('Calendario de Cuotas',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
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
                          subtitle: Text(
                              'Vence: ${cuota.fechaVencimiento}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(Formatters.formatCurrency(
                                  cuota.montoTotal)),
                              if (!cuota.estaPagada)
                                IconButton(
                                  icon: const Icon(Icons.payment,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    final ok = await provider
                                        .pagarCuota(cuota.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? 'Cuota pagada'
                                            : 'Error al pagar'),
                                        backgroundColor: ok
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    );
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
        ],
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
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
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

  void _mostrarDialogoSolicitar(
      BuildContext context, PrestamoProvider provider, int socioId) {
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
                  initialValue: tipoSeleccionado, // ✅ CORREGIDO
                  decoration:
                  const InputDecoration(labelText: 'Tipo de préstamo'),
                  items: const [
                    DropdownMenuItem(
                        value: 'personal', child: Text('Personal')),
                    DropdownMenuItem(
                        value: 'electrodomesticos',
                        child: Text('Electrodomésticos')),
                    DropdownMenuItem(value: 'escolar', child: Text('Escolar')),
                    DropdownMenuItem(value: 'vivienda', child: Text('Vivienda')),
                  ],
                  onChanged: (v) {
                    setStateDialog(() {
                      tipoSeleccionado = v!;
                      tasaInteres = v == 'personal'
                          ? 12.0
                          : v == 'electrodomesticos'
                          ? 8.0
                          : 10.0;
                    });
                  },
                ),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
                  onChanged: (v) {
                    final monto = double.tryParse(v) ?? 0;
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
                  onChanged: (v) {
                    final monto = double.tryParse(montoController.text) ?? 0;
                    final plazo = int.tryParse(v) ?? 12;
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
                      Text('Tasa: $tasaInteres%'),
                      const SizedBox(height: 4),
                      Text(
                        'Cuota mensual: ${Formatters.formatCurrency(cuotaEstimada)}',
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
                final ok = await provider.solicitarPrestamo(
                  socioId: socioId,
                  monto: monto,
                  tasaInteres: tasaInteres,
                  plazoMeses: plazo,
                  tipoPrestamo: tipoSeleccionado,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Préstamo solicitado. Espera aprobación.'
                        : 'Error al solicitar'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Solicitar'),
            ),
          ],
        ),
      ),
    );
  }
}