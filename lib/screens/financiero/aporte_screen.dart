import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/financiero_service.dart';
import '../../services/pdf_service.dart';
import '../../utils/theme.dart';

class AporteScreen extends StatefulWidget {
  const AporteScreen({super.key});
  @override
  State<AporteScreen> createState() => _AporteScreenState();
}

class _AporteScreenState extends State<AporteScreen> {
  final _socioId = TextEditingController();
  final _monto = TextEditingController();
  final _descripcion = TextEditingController();
  String _tipoCuenta = 'retirable';
  bool _cargando = false;

  Future<void> _guardar() async {
    if (_socioId.text.isEmpty || _monto.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete socio y monto'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final srv = FinancieroService(token);
      final r = await srv.registrarAporte(
        socioId: int.parse(_socioId.text),
        monto: double.parse(_monto.text),
        tipoCuenta: _tipoCuenta,
        descripcion: _descripcion.text.isEmpty ? null : _descripcion.text,
      );
      if (!mounted) return;
      await PdfService.generarRecibo(
        titulo: 'APORTE',
        nombreSocio: 'Socio #${_socioId.text}',
        cedula: '-',
        tipoOperacion: _tipoCuenta == 'retirable' ? 'Ahorro Retirable' : 'Ahorro Inversion',
        monto: double.parse(_monto.text),
        saldoNuevo: (r['saldo'] as num?)?.toDouble(),
        descripcion: _descripcion.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aporte registrado. Saldo: ${r['saldo']}'), backgroundColor: Colors.green));
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
        title: const Text('Registrar Aporte'),
        backgroundColor: Colors.green.shade700,
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
          DropdownButtonFormField<String>(
            value: _tipoCuenta,
            decoration: const InputDecoration(labelText: 'Tipo de Cuenta', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'retirable', child: Text('Ahorro Retirable')),
              DropdownMenuItem(value: 'inversion', child: Text('Ahorro Inversion')),
            ],
            onChanged: (v) { if (v != null) setState(() => _tipoCuenta = v); },
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
            decoration: const InputDecoration(labelText: 'Descripcion (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : _guardar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              icon: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_cargando ? 'Guardando...' : 'Registrar y Generar Recibo'),
            ),
          ),
        ],
      ),
    );
  }
}