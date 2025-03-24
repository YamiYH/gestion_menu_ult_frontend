import "package:equatable/equatable.dart";

// Enumerado UserType
enum UserType {
  ADMIN,
  USER,
}

class User extends Equatable {
  final String username;
  final String name;
  final String lastName;
  final String email;
  final UserType type;
  final List<Role> roles;
  final bool active;
  final DateTime lastLdapCheck;

  const User({
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.type,
    required this.roles,
    required this.active,
    required this.lastLdapCheck,
  });

  // Constructor desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      type: UserType.values.byName(json['type']),
      roles: (json['roles'] as List<dynamic>)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList(),
      active: json['active'],
      lastLdapCheck: DateTime.parse(json['lastLdapCheck']),
    );
  }

  // Método para convertir el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'lastName': lastName,
      'email': email,
      'type': type.name,
      'roles': roles.map((role) => role.toJson()).toList(),
      'active': active,
      'lastLdapCheck': lastLdapCheck.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        username,
        name,
        lastName,
        email,
        type,
        roles,
        active,
        lastLdapCheck,
      ];
}

class Role {
  final String name;

  const Role({
    required this.name,
  });

  // Constructor desde JSON
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'],
    );
  }

  // Método para convertir el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
