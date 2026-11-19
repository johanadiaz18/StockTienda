
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/categoria.dart';

class CategoriaService {
  // Registrar una categoría.
  Future<int> guardarCategoria(Categoria categoria) async {
    final db = await AppDatabase.instance.database;

    return await db.insert(
      'categorias',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obtener todas las categorías.
  Future<List<Categoria>> obtenerCategorias() async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'categorias',
      orderBy: 'nombre ASC',
    );

    return resultado.map((fila) => Categoria.fromMap(fila)).toList();
  }

  // Obtener una categoría por su ID.
  Future<Categoria?> obtenerCategoriaPorId(int id) async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Categoria.fromMap(resultado.first);
  }

  // Actualizar una categoría.
  Future<int> actualizarCategoria(Categoria categoria) async {
    if (categoria.id == null) {
      throw ArgumentError('La categoría necesita un ID.');
    }

    final db = await AppDatabase.instance.database;

    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  // Eliminar una categoría.
  Future<int> eliminarCategoria(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
