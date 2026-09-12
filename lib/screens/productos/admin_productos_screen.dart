import 'package:flutter/material.dart';
import 'package:coop_campooste/utils/theme.dart';
import 'package:coop_campooste/utils/formatters.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  // Lista de prueba simulando inventario de la tienda
  final List<Map<String, dynamic>> _productos = [
    {
      'id': 1,
      'nombre': 'Abono Orgánico 50lb',
      'categoria': 'Insumos',
      'precio': 1250.00,
      'stock': 45,
    },
    {
      'id': 2,
      'nombre': 'Manguera de Riego 100m',
      'categoria': 'Herramientas',
      'precio': 3400.00,
      'stock': 12,
    },
  ];

  void _abrirFormularioProducto({Map<String, dynamic>? producto}) {
    final isEditing = producto != null;
    final nombreController =
    TextEditingController(text: isEditing ? producto['nombre'] : '');
    final precioController =
    TextEditingController(text: isEditing ? producto['precio'].toString() : '');
    final stockController =
    TextEditingController(text: isEditing ? producto['stock'].toString() : '');
    String categoria = isEditing ? producto['categoria'] : 'Insumos';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Editar Producto' : 'Nuevo Producto',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: const [
                DropdownMenuItem(value: 'Insumos', child: Text('Insumos')),
                DropdownMenuItem(value: 'Herramientas', child: Text('Herramientas')),
                DropdownMenuItem(value: 'Semillas', child: Text('Semillas')),
              ],
              onChanged: (val) {
                if (val != null) categoria = val;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: precioController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio (RD\$)',
                prefixText: 'RD\$ ',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad en Stock'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 44),
              ),
              onPressed: () {
                final nombre = nombreController.text.trim();
                final precio = double.tryParse(precioController.text) ?? 0.0;
                final stock = int.tryParse(stockController.text) ?? 0;

                if (nombre.isNotEmpty && precio > 0) {
                  setState(() {
                    if (isEditing) {
                      producto['nombre'] = nombre;
                      producto['categoria'] = categoria;
                      producto['precio'] = precio;
                      producto['stock'] = stock;
                    } else {
                      _productos.add({
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'nombre': nombre,
                        'categoria': categoria,
                        'precio': precio,
                        'stock': stock,
                      });
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                isEditing ? 'Guardar Cambios' : 'Crear Producto',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Productos'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos registrados'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final item = _productos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.store, color: AppTheme.primaryColor),
              ),
              title: Text(
                item['nombre'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item['categoria']} - Stock: ${item['stock']} uds.',
              ),
              trailing: Text(
                Formatters.formatCurrency(item['precio']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onTap: () => _abrirFormularioProducto(producto: item),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _abrirFormularioProducto(),
      ),
    );
  }
}