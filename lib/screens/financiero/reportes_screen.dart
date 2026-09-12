import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/financiero_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, dynamic>? _data;
  List<dynamic> _trans = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final srv = FinancieroService(token);
      final r = await srv.reporteGanancias();
      final t = await srv.transacciones();
      setState(() {
        _data = r;
        _trans = t;
      });
    } catch (_) {}
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ganancias y Capital'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar)],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card('Capital Total', '${_data?['capitalTotal'] ?? 0}', Icons.savings, Colors.green),
                  _card('Intereses Proyectados', '${_data?['interesesProyectados'] ?? 0}', Icons.trending_up, Colors.blue),
                  const SizedBox(height: 20),
                  const Text('Ultimas Transacciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ..._trans.take(30).map((t) => ListTile(
                        leading: Icon(_iconoTipo(t['tipo']), color: Colors.grey.shade700),
                        title: Text('${t['tipo']} - RD ${t['monto']}'),
                        subtitle: Text(t['descripcion'] ?? ''),
                        trailing: Text(t['fecha'].toString().substring(0, 10)),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _card(String titulo, String valor, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(titulo),
        trailing: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  IconData _iconoTipo(String t) {
    switch (t) {
      case 'aporte': return Icons.add_circle;
      case 'retiro': return Icons.remove_circle;
      case 'deposito': return Icons.arrow_downward;
      case 'prestamo_desembolso': return Icons.money;
      default: return Icons.swap_horiz;
    }
  }
}