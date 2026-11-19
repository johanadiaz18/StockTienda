
class Categoria {
  final int? id;
  final String nombre;
  final String rubro;

  Categoria({
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

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      rubro: map['rubro'] as String,
    );
  }
}
