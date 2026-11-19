
import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../services/categoria_service.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _categoriaService = CategoriaService();

  List<Categoria> _categorias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await _categoriaService.obtenerCategorias();

      if (!mounted) return;

      setState(() {
        _categorias = categorias;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar categorías: $error'),
          backgroundColor: azulMarino,
        ),
      );
    }
  }

  Future<void> _mostrarFormulario({Categoria? categoria}) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );

    String rubroSeleccionado = categoria?.rubro ?? 'General';

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, actualizarDialogo) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  categoria == null
                      ? 'Nueva categoría'
                      : 'Editar categoría',
                  style: const TextStyle(
                    color: azulMarino,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la categoría',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: azulMarino,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresá un nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: rubroSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Rubro',
                          prefixIcon: Icon(
                            Icons.store_outlined,
                            color: azulMarino,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'General',
                            child: Text('General'),
                          ),
                          DropdownMenuItem(
                            value: 'Kiosco',
                            child: Text('Kiosco'),
                          ),
                          DropdownMenuItem(
                            value: 'Tienda de ropa',
                            child: Text('Tienda de ropa'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            actualizarDialogo(() {
                              rubroSeleccionado = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      foregroundColor: azulMedio,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulMarino,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      try {
                        final nuevaCategoria = Categoria(
                          id: categoria?.id,
                          nombre: nombreController.text.trim(),
                          rubro: rubroSeleccionado,
                        );

                        if (categoria == null) {
                          await _categoriaService.guardarCategoria(
                            nuevaCategoria,
                          );
                        } else {
                          await _categoriaService.actualizarCategoria(
                            nuevaCategoria,
                          );
                        }

                        if (!mounted || !dialogContext.mounted) return;

                        Navigator.pop(dialogContext);

                        await _cargarCategorias();

                        if (messenger != null && messenger.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: azulMarino,
                              content: Text(
                                categoria == null
                                    ? 'Categoría registrada correctamente'
                                    : 'Categoría actualizada correctamente',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (!mounted || !dialogContext.mounted) return;

                        Navigator.pop(dialogContext);

                        if (messenger != null && messenger.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: azulMarino,
                              content: Text('Error al guardar: $error'),
                            ),
                          );
                        }
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
    } finally {
      nombreController.dispose();
    }
  }

  Future<void> _eliminarCategoria(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Eliminar categoría',
            style: TextStyle(
              color: azulMarino,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Deseás eliminar la categoría "${categoria.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: azulMedio,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulMarino,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || categoria.id == null) return;

    try {
      await _categoriaService.eliminarCategoria(categoria.id!);

      await _cargarCategorias();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: azulMarino,
          content: Text('Categoría eliminada correctamente'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: azulMarino,
          content: Text(
            'No se puede eliminar: la categoría puede tener productos asociados.',
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
          'Categorías',
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
          : _categorias.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 65,
                        color: azulMarino,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no hay categorías registradas.',
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
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: azulClaro,
                          child: Icon(
                            Icons.category,
                            color: azulMarino,
                          ),
                        ),
                        title: Text(
                          categoria.nombre,
                          style: const TextStyle(
                            color: azulMarino,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Rubro: ${categoria.rubro}',
                          style: const TextStyle(
                            color: azulMedio,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          iconColor: azulMarino,
                          onSelected: (opcion) {
                            if (opcion == 'editar') {
                              _mostrarFormulario(
                                categoria: categoria,
                              );
                            } else if (opcion == 'eliminar') {
                              _eliminarCategoria(categoria);
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
        label: const Text('Nueva categoría'),
      ),
    );
  }
}
