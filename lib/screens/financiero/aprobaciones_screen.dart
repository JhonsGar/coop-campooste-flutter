import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/financiero_service.dart';

class AprobacionesScreen extends StatefulWidget {
  const AprobacionesScreen({super.key});
  @override
  State<AprobacionesScreen> createState() => _AprobacionesScreenState();
}

class _AprobacionesScreenState extends State<AprobacionesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<dynamic> _retiros = [];
  List<dynamic> _prestamos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final srv = FinancieroService(token);
      final r = await srv.retirosPendientes();
      final p = await srv.prestamosPendientes();
      setState(() {
        _retiros = r;
        _prestamos = p;
      });
    } catch (_) {}
    setState(() => _cargando = false);
  }

  Future<void> _aprobarRetiro(int id) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await FinancieroService(token).aprobarRetiro(id);
      _snack('Retiro aprobado', Colors.green);
      _cargar();
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
  }

  Future<void> _rechazarRetiro(int id) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await FinancieroService(token).rechazarRetiro(id);
      _snack('Retiro rechazado', Colors.orange);
      _cargar();
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
  }

  Future<void> _aprobarPrestamo(int id, double monto) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await FinancieroService(token).aprobarPrestamo(id, monto);
      _snack('Prestamo aprobado', Colors.green);
      _cargar();
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
  }

  Future<void> _desembolsar(int id) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await FinancieroService(token).desembolsarPrestamo(id);
      _snack('Prestamo desembolsado', Colors.green);
      _cargar();
    } catch (e) {
      _snack('Error: $e', Colors.red);
    }
  }

  void _snack(String m, Color c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobaciones Pendientes'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Retiros', icon: Icon(Icons.money_off)),
            Tab(text: 'Prestamos', icon: Icon(Icons.request_quote)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _listaRetiros(),
                _listaPrestamos(),
              ],
            ),
    );
  }

  Widget _listaRetiros() {
    if (_retiros.isEmpty) return const Center(child: Text('Sin retiros pendientes'));
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _retiros.length,
        itemBuilder: (c, i) {
          final r = _retiros[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Socio #${r['socioId']} - RD ${r['monto']}'),
              subtitle: Text(r['descripcion'] ?? 'Sin descripcion'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _aprobarRetiro(r['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rechazarRetiro(r['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listaPrestamos() {
    if (_prestamos.isEmpty) return const Center(child: Text('Sin prestamos pendientes'));
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _prestamos.length,
        itemBuilder: (c, i) {
          final p = _prestamos[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Socio #${p['socioId']} - RD ${p['montoSolicitado']}'),
              subtitle: Text('${p['plazoMeses']} meses - ${p['tasaInteres']}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _aprobarPrestamo(p['id'], (p['montoSolicitado'] as num).toDouble()),
                  ),
                  if (p['estado'] == 'Aprobado')
                    IconButton(
                      icon: const Icon(Icons.attach_money, color: Colors.blue),
                      onPressed: () => _desembolsar(p['id']),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}