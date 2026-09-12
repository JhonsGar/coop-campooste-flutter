import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/financiero_service.dart';
import '../../utils/theme.dart';

class PrestamoScreen extends StatefulWidget {
  const PrestamoScreen({super.key});
  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  final _socioId = TextEditingController();
  final _monto = TextEditingController();
  final _plazo = TextEditingController();
  final _tasa = TextEditingController(text: '10');
  final _observaciones = TextEditingController();
  bool _cargando = false;

  Future<void> _solicitar() async {
    if (_socioId.text.isEmpty || _monto.text.isEmpty || _plazo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete socio, monto y plazo'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final srv = FinancieroService(token);
      await srv.solicitarPrestamo(
        socioId: int.parse(_socioId.text),
        monto: double.parse(_monto.text),
        plazoMeses: int.parse(_plazo.text),
        tasaInteres: double.parse(_tasa.text),
        observaciones: _observaciones.text.isEmpty ? null : _observaciones.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud de prestamo enviada'), backgroundColor: Colors.green));
      _socioId.clear(); _monto.clear(); _plazo.clear(); _observaciones.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Prestamo'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _socioId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID del Socio', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _monto,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto Solicitado (RD)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plazo,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Plazo (meses)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tasa,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Tasa de Interes Anual (%)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observaciones,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : _solicitar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
              icon: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.request_quote),
              label: Text(_cargando ? 'Enviando...' : 'Solicitar Prestamo'),
            ),
          ),
        ],
      ),
    );
  }
}