import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/producto_provider.dart';
import '../../utils/theme.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  final Map<int, TextEditingController> _precioControllers = {};
  final Map<int, TextEditingController> _stockControllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductoProvider>().loadProductos();
      }
    });
  }

  void _syncControllers(List productos) {
    for (var producto in productos) {
      if (!_precioControllers.containsKey(producto.id)) {
        // Se removió 'const' porque el texto se genera dinámicamente
        _precioControllers[producto.id] = TextEditingController(
          text: producto.precio.toString(),
        );
        _stockControllers[producto.id] = TextEditingController(
          text: producto.stock.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductoProvider>(context);

    // Sincronización de controladores antes de renderizar
    _syncControllers(provider.productos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _guardarCambios,
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.productos.isEmpty
          ? const Center(child: Text('No hay productos'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.productos.length,
        itemBuilder: (context, index) {
          final producto = provider.productos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForCategory(producto.categoria),
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          producto.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _precioControllers[producto.id],
                          decoration: const InputDecoration(
                            // Se escapó el caracter '$' (RD\$)
                            labelText: 'Precio (RD\$)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _stockControllers[producto.id],
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (!mounted) return;

    setState(() => _isSaving = true);
    final provider = context.read<ProductoProvider>();
    int errores = 0;

    for (var producto in provider.productos) {
      final precioCtrl = _precioControllers[producto.id];
      final stockCtrl = _stockControllers[producto.id];

      if (precioCtrl != null && stockCtrl != null) {
        try {
          final nuevoPrecio = double.parse(precioCtrl.text.trim());
          final nuevoStock = int.parse(stockCtrl.text.trim());

          if (nuevoPrecio != producto.precio || nuevoStock != producto.stock) {
            await provider.actualizarProducto(
              producto.id,
              nuevoPrecio,
              nuevoStock: nuevoStock,
            );
            if (!mounted) return;
          }
        } catch (e) {
          errores++;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error en "${producto.nombre}": $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errores == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los productos actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      await provider.loadProductos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errores producto(s) con error. Revisa los datos.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  IconData _getIconForCategory(String categoria) {
    switch (categoria) {
      case 'electrodomesticos':
        return Icons.kitchen;
      case 'utiles_escolares':
        return Icons.school;
      case 'tecnologia':
        return Icons.computer;
      case 'hogar':
        return Icons.home;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  void dispose() {
    for (var controller in _precioControllers.values) {
      controller.dispose();
    }
    for (var controller in _stockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}