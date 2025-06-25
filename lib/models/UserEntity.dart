// lib/models/User.dart

import 'package:gestion_menu_ult_frontend/models/RoleEntity.dart';

class User {
  final String username;
  final String name;
  final String lastName;
  final String email;
  final String type;
  final List<RoleEntity> roles;

  final bool enabled;

  User({
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.type,
    required this.roles,
    this.enabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var rolesFromJson = json['roles'] as List<dynamic>? ?? [];
    List<RoleEntity> parsedRoles = rolesFromJson
        .map((r) => RoleEntity.fromJson(r as Map<String, dynamic>))
        .toList();

    return User(
      username: json['username'] as String? ?? 'N/A',
      name: json['name'] as String? ?? 'N/A',
      lastName: json['lastName'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'N/A',
      roles: parsedRoles,
      // El campo 'active' o 'enabled' no existe en el JSON de la captura.
      // Deberías añadirlo en tu backend. Mientras tanto, podemos asumir 'true'.
      enabled: json['enabled'] as bool? ?? json['enabled'] as bool? ?? true,
    );
  }

  // Helper para obtener la descripción del primer rol
  String get mainRoleDescription =>
      roles.isNotEmpty ? roles.first.description : 'Sin Rol';
}
