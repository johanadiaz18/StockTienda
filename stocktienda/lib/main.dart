
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'models/comercio.dart';
import 'screens/configuracion_inicial_screen.dart';
import 'screens/home_screen.dart';
import 'services/comercio_service.dart';

// Paleta oficial de StockTienda: tonos azules.
const Color azulMarino = Color(0xFF0B1F3A);
const Color azulMedio = Color(0xFF183A60);
const Color azulClaro = Color(0xFFEAF0F7);
const Color fondoApp = Color(0xFFF5F7FA);
const Color blanco = Colors.white;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de SQLite para Microsoft Edge.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const StockTiendaApp());
}

class StockTiendaApp extends StatelessWidget {
  const StockTiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockTienda',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: fondoApp,

        colorScheme: ColorScheme.fromSeed(
          seedColor: azulMarino,
          primary: azulMarino,
          secondary: azulMedio,
          surface: blanco,
        ),

        // Barra superior.
        appBarTheme: const AppBarTheme(
          backgroundColor: azulMarino,
          foregroundColor: blanco,
          centerTitle: true,
          elevation: 0,
        ),

        // Botones principales.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azulMarino,
            foregroundColor: blanco,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),

        // Campos de texto y formularios.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: blanco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: azulClaro,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: azulMedio,
              width: 2,
            ),
          ),
        ),

        // Botón flotante.
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: azulMarino,
          foregroundColor: blanco,
        ),

        // Tarjetas.
        cardTheme: CardThemeData(
          color: blanco,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        // Casillas de selección.
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return azulMarino;
            }
            return null;
          }),
        ),

        // Indicadores de carga.
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: azulMarino,
        ),

        // Íconos.
        iconTheme: const IconThemeData(
          color: azulMarino,
        ),

        // Navegación.
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: blanco,
          indicatorColor: azulClaro,
        ),
      ),

      home: const InicioScreen(),
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final ComercioService _comercioService = ComercioService();

  late Future<Comercio?> _comercioFuture;

  @override
  void initState() {
    super.initState();
    _comercioFuture = _comercioService.obtenerComercio();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Comercio?>(
      future: _comercioFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: azulMarino,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar el comercio: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final comercio = snapshot.data;

        if (comercio == null) {
          return const ConfiguracionInicialScreen();
        }

        return HomeScreen(comercio: comercio);
      },
    );
  }
}
