
import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ProductoService _productoService = ProductoService();

  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    try {
      final productos = await _productoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudo generar el reporte.';
        _cargando = false;
      });
    }
  }

  int get _totalUnidades {
    return _productos.fold(
      0,
      (total, producto) => total + producto.cantidad,
    );
  }

  int get _productosStockBajo {
    return _productos.where((producto) => producto.tieneStockBajo).length;
  }

  double get _valorCompra {
    return _productos.fold(
      0,
      (total, producto) => total + producto.valorInventario,
    );
  }

  double get _valorVenta {
    return _productos.fold(
      0,
      (total, producto) => total + producto.precioVenta * producto.cantidad,
    );
  }

  String _formatearPrecio(double valor) {
    return '\$ ${valor.toStringAsFixed(2)}';
  }

  Widget _crearIndicador({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withAlpha(30),
              child: Icon(
                icono,
                color: color,
                size: 29,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: azulMarino,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearTitulo(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: azulMarino,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _cargarReporte,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar reporte',
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
                          onPressed: _cargarReporte,
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
              : RefreshIndicator(
                  color: azulMarino,
                  onRefresh: _cargarReporte,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _crearTitulo('Resumen del inventario'),

                      const SizedBox(height: 8),

                      const Text(
                        'Información general de los productos registrados.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _crearIndicador(
                        titulo: 'Productos registrados',
                        valor: '${_productos.length}',
                        icono: Icons.inventory_2,
                        color: azulMedio,
                      ),

                      _crearIndicador(
                        titulo: 'Unidades disponibles',
                        valor: '$_totalUnidades',
                        icono: Icons.warehouse,
                        color: azulMedio,
                      ),

                      _crearIndicador(
                        titulo: 'Productos con stock bajo',
                        valor: '$_productosStockBajo',
                        icono: Icons.warning_amber_rounded,
                        color: Colors.deepOrange,
                      ),

                      const SizedBox(height: 12),

                      _crearTitulo('Valor del inventario'),

                      const SizedBox(height: 12),

                      _crearIndicador(
                        titulo: 'Valor según precio de compra',
                        valor: _formatearPrecio(_valorCompra),
                        icono: Icons.shopping_cart,
                        color: azulMedio,
                      ),

                      _crearIndicador(
                        titulo: 'Valor potencial de venta',
                        valor: _formatearPrecio(_valorVenta),
                        icono: Icons.attach_money,
                        color: azulMedio,
                      ),

                      const SizedBox(height: 12),

                      _crearTitulo('Detalle de productos'),

                      const SizedBox(height: 12),

                      if (_productos.isEmpty)
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Todavía no hay productos registrados.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: azulMarino,
                              ),
                            ),
                          ),
                        )
                      else
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
                                  Icons.inventory_2_outlined,
                                  color: azulMedio,
                                ),
                              ),
                              title: Text(
                                producto.nombre,
                                style: const TextStyle(
                                  color: azulMarino,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Cantidad: ${producto.cantidad}\n'
                                'Precio de compra: '
                                '${_formatearPrecio(producto.precioCompra)}\n'
                                'Precio de venta: '
                                '${_formatearPrecio(producto.precioVenta)}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                              isThreeLine: true,
                              trailing: producto.tieneStockBajo
                                  ? const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.deepOrange,
                                    )
                                  : const Icon(
                                      Icons.check_circle_outline,
                                      color: azulMedio,
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
