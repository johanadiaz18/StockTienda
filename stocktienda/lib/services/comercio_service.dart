
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/comercio.dart';

class ComercioService {
  Future<int> guardarComercio(Comercio comercio) async {
    final db = await AppDatabase.instance.database;

    return await db.insert(
      'comercios',
      comercio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Comercio?> obtenerComercio() async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'comercios',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return Comercio.fromMap(resultado.first);
  }

  Future<int> actualizarComercio(Comercio comercio) async {
    if (comercio.id == null) {
      throw ArgumentError(
        'El comercio debe tener un ID para actualizarse.',
      );
    }

    final db = await AppDatabase.instance.database;

    return await db.update(
      'comercios',
      comercio.toMap(),
      where: 'id = ?',
      whereArgs: [comercio.id],
    );
  }

  Future<bool> existeComercio() async {
    final comercio = await obtenerComercio();
    return comercio != null;
  }
}
