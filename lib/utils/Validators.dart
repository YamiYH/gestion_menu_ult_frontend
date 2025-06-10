// lib/utils/validators.dart

/// Una clase de utilidad que contiene métodos estáticos para la validación de campos de texto.
/// Cada método agrupa un conjunto de reglas específicas para un tipo de campo.
class Validators {
  /// Valida un campo de nombre de usuario con las siguientes reglas:
  /// 1. Requerido.
  /// 2. No debe contener mayúsculas.
  /// 3. No debe contener números.
  /// 4. No debe contener espacios.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de usuario es requerido.';
    }
    if (value.contains(' ')) {
      return 'No se permiten espacios.';
    }
    if (RegExp(r'[A-Z]').hasMatch(value)) {
      return 'No se permiten mayúsculas.';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'No se permiten números.';
    }
    return null; // El valor es válido
  }

  /// Valida un nombre de persona (Nombre o Apellido) con las siguientes reglas:
  /// 1. Requerido.
  /// 2. No debe contener números ni caracteres especiales.
  /// 3. La letra inicial de cada palabra debe ser mayúscula (Title Case).
  static String? personName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido.';
    }
    // Verifica que no haya números o símbolos no deseados
    if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
      return 'Solo se permiten letras y espacios.';
    }
    // Verifica que cada palabra inicie con mayúscula
    final words = value.split(' ');
    for (final word in words) {
      if (word.isNotEmpty && word[0] != word[0].toUpperCase()) {
        return 'La inicial de cada palabra debe ser mayúscula.';
      }
    }
    return null; // El valor es válido
  }

  /// Valida la fortaleza de una contraseña con las siguientes reglas:
  /// 1. Requerida.
  /// 2. Mínimo 7 caracteres de longitud.
  /// 3. Debe contener al menos una letra minúscula.
  /// 4. Debe contener al menos una letra mayúscula.
  /// 5. Debe contener al menos un número.
  /// 6. Debe contener al menos un carácter especial (ej. !@#$%).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida.';
    }
    if (value.length <= 6) {
      return 'Debe tener más de 6 caracteres.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Debe contener al menos un carácter especial.';
    }
    return null; // La contraseña es válida
  }

  /// Valida un formato de correo electrónico.
  /// Se puede especificar si el campo es requerido o no.
  static String? email(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'El correo es requerido.' : null;
    }
    final emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailPattern.hasMatch(value)) {
      return 'Formato de correo inválido.';
    }
    return null;
  }

  /// Valida la parte del nombre de un rol (lo que va después de "ROLE_").
  /// 1. Requerido.
  /// 2. Debe estar en mayúsculas.
  /// 3. Solo puede contener letras y guiones bajos (_).
  static String? roleNamePart(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del rol es requerido.';
    }
    if (value.contains(' ')) {
      return 'No se permiten espacios.';
    }
    if (value != value.toUpperCase()) {
      return 'El nombre del rol debe estar en mayúsculas.';
    }
    final validCharsPattern = RegExp(r'^[A-Z_]+$');
    if (!validCharsPattern.hasMatch(value)) {
      return 'Solo se permiten mayúsculas y guion bajo (_).';
    }
    return null; // El valor es válido
  }
}
