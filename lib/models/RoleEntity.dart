import 'package:flutter/material.dart';

class RoleEntity {
  String? id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool enabled;
  final bool deletable;

  RoleEntity(
      {this.id,
      required this.name,
      required this.description,
      required this.permissions,
      required this.enabled,
      required this.deletable});

  // Constructor desde JSON
  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    final permissionsList = json['permissions'];
    final List<String> parsedPermissions = permissionsList is List
        ? List<String>.from(permissionsList.map((p) => p.toString()))
        : [];
    return RoleEntity(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['name'] as String? ?? 'Sin Nombre',
      description: json['description'] as String? ?? 'Sin Descripción',
      permissions: parsedPermissions,
      enabled: json['enabled'],
      deletable: json['deletable'],
    );
  }

  // Método para convertir el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'enabled': enabled,
    };
  }

  @override
  List<Object?> get props => [id, name, description, permissions, enabled];
}
