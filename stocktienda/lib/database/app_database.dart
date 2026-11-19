
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'stocktienda.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE comercios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        rubro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        rubro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoria_id INTEGER,
        nombre TEXT NOT NULL,
        marca TEXT,
        talle TEXT,
        color TEXT,
        precio_compra REAL NOT NULL DEFAULT 0,
        precio_venta REAL NOT NULL DEFAULT 0,
        cantidad INTEGER NOT NULL DEFAULT 0
          CHECK (cantidad >= 0),
        stock_minimo INTEGER NOT NULL DEFAULT 0
          CHECK (stock_minimo >= 0),
        fecha_vencimiento TEXT,
        foto_ruta TEXT,
        FOREIGN KEY (categoria_id)
          REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL
          CHECK (tipo IN ('entrada', 'salida')),
        cantidad INTEGER NOT NULL
          CHECK (cantidad > 0),
        fecha TEXT NOT NULL,
        observacion TEXT,
        motivo TEXT,
        precio_unitario REAL,
        importe_total REAL,
        FOREIGN KEY (producto_id)
          REFERENCES productos(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
