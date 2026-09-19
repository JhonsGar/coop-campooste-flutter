import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/socio.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class EditarSocioScreen extends StatefulWidget {
  final Socio socio;
  const EditarSocioScreen({super.key, required this.socio});

  @override
  State<EditarSocioScreen> createState() => _EditarSocioScreenState();
}

class _EditarSocioScreenState extends State<EditarSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cedula;
  late TextEditingController _nombre;
  late TextEditingController _email;
  late TextEditingController _telefono;
  late TextEditingController _direccion;
  late String _rol;
  late String _estado;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cedula = TextEditingController(text: widget.socio.cedula);
    _nombre = TextEditingController(text: widget.socio.nombreCompleto);
    _email = TextEditingController(text: widget.socio.email);
    _telefono = TextEditingController(text: widget.socio.telefono ?? '');
    _direccion = TextEditingController(text: widget.socio.direccion ?? '');
    _rol = widget.socio.rol ?? 'Usuarios';
    _estado = widget.socio.estado ?? 'activo';
  }

  @override
  void dispose() {
    _cedula.dispose();
    _nombre.dispose();
    _email.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final token = context.read<AuthProvider>().token;
      await ApiService.patch('/socios/${widget.socio.id}', {
        'cedula': _cedula.text.trim(),
        'nombre_completo': _nombre.text.trim(),
        'email': _email.text.trim(),
        'telefono': _telefono.text.trim(),
        'direccion': _direccion.text.trim(),
        'rol': _rol,
        'estado': _estado,
      }, token: token);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Socio actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString().replaceFirst('Exception: ', '')}'),
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
        title: const Text('Editar Socio'),
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
              decoration: const InputDecoration(labelText: 'Cédula', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccion,
              decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _rol,
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'activo', child: Text('Activo')),
                DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                DropdownMenuItem(value: 'retirado', child: Text('Retirado')),
              ],
              onChanged: (v) { if (v != null) setState(() => _estado = v); },
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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_cargando ? 'Guardando...' : 'Actualizar Datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}