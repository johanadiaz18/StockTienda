
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/producto.dart';

class ProductoService {
  // Registrar un producto.
  Future<int> guardarProducto(Producto producto) async {
    final db = await AppDatabase.instance.database;

    return await db.insert(
      'productos',
      producto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obtener todos los productos.
  Future<List<Producto>> obtenerProductos() async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'productos',
      orderBy: 'nombre ASC',
    );

    return resultado.map((fila) => Producto.fromMap(fila)).toList();
  }

  // Obtener un producto por su ID.
  Future<Producto?> obtenerProductoPorId(int id) async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Producto.fromMap(resultado.first);
  }

  // Obtener productos de una categoría.
  Future<List<Producto>> obtenerProductosPorCategoria(
    int categoriaId,
  ) async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'productos',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
      orderBy: 'nombre ASC',
    );

    return resultado.map((fila) => Producto.fromMap(fila)).toList();
  }

  // Actualizar un producto.
  Future<int> actualizarProducto(Producto producto) async {
    if (producto.id == null) {
      throw ArgumentError('El producto necesita un ID.');
    }

    final db = await AppDatabase.instance.database;

    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  // Eliminar un producto.
  Future<int> eliminarProducto(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener productos con stock bajo.
  Future<List<Producto>> obtenerProductosConStockBajo() async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'productos',
      where: 'cantidad <= stock_minimo',
      orderBy: 'cantidad ASC',
    );

    return resultado.map((fila) => Producto.fromMap(fila)).toList();
  }
}
