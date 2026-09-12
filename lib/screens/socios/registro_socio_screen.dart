import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coop_campooste/providers/auth_provider.dart';
import 'package:coop_campooste/utils/theme.dart';

class RegistroSocioScreen extends StatefulWidget {
  const RegistroSocioScreen({super.key});

  @override
  State<RegistroSocioScreen> createState() => _RegistroSocioScreenState();
}

class _RegistroSocioScreenState extends State<RegistroSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  String _rolSeleccionado = 'SOCIO';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Nuevo Socio'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingrese la cédula del socio';
                  }
                  if (val.trim().length < 11) {
                    return 'La cédula debe contener al menos 11 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) =>
                (val == null || val.trim().isEmpty) ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) =>
                (val == null || val.trim().isEmpty) ? 'Ingrese el apellido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingrese el correo electrónico';
                  }
                  if (!val.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) =>
                (val == null || val.trim().isEmpty) ? 'Ingrese el teléfono' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _rolSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Rol de Sistema',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'SOCIO', child: Text('Socio General')),
                  DropdownMenuItem(value: 'CAJERO', child: Text('Cajero')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _rolSeleccionado = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña Temporal',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Ingrese una contraseña asignada';
                  }
                  if (val.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final exito = await authProvider.registrarSocio(
                      cedula: _cedulaController.text.trim(),
                      nombre: _nombreController.text.trim(),
                      apellido: _apellidoController.text.trim(),
                      email: _correoController.text.trim(),
                      telefono: _telefonoController.text.trim(),
                      rol: _rolSeleccionado,
                      password: _passwordController.text,
                    );

                    if (!mounted) return;

                    if (exito) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Socio registrado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      navigator.pop();
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.error ?? 'Error al registrar socio',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Registrar Socio',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}