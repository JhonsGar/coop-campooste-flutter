import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/financiero_service.dart';
import '../../utils/theme.dart';

class RetiroScreen extends StatefulWidget {
  const RetiroScreen({super.key});
  @override
  State<RetiroScreen> createState() => _RetiroScreenState();
}

class _RetiroScreenState extends State<RetiroScreen> {
  final _socioId = TextEditingController();
  final _monto = TextEditingController();
  final _descripcion = TextEditingController();
  bool _cargando = false;

  Future<void> _solicitar() async {
    if (_socioId.text.isEmpty || _monto.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete socio y monto'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final srv = FinancieroService(token);
      await srv.solicitarRetiro(
        socioId: int.parse(_socioId.text),
        monto: double.parse(_monto.text),
        descripcion: _descripcion.text.isEmpty ? null : _descripcion.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud de retiro enviada. Espere aprobacion.'), backgroundColor: Colors.orange));
      _socioId.clear(); _monto.clear(); _descripcion.clear();
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
        title: const Text('Solicitar Retiro'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Color(0xFFFFF3E0),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('El retiro quedara pendiente hasta que el administrador lo apruebe.'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _socioId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID del Socio', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _monto,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto (RD)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            decoration: const InputDecoration(labelText: 'Motivo (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : _solicitar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
              icon: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
              label: Text(_cargando ? 'Enviando...' : 'Solicitar Retiro'),
            ),
          ),
        ],
      ),
    );
  }
}