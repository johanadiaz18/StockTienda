
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/movimiento.dart';

class MovimientoService {
  // Registrar una entrada o salida de stock.
  Future<int> registrarMovimiento(Movimiento movimiento) async {
    final db = await AppDatabase.instance.database;

    return await db.transaction((txn) async {
      // Buscar el producto.
      final resultado = await txn.query(
        'productos',
        columns: ['id', 'cantidad'],
        where: 'id = ?',
        whereArgs: [movimiento.productoId],
        limit: 1,
      );

      if (resultado.isEmpty) {
        throw Exception('El producto no existe.');
      }

      final cantidadActual = resultado.first['cantidad'] as int;

      int nuevaCantidad;

      if (movimiento.tipo == 'entrada') {
        nuevaCantidad = cantidadActual + movimiento.cantidad;
      } else if (movimiento.tipo == 'salida') {
        if (movimiento.cantidad > cantidadActual) {
          throw Exception(
            'No hay suficiente stock disponible.',
          );
        }

        nuevaCantidad = cantidadActual - movimiento.cantidad;
      } else {
        throw Exception('Tipo de movimiento inválido.');
      }

      // Actualizar la cantidad del producto.
      await txn.update(
        'productos',
        {'cantidad': nuevaCantidad},
        where: 'id = ?',
        whereArgs: [movimiento.productoId],
      );

      // Registrar el movimiento.
      final datos = movimiento.toMap();
      datos.remove('id');

      return await txn.insert(
        'movimientos',
        datos,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  // Obtener todos los movimientos.
  Future<List<Movimiento>> obtenerMovimientos() async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'movimientos',
      orderBy: 'fecha DESC, id DESC',
    );

    return resultado
        .map((fila) => Movimiento.fromMap(fila))
        .toList();
  }

  // Obtener los movimientos de un producto.
  Future<List<Movimiento>> obtenerMovimientosPorProducto(
    int productoId,
  ) async {
    final db = await AppDatabase.instance.database;

    final resultado = await db.query(
      'movimientos',
      where: 'producto_id = ?',
      whereArgs: [productoId],
      orderBy: 'fecha DESC, id DESC',
    );

    return resultado
        .map((fila) => Movimiento.fromMap(fila))
        .toList();
  }
}
