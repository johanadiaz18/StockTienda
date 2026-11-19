
class Comercio {
  final int? id;
  final String nombre;
  final String rubro;

  Comercio({
    this.id,
    required this.nombre,
    required this.rubro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'rubro': rubro,
    };
  }

  factory Comercio.fromMap(Map<String, dynamic> map) {
    return Comercio(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      rubro: map['rubro'] as String,
    );
  }
}
