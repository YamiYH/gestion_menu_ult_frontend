// lib/models/UserProfile.dart

import 'UserEntity.dart';

class UserProfile {
  final String username;
  final String name;
  final String fullName;
  final String email;
  final String? role;
  final List<String>? permissions;
  final String type;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.email,
    required this.type,
    required this.name,
    this.permissions,
    this.role,
  });

  factory UserProfile.fromUser(User user) {
    String name = user.name ?? '';
    String lastName = user.lastName ?? '';
    String role = '';
    List<String> permissions = [];
    if (user.roles.isNotEmpty) {
      role = user.roles.first.description;
      if (user.roles.first.permissions.isNotEmpty) {
        permissions = user.roles.first.permissions;
        permissions.add(role);
      }
    }

    return UserProfile(
      name: user.name,
      username: user.username,
      fullName: '$name $lastName'.trim(),
      email: user.email,
      role: role,
      permissions: permissions,
      type: user.type,
    );
  }
}
