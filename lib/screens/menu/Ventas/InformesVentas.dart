// lib/screens/admin/InformesVentas.dart

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/ReportController.dart';
import 'package:gestion_menu_ult_frontend/models/SalesReport.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:intl/intl.dart';

import '../../../widgets/Button.dart';
import '../../../widgets/DatePickerButton.dart';
import '../../../widgets/Pagination.dart';

class InformesVentas extends StatefulWidget {
  const InformesVentas({super.key}); // Añadido super.key

  @override
  State<InformesVentas> createState() => _InformesVentasState();
}

class _InformesVentasState extends State<InformesVentas> {
  final ReportController _controller = ReportController();
  bool _isLoading = true;
  List<DailyReportGroup> _reportGroups = [];

  // Las fechas ahora se manejan en el controlador, pero las guardamos
  // localmente para los DatePickers
  DateTime? _localStartDate;
  DateTime? _localEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Actualiza el controlador con las fechas de la UI
    _controller.startDate = _localStartDate;
    _controller.endDate = _localEndDate;

    try {
      final reportsFromApi = await _controller.fetchReports();
      setState(() {
        _reportGroups = reportsFromApi;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar informes: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _triggerSearch() {
    // Al buscar, siempre reseteamos a la primera página
    _controller.currentPage = 0;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Informes de Ventas'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    children: [
                      _buildDatePickerRow(),
                      const SizedBox(height: 15),
                      Button(
                          onPressed: _triggerSearch,
                          icon: Icons.search,
                          text: 'Buscar'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDatePickerRow(),
                      const SizedBox(width: 30),
                      Button(
                          onPressed: _triggerSearch,
                          icon: Icons.search,
                          text: 'Buscar'),
                    ],
                  ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reportGroups.isEmpty
                    ? const Center(
                        child: Text(
                            'No se encontraron informes para las fechas seleccionadas.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _reportGroups.length,
                        itemBuilder: (context, index) {
                          final reportGroup = _reportGroups[index];
                          return _buildInformeCard(reportGroup);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        currentPage: _controller.currentPage,
        totalPages: _controller.totalPages,
        itemsPerPage: _controller.pageSize,
        onPageChanged: (newPage) {
          if (_controller.currentPage != newPage) {
            _controller.currentPage = newPage;
            _fetchData();
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            _controller.pageSize = newSize;
            _controller.currentPage = 0;
            _fetchData();
          }
        },
      ),
    );
  }

  Widget _buildDatePickerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePickerButton(
          label: 'Desde',
          selectedDate: _localStartDate,
          onDateSelected: (date) {
            setState(() {
              _localStartDate = date;
            });
          },
          firstDate: DateTime(2000),
          lastDate: _localEndDate ?? DateTime.now(),
        ),
        const SizedBox(width: 10),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        const SizedBox(width: 10),
        DatePickerButton(
          label: 'Hasta',
          selectedDate: _localEndDate,
          onDateSelected: (date) {
            setState(() {
              _localEndDate = date;
            });
          },
          firstDate: _localStartDate ?? DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildInformeCard(DailyReportGroup reportGroup) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    // Formatea la fecha usando intl para mostrarla
    final String fecha =
        DateFormat('dd MMMM yyyy', 'es_ES').format(reportGroup.fecha);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: $fecha',
              style: TextStyle(
                  fontSize: isMobile ? 17 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
            const SizedBox(height: 5),
            const Divider(),
            ...reportGroup.informes.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.nombre,
                  style: TextStyle(
                      fontSize: isMobile ? 16 : 15,
                      fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.download, color: Colors.red[900], size: 25),
                  onPressed: () {
                    // Lógica para descargar usando item.archivoUrl
                    // Ejemplo: await launchUrl(Uri.parse(item.archivoUrl));
                    print('Descargando desde ${item.archivoUrl}...');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Iniciando descarga de ${item.nombre}...')),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
