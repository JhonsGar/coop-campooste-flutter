import 'package:flutter/material.dart';
import '../../services/compra_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class MisComprasScreen extends StatefulWidget {
  const MisComprasScreen({super.key});

  @override
  State<MisComprasScreen> createState() => _MisComprasScreenState();
}

class _MisComprasScreenState extends State<MisComprasScreen> {
  List _compras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCompras();
  }

  Future<void> _cargarCompras() async {
    setState(() => _isLoading = true);
    try {
      final compraService = CompraService();
      final data = await compraService.getMisCompras();
      setState(() {
        _compras = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar compras: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Compras'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _compras.isEmpty
          ? const Center(child: Text('Aún no has realizado compras'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _compras.length,
        itemBuilder: (context, index) {
          final compra = _compras[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Compra #${compra['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: compra['estado'] == 'pagado'
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          compra['estado'] ?? 'pendiente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Fecha: ${Formatters.formatDate(compra['fecha_compra'] ?? '')}'),
                  Text('Total: ${Formatters.formatCurrency((compra['total'] ?? 0).toDouble())}'),
                  Text('Método de pago: ${compra['metodo_pago'] ?? ''}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}