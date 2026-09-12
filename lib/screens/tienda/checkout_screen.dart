// lib/screens/tienda/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/carrito_item.dart';
import '../../services/compra_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../utils/impresion_utils.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodoPago = 'cuenta_ahorro';
  bool _isLoading = false;

  final List<Map<String, String>> _metodosPago = [
    {'value': 'cuenta_ahorro', 'label': 'Cuenta de Ahorro'},
    {'value': 'prestamo', 'label': 'Préstamo'},
  ];

  Future<void> _imprimirTicket() async {
    final cart = context.read<CarritoProvider>();
    final auth = context.read<AuthProvider>();
    try {
      final bytes = await ImpresionUtils.generarTicket(
        cart.items,
        cart.total,
        auth.usuario?.nombreCompleto ?? 'Cliente',
        auth.usuario?.nombreCompleto ?? 'Vendedor',
      );
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al imprimir: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarPDF() async {
    final cart = context.read<CarritoProvider>();
    final auth = context.read<AuthProvider>();
    try {
      final bytes = await ImpresionUtils.generarPDF(
        cart.items,
        cart.total,
        auth.usuario?.nombreCompleto ?? 'Cliente',
      );
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _realizarCompra() async {
    final cartProvider = context.read<CarritoProvider>();

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = cartProvider.items.map((item) {
        return {
          'productoId': item.producto.id,
          'cantidad': item.cantidad,
        };
      }).toList();

      final compraService = CompraService();
      await compraService.realizarCompra(
        items: items,
        metodoPago: _metodoPago,
      );

      if (!mounted) return;

      cartProvider.limpiarCarrito();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra realizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Compra'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final CarritoItem item = cartProvider.items[index];
                  return ListTile(
                    title: Text(item.producto.nombre),
                    subtitle: Text('Cantidad: ${item.cantidad}'),
                    trailing: Text(Formatters.formatCurrency(item.subtotal)),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.formatCurrency(cartProvider.total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // ✅ Uso correcto de RadioGroup para Flutter v3.32+
            RadioGroup<String>(
              groupValue: _metodoPago,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _metodoPago = value;
                  });
                }
              },
              child: Column(
                children: _metodosPago.map((metodo) {
                  return RadioListTile<String>(
                    title: Text(metodo['label']!),
                    value: metodo['value']!,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _imprimirTicket,
                    icon: const Icon(Icons.print),
                    label: const Text('Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generarPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _realizarCompra,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Confirmar Compra'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}