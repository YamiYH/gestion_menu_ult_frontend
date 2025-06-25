// Representa un único informe (ej. un PDF)
class SalesReport {
  final String nombre;
  final String archivoUrl; // URL para descargar el archivo

  SalesReport({required this.nombre, required this.archivoUrl});

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      nombre: json['nombre'] as String? ?? 'Nombre no disponible',
      // Asume que el backend envía una URL de descarga en la clave 'archivo' o 'url'
      archivoUrl: json['archivo'] as String? ?? json['url'] as String? ?? '',
    );
  }
}

// Representa el grupo de informes para una fecha específica
class DailyReportGroup {
  final DateTime fecha;
  final List<SalesReport> informes;

  DailyReportGroup({required this.fecha, required this.informes});

  factory DailyReportGroup.fromJson(Map<String, dynamic> json) {
    var reportListJson = json['informes'] as List<dynamic>? ?? [];
    List<SalesReport> parsedReports = reportListJson
        .map((item) => SalesReport.fromJson(item as Map<String, dynamic>))
        .toList();

    return DailyReportGroup(
      fecha: DateTime.parse(
          json['fecha'] as String? ?? DateTime.now().toIso8601String()),
      informes: parsedReports,
    );
  }
}
