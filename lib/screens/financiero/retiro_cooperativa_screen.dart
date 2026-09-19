import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/socio.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class RetiroCooperativaScreen extends StatefulWidget {
  final Socio socio;
  const RetiroCooperativaScreen({super.key, required this.socio});

  @override
  State<RetiroCooperativaScreen> createState() => _RetiroCooperativaScreenState();
}

class _RetiroCooperativaScreenState extends State<RetiroCooperativaScreen> {
  final _motivoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _procesarRetiro() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.post(
        '/socios/${widget.socio.id}/retiro-cooperativa',
        {'motivo': _motivoCtrl.text.trim()},
        token: token,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('âœ… Salida de la cooperativa procesada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('âŒ Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirar Socio de Cooperativa'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Proceso de Retiro',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'EstÃ¡ a punto de marcar a ${widget.socio.nombreCompleto} (CÃ©dula: ${widget.socio.cedula}) como socio retirado.\n\n'
                          'AsegÃºrese de haber liquidado cuentas pendientes o prÃ©stamos antes de proceder.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motivoCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Motivo de retiro',
                hintText: 'Escriba las razones de la renuncia o salida...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un motivo de retiro' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _procesarRetiro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                icon: _cargando
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.exit_to_app),
                label: Text(_cargando ? 'Procesando...' : 'Confirmar Retiro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
