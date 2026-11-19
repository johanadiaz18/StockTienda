
class Producto {
  final int? id;
  final int? categoriaId;
  final String nombre;
  final String? marca;
  final String? talle;
  final String? color;
  final double precioCompra;
  final double precioVenta;
  final int cantidad;
  final int stockMinimo;
  final String? fechaVencimiento;
  final String? fotoRuta;

  Producto({
    this.id,
    this.categoriaId,
    required this.nombre,
    this.marca,
    this.talle,
    this.color,
    required this.precioCompra,
    required this.precioVenta,
    required this.cantidad,
    required this.stockMinimo,
    this.fechaVencimiento,
    this.fotoRuta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'marca': marca,
      'talle': talle,
      'color': color,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'cantidad': cantidad,
      'stock_minimo': stockMinimo,
      'fecha_vencimiento': fechaVencimiento,
      'foto_ruta': fotoRuta,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      categoriaId: map['categoria_id'] as int?,
      nombre: map['nombre'] as String,
      marca: map['marca'] as String?,
      talle: map['talle'] as String?,
      color: map['color'] as String?,
      precioCompra:
          (map['precio_compra'] as num).toDouble(),
      precioVenta:
          (map['precio_venta'] as num).toDouble(),
      cantidad: map['cantidad'] as int,
      stockMinimo: map['stock_minimo'] as int,
      fechaVencimiento:
          map['fecha_vencimiento'] as String?,
      fotoRuta: map['foto_ruta'] as String?,
    );
  }

  bool get tieneStockBajo {
    return cantidad <= stockMinimo;
  }

  double get valorInventario {
    return precioCompra * cantidad;
  }
}
