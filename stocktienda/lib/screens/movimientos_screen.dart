
import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/producto.dart';
import '../services/movimiento_service.dart';
import '../services/producto_service.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  final MovimientoService _movimientoService = MovimientoService();
  final ProductoService _productoService = ProductoService();

  List<Movimiento> _movimientos = [];
  List<Producto> _productos = [];

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final productos = await _productoService.obtenerProductos();
      final movimientos = await _movimientoService.obtenerMovimientos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _movimientos = movimientos;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudieron cargar los movimientos.';
        _cargando = false;
      });
    }
  }

  Future<void> _mostrarFormulario() async {
    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: azulMarino,
          content: Text(
            'Primero tenés que registrar un producto.',
          ),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);

    final cantidadController = TextEditingController();
    final motivoController = TextEditingController();
    final observacionController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    int? productoSeleccionadoId = _productos.first.id;
    String tipoSeleccionado = 'entrada';
    bool guardando = false;
    String? errorFormulario;

    try {
      final navigator = Navigator.of(
        context,
        rootNavigator: true,
      );

      final dialogRoute = DialogRoute<bool>(
        context: context,
        themes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text(
                  'Registrar movimiento',
                  style: TextStyle(
                    color: azulMarino,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: productoSeleccionadoId,
                          decoration: const InputDecoration(
                            labelText: 'Producto',
                            prefixIcon: Icon(
                              Icons.inventory_2_outlined,
                              color: azulMedio,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: _productos.map((producto) {
                            return DropdownMenuItem<int>(
                              value: producto.id,
                              child: Text(producto.nombre),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setDialogState(() {
                              productoSeleccionadoId = valor;
                            });
                          },
                          validator: (valor) {
                            if (valor == null) {
                              return 'Seleccioná un producto.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: tipoSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de movimiento',
                            prefixIcon: Icon(
                              Icons.swap_vert,
                              color: azulMedio,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'entrada',
                              child: Text('Entrada de stock'),
                            ),
                            DropdownMenuItem(
                              value: 'salida',
                              child: Text('Salida de stock'),
                            ),
                          ],
                          onChanged: (valor) {
                            if (valor == null) return;

                            setDialogState(() {
                              tipoSeleccionado = valor;
                              motivoController.text =
                                  valor == 'entrada' ? 'compra' : 'ajuste';
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                            prefixIcon: Icon(
                              Icons.numbers,
                              color: azulMedio,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            final cantidad = int.tryParse(valor ?? '');

                            if (cantidad == null || cantidad <= 0) {
                              return 'Ingresá una cantidad válida.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: motivoController,
                          decoration: const InputDecoration(
                            labelText: 'Motivo',
                            hintText: 'Ej.: compra, venta, pérdida',
                            prefixIcon: Icon(
                              Icons.assignment_outlined,
                              color: azulMedio,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: observacionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Observación (opcional)',
                            prefixIcon: Icon(
                              Icons.notes,
                              color: azulMedio,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        if (errorFormulario != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorFormulario!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: guardando
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: azulMedio),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulMarino,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: guardando
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              guardando = true;
                              errorFormulario = null;
                            });

                            try {
                              final movimiento = Movimiento(
                                productoId: productoSeleccionadoId!,
                                tipo: tipoSeleccionado,
                                cantidad: int.parse(
                                  cantidadController.text,
                                ),
                                fecha: DateTime.now().toIso8601String(),
                                motivo: motivoController.text.trim().isEmpty
                                    ? null
                                    : motivoController.text.trim(),
                                observacion:
                                    observacionController.text.trim().isEmpty
                                        ? null
                                        : observacionController.text.trim(),
                              );

                              await _movimientoService.registrarMovimiento(
                                movimiento,
                              );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext, true);
                            } catch (e) {
                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                guardando = false;
                                errorFormulario = e
                                    .toString()
                                    .replaceFirst('Exception: ', '');
                              });
                            }
                          },
                    child: guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );

      final guardado = await navigator.push(dialogRoute);
      await dialogRoute.completed;

      if (guardado == true && mounted) {
        await _cargarDatos();

        if (messenger != null && messenger.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              backgroundColor: azulMarino,
              content: Text(
                'Movimiento registrado correctamente.',
              ),
            ),
          );
        }
      }
    } finally {
      cantidadController.dispose();
      motivoController.dispose();
      observacionController.dispose();
    }
  }

  String _nombreProducto(int productoId) {
    for (final producto in _productos) {
      if (producto.id == productoId) {
        return producto.nombre;
      }
    }
    return 'Producto no encontrado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text('Movimientos de stock'),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : _movimientos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.swap_vert_circle_outlined,
                              size: 75,
                              color: azulMedio,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Todavía no hay movimientos registrados.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: azulMarino,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: azulMarino,
                      onRefresh: _cargarDatos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _movimientos.length,
                        itemBuilder: (context, index) {
                          final movimiento = _movimientos[index];
                          final esEntrada = movimiento.esEntrada;

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
                              leading: CircleAvatar(
                                backgroundColor: azulClaro,
                                child: Icon(
                                  esEntrada
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: azulMedio,
                                ),
                              ),
                              title: Text(
                                _nombreProducto(movimiento.productoId),
                                style: const TextStyle(
                                  color: azulMarino,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${esEntrada ? 'Entrada' : 'Salida'}'
                                ' • ${movimiento.motivo ?? 'Sin motivo'}\n'
                                '${movimiento.fecha.replaceFirst('T', ' ')}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                '${esEntrada ? '+' : '-'}'
                                '${movimiento.cantidad}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: azulMedio,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormulario,
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
    );
  }
}
