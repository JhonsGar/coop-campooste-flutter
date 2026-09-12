import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  List<dynamic> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthProvider>().token;
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/socios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _usuarios = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error ${response.statusCode}: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _crearUsuario(Map<String, dynamic> datos) async {
    try {
      final token = context.read<AuthProvider>().token;
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/socios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(datos),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Usuario creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _cargarUsuarios();
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${error['message'] ?? 'Error al crear'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarFormularioNuevoUsuario({String? rolPreseleccionado}) {
    final cedulaCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    String rolSeleccionado = rolPreseleccionado ?? 'Usuarios';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nuevo Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cedulaCtrl,
                  decoration: const InputDecoration(labelText: 'Cédula'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: telefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                    DropdownMenuItem(value: 'Secretario', child: Text('Secretario')),
                    DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                    DropdownMenuItem(value: 'Empleados', child: Text('Empleado')),
                    DropdownMenuItem(value: 'Usuarios', child: Text('Socio / Usuario')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setStateDialog(() => rolSeleccionado = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cedulaCtrl.text.isEmpty ||
                    nombreCtrl.text.isEmpty ||
                    emailCtrl.text.isEmpty ||
                    passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complete todos los campos obligatorios'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                _crearUsuario({
                  'cedula': cedulaCtrl.text.trim(),
                  'nombre_completo': nombreCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'telefono': telefonoCtrl.text.trim(),
                  'password': passwordCtrl.text,
                  'rol': rolSeleccionado,
                });
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Usuarios'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Socios', icon: Icon(Icons.people)),
              Tab(text: 'Empleados', icon: Icon(Icons.badge)),
              Tab(text: 'Cajeros', icon: Icon(Icons.point_of_sale)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : TabBarView(
          children: [
            _buildListaFiltrada(['Usuarios', 'Socio']),
            _buildListaFiltrada(['Empleados', 'Secretario', 'Administrador']),
            _buildListaFiltrada(['Cajero']),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarFormularioNuevoUsuario(),
          icon: const Icon(Icons.person_add),
          label: const Text('Nuevo Usuario'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListaFiltrada(List<String> roles) {
    final filtrados = _usuarios.where((u) {
      final rolesUsuario = (u['roles'] as List?)?.map((r) => r is String ? r : r['nombre']).toList() ?? [];
      return rolesUsuario.any((r) => roles.contains(r.toString()));
    }).toList();

    if (filtrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No hay usuarios en esta categoría.\n\nPulsa el botón inferior para crear uno nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarUsuarios,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtrados.length,
        itemBuilder: (context, index) {
          final u = filtrados[index];
          final rolesUsuario = (u['roles'] as List?)?.map((r) => r is String ? r : r['nombre']).join(', ') ?? 'Sin rol';
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (u['nombre_completo'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(u['nombre_completo'] ?? 'Sin nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cédula: ${u['cedula'] ?? '-'}'),
                  Text('Rol: $rolesUsuario'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Detalles del usuario
              },
            ),
          );
        },
      ),
    );
  }
}