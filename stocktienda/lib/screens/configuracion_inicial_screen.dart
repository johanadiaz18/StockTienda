
import 'package:flutter/material.dart';

import '../models/comercio.dart';
import '../services/comercio_service.dart';
import 'home_screen.dart';

class ConfiguracionInicialScreen extends StatefulWidget {
  const ConfiguracionInicialScreen({super.key});

  @override
  State<ConfiguracionInicialScreen> createState() =>
      _ConfiguracionInicialScreenState();
}

class _ConfiguracionInicialScreenState
    extends State<ConfiguracionInicialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _comercioService = ComercioService();

  String? _rubroSeleccionado;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardarComercio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final comercioExistente =
          await _comercioService.obtenerComercio();

      if (comercioExistente != null) {
        throw StateError(
          'Ya existe un comercio configurado.',
        );
      }

      final comercio = Comercio(
        nombre: _nombreController.text.trim(),
        rubro: _rubroSeleccionado!,
      );

      await _comercioService.guardarComercio(comercio);

      final comercioGuardado =
          await _comercioService.obtenerComercio();

      if (comercioGuardado == null) {
        throw StateError(
          'No se pudo recuperar el comercio guardado.',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Comercio registrado correctamente!',
          ),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            comercio: comercioGuardado,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar el comercio: $error',
          ),
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
    const azulMarino = Color(0xFF0B1F3A);
    const turquesa = Color(0xFF26A6A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text('StockTienda'),
        backgroundColor: azulMarino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo original de StockTienda.
                Center(
                  child: Image.asset(
                    'assets/images/logo_st.png',
                    height: 155,
                    width: 190,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Bienvenido a StockTienda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: azulMarino,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Configuremos tu negocio para comenzar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 32),

                // Nombre del comercio.
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del comercio',
                    hintText: 'Ej.: Mi Kiosco',
                    prefixIcon: const Icon(
                      Icons.store,
                      color: turquesa,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresá el nombre del comercio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Tipo de comercio.
                DropdownButtonFormField<String>(
                  initialValue: _rubroSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Tipo de comercio',
                    prefixIcon: const Icon(
                      Icons.category,
                      color: turquesa,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Kiosco',
                      child: Text('Kiosco'),
                    ),
                    DropdownMenuItem(
                      value: 'Tienda de ropa',
                      child: Text('Tienda de ropa'),
                    ),
                  ],
                  onChanged: _guardando
                      ? null
                      : (value) {
                          setState(() {
                            _rubroSeleccionado = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccioná un tipo de comercio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Guardar y continuar.
                ElevatedButton.icon(
                  onPressed:
                      _guardando ? null : _guardarComercio,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : 'Guardar y continuar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulMarino,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
