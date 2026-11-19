
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/producto.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';

// Paleta oficial de StockTienda.
const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();

  final ImagePicker _selectorImagen = ImagePicker();

  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await _productoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: azulMarino,
          content: Text('Error al cargar productos: $error'),
        ),
      );
    }
  }

  Future<void> _mostrarFormulario({Producto? producto}) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    List<Categoria> categorias;

    try {
      categorias = await _categoriaService.obtenerCategorias();
    } catch (error) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(
          backgroundColor: azulMarino,
          content: Text('Error al cargar categorías: $error'),
        ),
      );
      return;
    }

    if (!mounted) return;

    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );

    final marcaController = TextEditingController(
      text: producto?.marca ?? '',
    );

    final talleController = TextEditingController(
      text: producto?.talle ?? '',
    );

    final colorController = TextEditingController(
      text: producto?.color ?? '',
    );

    final precioCompraController = TextEditingController(
      text: producto?.precioCompra.toString() ?? '',
    );

    final precioVentaController = TextEditingController(
      text: producto?.precioVenta.toString() ?? '',
    );

    final cantidadController = TextEditingController(
      text: producto?.cantidad.toString() ?? '0',
    );

    final stockMinimoController = TextEditingController(
      text: producto?.stockMinimo.toString() ?? '0',
    );

    int? categoriaSeleccionada = producto?.categoriaId;
    String? fotoSeleccionada = producto?.fotoRuta;

    try {
      final navigator = Navigator.of(
        context,
        rootNavigator: true,
      );

      final dialogRoute = DialogRoute<void>(
        context: context,
        themes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, actualizarDialogo) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  producto == null
                      ? 'Nuevo producto'
                      : 'Editar producto',
                  style: const TextStyle(
                    color: azulMarino,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: 450,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fotografía del producto.
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: azulClaro,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: azulMedio,
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _crearImagenProducto(
                                fotoSeleccionada,
                                ancho: 130,
                                alto: 130,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: azulMarino,
                              side: const BorderSide(
                                color: azulMarino,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final XFile? imagen =
                                    await _selectorImagen.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                  maxWidth: 1200,
                                );

                                if (imagen == null) return;

                                final bytes = await imagen.readAsBytes();

                                if (!dialogContext.mounted) return;

                                actualizarDialogo(() {
                                  fotoSeleccionada = base64Encode(bytes);
                                });
                              } catch (error) {
                                if (!dialogContext.mounted) return;

                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    backgroundColor: azulMarino,
                                    content: Text(
                                      'Error al seleccionar la imagen: $error',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Elegir fotografía'),
                          ),

                          if (fotoSeleccionada != null) ...[
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: azulMedio,
                              ),
                              onPressed: () {
                                actualizarDialogo(() {
                                  fotoSeleccionada = null;
                                });
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Quitar fotografía'),
                            ),
                          ],

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto *',
                              prefixIcon: Icon(
                                Icons.inventory_2_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Ingresá el nombre del producto';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<int?>(
                            initialValue: categoriaSeleccionada,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Sin categoría'),
                              ),
                              ...categorias.map((categoria) {
                                return DropdownMenuItem<int?>(
                                  value: categoria.id,
                                  child: Text(categoria.nombre),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              actualizarDialogo(() {
                                categoriaSeleccionada = value;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: marcaController,
                            decoration: const InputDecoration(
                              labelText: 'Marca',
                              prefixIcon: Icon(
                                Icons.sell_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: talleController,
                            decoration: const InputDecoration(
                              labelText: 'Talle',
                              prefixIcon: Icon(
                                Icons.straighten,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: colorController,
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              prefixIcon: Icon(
                                Icons.palette_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: precioCompraController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Precio de compra *',
                              prefixText: '\$ ',
                              prefixIcon: Icon(
                                Icons.shopping_cart_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final numero = double.tryParse(
                                (value ?? '').replaceAll(',', '.'),
                              );

                              if (numero == null || numero < 0) {
                                return 'Ingresá un precio válido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: precioVentaController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Precio de venta *',
                              prefixText: '\$ ',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final numero = double.tryParse(
                                (value ?? '').replaceAll(',', '.'),
                              );

                              if (numero == null || numero < 0) {
                                return 'Ingresá un precio válido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: cantidadController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Cantidad disponible *',
                              prefixIcon: Icon(
                                Icons.inventory_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (int.tryParse(value ?? '') == null) {
                                return 'Ingresá una cantidad válida';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: stockMinimoController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Stock mínimo *',
                              prefixIcon: Icon(
                                Icons.warning_amber_outlined,
                                color: azulMarino,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (int.tryParse(value ?? '') == null) {
                                return 'Ingresá un stock mínimo válido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: azulMedio,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulMarino,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      try {
                        final nuevoProducto = Producto(
                          id: producto?.id,
                          categoriaId: categoriaSeleccionada,
                          nombre: nombreController.text.trim(),
                          marca: marcaController.text.trim().isEmpty
                              ? null
                              : marcaController.text.trim(),
                          talle: talleController.text.trim().isEmpty
                              ? null
                              : talleController.text.trim(),
                          color: colorController.text.trim().isEmpty
                              ? null
                              : colorController.text.trim(),
                          precioCompra: double.parse(
                            precioCompraController.text.replaceAll(
                              ',',
                              '.',
                            ),
                          ),
                          precioVenta: double.parse(
                            precioVentaController.text.replaceAll(
                              ',',
                              '.',
                            ),
                          ),
                          cantidad: int.parse(
                            cantidadController.text,
                          ),
                          stockMinimo: int.parse(
                            stockMinimoController.text,
                          ),
                          fechaVencimiento: producto?.fechaVencimiento,
                          fotoRuta: fotoSeleccionada,
                        );

                        if (producto == null) {
                          await _productoService.guardarProducto(
                            nuevoProducto,
                          );
                        } else {
                          await _productoService.actualizarProducto(
                            nuevoProducto,
                          );
                        }

                        if (!mounted || !dialogContext.mounted) {
                          return;
                        }

                        Navigator.pop(dialogContext);

                        await _cargarProductos();

                        if (messenger != null && messenger.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: azulMarino,
                              content: Text(
                                producto == null
                                    ? 'Producto registrado correctamente'
                                    : 'Producto actualizado correctamente',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (!mounted || !dialogContext.mounted) {
                          return;
                        }

                        messenger?.showSnackBar(
                          SnackBar(
                            backgroundColor: azulMarino,
                            content: Text(
                              'Error al guardar el producto: $error',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );

      await navigator.push(dialogRoute);
      await dialogRoute.completed;
    } finally {
      nombreController.dispose();
      marcaController.dispose();
      talleController.dispose();
      colorController.dispose();
      precioCompraController.dispose();
      precioVentaController.dispose();
      cantidadController.dispose();
      stockMinimoController.dispose();
    }
  }

  Widget _crearImagenProducto(
    String? fotoRuta, {
    required double ancho,
    required double alto,
  }) {
    if (fotoRuta == null || fotoRuta.isEmpty) {
      return const Icon(
        Icons.image_outlined,
        size: 45,
        color: azulMarino,
      );
    }

    try {
      return Image.memory(
        base64Decode(fotoRuta),
        width: ancho,
        height: alto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image_outlined,
            color: azulMarino,
          );
        },
      );
    } catch (_) {
      return const Icon(
        Icons.broken_image_outlined,
        color: azulMarino,
      );
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Eliminar producto',
            style: TextStyle(
              color: azulMarino,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Deseás eliminar "${producto.nombre}"?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: azulMedio,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulMarino,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || producto.id == null) return;

    try {
      await _productoService.eliminarProducto(producto.id!);

      await _cargarProductos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: azulMarino,
          content: Text('Producto eliminado correctamente'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: azulMarino,
          content: Text(
            'No se puede eliminar el producto porque tiene movimientos asociados.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text(
          'Productos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: azulMarino,
              ),
            )
          : _productos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 65,
                        color: azulMarino,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no hay productos registrados.',
                        style: TextStyle(
                          fontSize: 16,
                          color: azulMarino,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _productos.length,
                  itemBuilder: (context, index) {
                    final producto = _productos[index];

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        isThreeLine: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 55,
                            height: 55,
                            color: azulClaro,
                            child: producto.fotoRuta != null &&
                                    producto.fotoRuta!.isNotEmpty
                                ? _crearImagenProducto(
                                    producto.fotoRuta,
                                    ancho: 55,
                                    alto: 55,
                                  )
                                : CircleAvatar(
                                    backgroundColor: azulMedio,
                                    child: const Icon(
                                      Icons.inventory_2,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: azulMarino,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (producto.marca != null &&
                                producto.marca!.isNotEmpty)
                              Text(
                                'Marca: ${producto.marca}',
                                style: const TextStyle(
                                  color: azulMedio,
                                ),
                              ),
                            Text(
                              'Precio de venta: \$${producto.precioVenta.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: azulMedio,
                              ),
                            ),
                            Text(
                              'Cantidad: ${producto.cantidad}',
                              style: const TextStyle(
                                color: azulMedio,
                              ),
                            ),
                            Text(
                              'Stock mínimo: ${producto.stockMinimo}',
                              style: const TextStyle(
                                color: azulMedio,
                              ),
                            ),
                            if (producto.tieneStockBajo)
                              const Text(
                                '¡Stock bajo!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          iconColor: azulMarino,
                          onSelected: (opcion) {
                            if (opcion == 'editar') {
                              _mostrarFormulario(
                                producto: producto,
                              );
                            } else if (opcion == 'eliminar') {
                              _eliminarProducto(producto);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: azulMarino,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: azulMarino,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }
}
