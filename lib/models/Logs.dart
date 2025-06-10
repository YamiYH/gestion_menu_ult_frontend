import 'package:flutter/material.dart';

class Log {
  final String id;
  final String username;
  final DateTime date;
  final String module;
  final String type;
  final String action;
  final String? description;

  Log({
    required this.id,
    required this.username,
    required this.date,
    required this.module,
    required this.type,
    required this.action,
    this.description,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as String? ?? UniqueKey().toString(),
      username: json['username'] as String? ?? 'N/A',
      date: DateTime.parse(json['timestamp'] as String),
      module: json['module'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'N/A',
      action: json['action'] as String? ?? 'N/A',
      description: json['details'] as String?,
    );
  }

  // Método para convertir el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'date': date,
      'module': module,
      'type': type,
      'action': action,
      'description': description
    };
  }
}
