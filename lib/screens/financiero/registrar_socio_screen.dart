import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class RegistrarSocioScreen extends StatefulWidget {
  const RegistrarSocioScreen({super.key});
  @override
  State<RegistrarSocioScreen> createState() => _RegistrarSocioScreenState();
}

class _RegistrarSocioScreenState extends State<RegistrarSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedula = TextEditingController();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _password = TextEditingController();
  String _rol = 'Usuarios';
  bool _cargando = false;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.post('/socios', {
        'cedula': _cedula.text.trim(),
        'nombre_completo': _nombre.text.trim(),
        'email': _email.text.trim(),
        'telefono': _telefono.text.trim(),
        'direccion': _direccion.text.trim(),
        'password': _password.text,
        'rol': _rol,
      }, token: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Socio registrado correctamente'),
            backgroundColor: Colors.green));
      Navigator.pop(context);
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
        title: const Text('Inscribir Nuevo Socio'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _cedula,
              decoration: const InputDecoration(labelText: 'Cedula', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre completo', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefono', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccion,
              decoration: const InputDecoration(labelText: 'Direccion', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasena', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.length < 6) ? 'Minimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _rol,
              decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                DropdownMenuItem(value: 'Secretario', child: Text('Secretario')),
                DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                DropdownMenuItem(value: 'Empleados', child: Text('Empleado')),
                DropdownMenuItem(value: 'Usuarios', child: Text('Socio / Usuario')),
              ],
              onChanged: (v) { if (v != null) setState(() => _rol = v); },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: _cargando
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_cargando ? 'Guardando...' : 'Guardar Socio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}