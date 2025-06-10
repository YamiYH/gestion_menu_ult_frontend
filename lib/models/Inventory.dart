// lib/models/Inventory.dart (versión recomendada)

class Inventory {
  final String code;
  final String description;
  final double existence; // Cambiado a double
  final String measurementUnit;
  final double price; // Cambiado a double

  const Inventory({
    required this.code,
    required this.description,
    required this.existence,
    required this.measurementUnit,
    required this.price,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    // Función segura para parsear números que pueden venir como String o num
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Inventory(
      code: json['code'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'Sin descripción',
      existence: safeParseDouble(json['existence']),
      measurementUnit: json['measurementUnit'] as String? ?? 'N/A',
      price: safeParseDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'existence': existence,
      'measurementUnit': measurementUnit,
      'price': price,
    };
  }
}
