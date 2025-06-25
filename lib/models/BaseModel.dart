class BaseModel {
  // Método para convertir una instancia de la clase en JSON
  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        'El método toJson debe ser implementado por las subclases.');
  }

  // Método estático para convertir un JSON en una instancia de la clase
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonFactory) {
    return fromJsonFactory(json);
  }
}
