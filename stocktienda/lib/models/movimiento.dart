
class Movimiento {
  final int? id;
  final int productoId;
  final String tipo;
  final int cantidad;
  final String fecha;
  final String? observacion;
  final String? motivo;
  final double? precioUnitario;
  final double? importeTotal;

  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.observacion,
    this.motivo,
    this.precioUnitario,
    this.importeTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha,
      'observacion': observacion,
      'motivo': motivo,
      'precio_unitario': precioUnitario,
      'importe_total': importeTotal,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      productoId: map['producto_id'] as int,
      tipo: map['tipo'] as String,
      cantidad: map['cantidad'] as int,
      fecha: map['fecha'] as String,
      observacion: map['observacion'] as String?,
      motivo: map['motivo'] as String?,
      precioUnitario:
          (map['precio_unitario'] as num?)?.toDouble(),
      importeTotal:
          (map['importe_total'] as num?)?.toDouble(),
    );
  }

  bool get esEntrada => tipo == 'entrada';

  bool get esSalida => tipo == 'salida';

  bool get esVenta =>
      tipo == 'salida' && motivo == 'venta';
}
