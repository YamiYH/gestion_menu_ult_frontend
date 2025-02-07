// lib/models/menu_propuesta.dart
class MenuPropuesta {
  String tipo = ''; // 'estudiante' o 'profesor'
  Map<String, List<String>> comidas = Map(); // Desayuno, Almuerzo, Comida

  MenuPropuesta({required this.tipo, required this.comidas});

  // Método para convertir el objeto a un Map
  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'comidas': comidas,
    };
  }

  // Método para crear un objeto desde un Map
  factory MenuPropuesta.fromMap(Map<String, dynamic> map) {
    return MenuPropuesta(
      tipo: map['tipo'],
      comidas: Map<String, List<String>>.from(map['comidas']),
    );
  }
}
