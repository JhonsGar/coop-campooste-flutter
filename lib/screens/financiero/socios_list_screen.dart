import '../../utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/socio.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'socio_detalle_screen.dart';

class SociosListScreen extends StatefulWidget {
  const SociosListScreen({super.key});

  @override
  State<SociosListScreen> createState() => _SociosListScreenState();
}

class _SociosListScreenState extends State<SociosListScreen> {
  List<Socio> _socios = [];
  List<Socio> _sociosFiltrados = [];
  bool _cargando = true;
  String? _error;
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarSocios();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarSocios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token;  // ✅ limpio
      final data = await ApiService.get('/socios', token: token);
      final lista = (data as List).map((e) => Socio.fromJson(e)).toList();
      setState(() {
        _socios = lista;
        _sociosFiltrados = lista;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  void _filtrar(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _sociosFiltrados = _socios;
      } else {
        _sociosFiltrados = _socios.where((s) {
          return s.nombreCompleto.toLowerCase().contains(q) ||
              s.cedula.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Color _colorRol(String? rol) {
    switch ((rol ?? '').toLowerCase()) {
      case 'administrador':
        return Colors.red;
      case 'secretario':
        return Colors.purple;
      case 'cajero':
        return Colors.orange;
      case 'empleados':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socios'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarSocios,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: _filtrar,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, cédula o email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaCtrl.clear();
                    _filtrar('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // 📊 Contador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_sociosFiltrados.length} socio(s)',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 📋 Lista
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError()
                : _sociosFiltrados.isEmpty
                ? _buildVacio()
                : RefreshIndicator(
              onRefresh: _cargarSocios,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _sociosFiltrados.length,
                itemBuilder: (context, i) {
                  final s = _sociosFiltrados[i];
                  final color = _colorRol(s.rol);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(
                          s.nombreCompleto.isNotEmpty
                              ? s.nombreCompleto[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        s.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text('Cédula: ${Formatters.cedula(s.cedula)}'),
                          if (s.rol != null && s.rol!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s.rol!,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SocioDetalleScreen(socio: s),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'No se encontraron socios',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'Error al cargar socios',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarSocios,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}