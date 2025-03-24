class Reserva {
  final String tipoMenu; // 'Estudiantes' o 'Profesores'
  final List<String> productosSeleccionados;

  Reserva({required this.tipoMenu, required this.productosSeleccionados});
}
