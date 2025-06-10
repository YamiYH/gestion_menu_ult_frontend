// lib/screens/admin/Inventario.dart

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/InventoryController.dart';
import 'package:gestion_menu_ult_frontend/models/Inventory.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart'; // Importa tu widget de paginación refactorizado
import 'package:gestion_menu_ult_frontend/widgets/UserTextFormField.dart';

import '../../widgets/Button.dart';
import '../../widgets/NumField.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  _InventarioState createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final InventoryController _controller = InventoryController();
  bool _isLoading = true;
  List<Inventory> _products = [];

  // Controladores para los campos de texto de la UI
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Carga inicial de datos
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minQuantityController.dispose();
    _maxQuantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // Actualiza el controlador con los filtros de la UI ANTES de la llamada
    _controller.searchTerm = _searchController.text;
    _controller.minQuantity = double.tryParse(_minQuantityController.text);
    _controller.maxQuantity = double.tryParse(_maxQuantityController.text);

    try {
      final productsFromApi = await _controller.fetchProducts();
      setState(() {
        _products = productsFromApi;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar inventario: ${e.toString()}')),
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
    // Al buscar, siempre volvemos a la primera página
    _controller.currentPage = 0;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Inventario'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildFilterSection(isMobile),
          ),
          const SizedBox(height: 10),
          isMobile ? _buildHeaderRowMobile() : _buildHeaderRow(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            'No se encontraron productos con los filtros aplicados.'),
                      ))
                    : isMobile
                        ? _buildProductListMobile()
                        : _buildProductList(),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        currentPage: _controller.currentPage,
        totalPages: _controller.totalPages,
        itemsPerPage: _controller.pageSize,
        onPageChanged: (newPage) {
          if (_controller.currentPage != newPage) {
            setState(() {
              _controller.currentPage = newPage;
            });
            _fetchData();
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            setState(() {
              _controller.pageSize = newSize;
              _controller.currentPage = 0;
            });
            _fetchData();
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: _buildQuantityRange()),
              const SizedBox(height: 10),
              Button(
                  onPressed: _triggerSearch,
                  text: 'BUSCAR',
                  icon: Icons.search),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _buildSearchField()),
              const SizedBox(width: 20),
              SizedBox(width: 300, child: _buildQuantityRange()),
              const SizedBox(width: 20),
              Button(
                  onPressed: _triggerSearch,
                  text: 'BUSCAR',
                  icon: Icons.search),
            ],
          );
  }

  Widget _buildSearchField() {
    return UserTextFormField(
      text: 'Producto',
      controller: _searchController,
    );
  }

  Widget _buildQuantityRange() {
    return Row(
      children: [
        Expanded(
            child: NumField(
          controller: _minQuantityController,
          text: 'Cant.Mínima',
        )),
        const SizedBox(width: 5),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        const SizedBox(width: 5),
        Expanded(
            child: NumField(
          controller: _maxQuantityController,
          text: 'Cant.Máxima',
        )),
      ],
    );
  }

  Widget _buildHeaderRowMobile() {
    return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Expanded(flex: 4, child: Text('Producto', style: _headerStyle())),
            Expanded(flex: 3, child: Text('Existencia', style: _headerStyle())),
            Expanded(flex: 2, child: Text('U/M', style: _headerStyle())),
          ],
        ));
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(flex: 2, child: Text('Código', style: _headerStyle())),
          Expanded(flex: 3, child: Text('Producto', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Existencia', style: _headerStyle())),
          Expanded(flex: 1, child: Text('U/M', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Precio', style: _headerStyle())),
        ],
      ),
    );
  }

  Widget _buildProductListMobile() {
    return ListView.separated(
      itemCount: _products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                flex: 4,
                child: Text(product.description,
                    style: const TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 3,
                child: Text(product.existence.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 2,
                child: Text(product.measurementUnit,
                    style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return ListView.separated(
      itemCount: _products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                  flex: 2,
                  child:
                      Text(product.code, style: const TextStyle(fontSize: 16))),
              Expanded(
                  flex: 3,
                  child: Text(product.description,
                      style: const TextStyle(fontSize: 16))),
              Expanded(
                  flex: 2,
                  child: Text(product.existence.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16))),
              Expanded(
                  flex: 1,
                  child: Text(product.measurementUnit,
                      style: const TextStyle(fontSize: 16))),
              Expanded(
                  flex: 2,
                  child: Text("\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      },
    );
  }

  TextStyle _headerStyle() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red[900],
        fontSize: isMobile ? 13 : 16);
  }
}
