import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ticket_service.dart';

void abrirDialogoInscripcionSocio(BuildContext context) {
  final nombreCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final aporteCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Inscribir Nuevo Socio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
            const SizedBox(height: 8),
            TextField(controller: cedulaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cédula')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo Electrónico')),
            const SizedBox(height: 8),
            TextField(controller: telefonoCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono')),
            const SizedBox(height: 8),
            TextField(
              controller: aporteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Aporte Inicial (RD\$)', prefixText: 'RD\$ '),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton.icon(
          icon: const Icon(Icons.print),
          label: const Text('Registrar e Imprimir'),
          onPressed: () async {
            final nombre = nombreCtrl.text.trim();
            final monto = double.tryParse(aporteCtrl.text) ?? 0.0;
            final auth = Provider.of<AuthProvider>(context, listen: false);

            if (nombre.isEmpty || monto <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor complete los campos obligatorios.')),
              );
              return;
            }

            Navigator.pop(ctx);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrando en NestJS e imprimiendo recibo...'),
                backgroundColor: Colors.green,
              ),
            );

            // Disparar Impresión Térmica
            await TicketService.imprimirReciboOperacion(
              tipoOperacion: 'Inscripción y Aporte Inicial',
              socioNombre: nombre,
              monto: monto,
              // Corrección aplicada aquí:
              atendidopor: auth.usuario?.nombreCompleto ?? 'Cajero',
            );
          },
        ),
      ],
    ),
  );
}