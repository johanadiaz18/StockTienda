
import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final ProductoService _productoService = ProductoService();

  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    try {
      final productos =
          await _productoService.obtenerProductosConStockBajo();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudieron cargar las alertas.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text('Alertas de stock'),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _cargarAlertas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: azulMarino,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: azulMarino,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarAlertas,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulMarino,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _productos.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: azulMedio,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '¡Todo está en orden!',
                              style: TextStyle(
                                color: azulMarino,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No hay productos con stock bajo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: azulMarino,
                      onRefresh: _cargarAlertas,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            color: Colors.orange.shade50,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.deepOrange,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Hay ${_productos.length} productos '
                                      'que necesitan reposición.',
                                      style: const TextStyle(
                                        color: azulMarino,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ..._productos.map((producto) {
                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: azulClaro,
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                title: Text(
                                  producto.nombre,
                                  style: const TextStyle(
                                    color: azulMarino,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Stock actual: ${producto.cantidad}\n'
                                    'Stock mínimo: ${producto.stockMinimo}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: const Text(
                                  'Reponer',
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }
}
