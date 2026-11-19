
import 'package:flutter/material.dart';

import '../models/comercio.dart';
import 'categorias_screen.dart';
import 'productos_screen.dart';
import 'movimientos_screen.dart';
import 'alertas_screen.dart';
import 'reportes_screen.dart';
import 'configuracion_comercio_screen.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class HomeScreen extends StatefulWidget {
  final Comercio comercio;

  const HomeScreen({
    super.key,
    required this.comercio,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Comercio _comercio;

  @override
  void initState() {
    super.initState();
    _comercio = widget.comercio;
  }

  Future<void> _abrirConfiguracion() async {
    final comercioActualizado = await Navigator.push<Comercio>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfiguracionComercioScreen(
          comercio: _comercio,
        ),
      ),
    );

    if (!mounted) return;

    if (comercioActualizado != null) {
      setState(() {
        _comercio = comercioActualizado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text(
          'StockTienda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: azulMarino.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.storefront,
                    size: 80,
                    color: azulMarino,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    '¡Bienvenido a ${_comercio.nombre}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: azulMarino,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nombre del comercio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store,
                        color: Color(0xFF0B1F3A),
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _comercio.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: azulMedio,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tipo de comercio
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: azulClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF0B1F3A),
                        size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Tipo de comercio: ${_comercio.rubro}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: azulMedio,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Panel principal',
              style: TextStyle(
                color: azulMarino,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Seleccioná una opción para administrar tu comercio.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            _crearTarjeta(
              context,
              icono: Icons.category,
              titulo: 'Categorías',
              descripcion:
                  'Registrar, consultar, editar y eliminar categorías.',
              pantalla: const CategoriasScreen(),
            ),

            const SizedBox(height: 12),

            _crearTarjeta(
              context,
              icono: Icons.inventory_2,
              titulo: 'Productos',
              descripcion:
                  'Registrar, consultar, editar y eliminar productos.',
              pantalla: const ProductosScreen(),
            ),

            const SizedBox(height: 12),

            _crearTarjeta(
              context,
              icono: Icons.swap_vert,
              titulo: 'Movimientos de stock',
              descripcion:
                  'Registrar entradas y salidas de mercadería.',
              pantalla: const MovimientosScreen(),
            ),

            const SizedBox(height: 12),

            _crearTarjeta(
              context,
              icono: Icons.warning_amber_rounded,
              titulo: 'Alertas de stock',
              descripcion:
                  'Consultar productos que necesitan reposición.',
              pantalla: const AlertasScreen(),
            ),

            const SizedBox(height: 12),

            _crearTarjeta(
              context,
              icono: Icons.bar_chart,
              titulo: 'Reportes',
              descripcion:
                  'Consultar el resumen y valor del inventario.',
              pantalla: const ReportesScreen(),
            ),

            const SizedBox(height: 12),

            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: azulClaro,
                  radius: 28,
                  child: Icon(
                    Icons.settings,
                    color: azulMarino,
                    size: 30,
                  ),
                ),
                title: const Text(
                  'Configuración',
                  style: TextStyle(
                    color: azulMarino,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Modificar los datos del comercio.',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: azulMedio,
                  size: 18,
                ),
                onTap: _abrirConfiguracion,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Gestión de inventario, ventas y alertas de stock.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: azulMedio,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _crearTarjeta(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Widget pantalla,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: azulClaro,
          radius: 28,
          child: Icon(
            icono,
            color: azulMarino,
            size: 30,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: azulMarino,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: azulMedio,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => pantalla,
            ),
          );
        },
      ),
    );
  }
}
