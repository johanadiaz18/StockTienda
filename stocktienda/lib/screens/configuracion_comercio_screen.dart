
import 'package:flutter/material.dart';

import '../models/comercio.dart';
import '../services/comercio_service.dart';

const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);

class ConfiguracionComercioScreen extends StatefulWidget {
  final Comercio comercio;

  const ConfiguracionComercioScreen({
    super.key,
    required this.comercio,
  });

  @override
  State<ConfiguracionComercioScreen> createState() =>
      _ConfiguracionComercioScreenState();
}

class _ConfiguracionComercioScreenState
    extends State<ConfiguracionComercioScreen> {
  final ComercioService _comercioService = ComercioService();

  final TextEditingController _nombreController =
      TextEditingController();

  final TextEditingController _rubroController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    _nombreController.text = widget.comercio.nombre;
    _rubroController.text = widget.comercio.rubro;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rubroController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final comercioActualizado = Comercio(
        id: widget.comercio.id,
        nombre: _nombreController.text.trim(),
        rubro: _rubroController.text.trim(),
      );

      await _comercioService.actualizarComercio(
        comercioActualizado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Datos del comercio actualizados.'),
          backgroundColor: azulMarino,
        ),
      );

      Navigator.pop(context, comercioActualizado);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text('Configuración del comercio'),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: azulMarino.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.storefront,
                      color: azulMarino,
                      size: 85,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Datos del comercio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: azulMarino,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Podés modificar el nombre y el rubro de tu negocio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del comercio',
                  prefixIcon: Icon(
                    Icons.store,
                    color: azulMedio,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresá el nombre del comercio.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _rubroController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Rubro del comercio',
                  prefixIcon: Icon(
                    Icons.business,
                    color: azulMedio,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresá el rubro del comercio.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarCambios,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar cambios',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulMarino,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
