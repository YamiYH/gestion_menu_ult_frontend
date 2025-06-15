// lib/screens/admin/Inventario.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/inventory/InventoryController.dart';
import 'package:gestion_menu_ult_frontend/models/Inventory.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart'; // Importa tu widget de paginación refactorizado
import 'package:gestion_menu_ult_frontend/widgets/UserTextFormField.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  _InventarioState createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final InventoryController _controller = InventoryController();
  bool _isLoading = true;
  List<Inventory> _products = [];
  Timer? _debounce;

  // Controladores para los campos de texto de la UI
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData(_searchController.text);

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _triggerSearch();
    });
  }

  Future<void> _fetchData(String filter) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    Map<String, String> filters = {
      'description': filter,
    };
    _controller.searchTerm = _searchController.text;

    try {
      final productsFromApi = await _controller.fetchProducts(filters: filters);
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
    _controller.currentPage = 0;
    _fetchData(_searchController.text);
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
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.red,
                  ))
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
            _fetchData(_searchController.text);
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            setState(() {
              _controller.pageSize = newSize;
              _controller.currentPage = 0;
            });
            _fetchData(_searchController.text);
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              const SizedBox(height: 10),
              _buildSearchField(),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _buildSearchField()),
              const SizedBox(width: 20),
            ],
          );
  }

  Widget _buildSearchField() {
    return UserTextFormField(
      text: 'Buscar producto',
      controller: _searchController,
    );
  }

  Widget _buildHeaderRowMobile() {
    return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            _header('Producto', 0.48),
            _header('Existencia', 0.26),
            _header('U/M', 0.1),
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
          _header('Código', 0.2),
          _header('Producto', 0.2),
          _header('Existencia', 0.2),
          _header('U/M', 0.1),
          _header('Precio', 0.1),
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
              _listStyle(product.description, 0.5),
              _listStyle(product.existence.toStringAsFixed(2), 0.21),
              _listStyle(product.measurementUnit, 0.2),
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
              _listStyle(product.code, 0.2),
              _listStyle(product.description, 0.4),
              _listStyle(product.existence.toStringAsFixed(2), 0.2),
              _listStyle(product.measurementUnit, 0.1),
              _listStyle("\$${product.price.toStringAsFixed(2)}", 0.1),
            ],
          ),
        );
      },
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
        fontWeight: FontWeight.bold, color: Colors.red[900], fontSize: 16);
  }

  Widget _listStyle(String title, widthFactor) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        child: Text(title, style: TextStyle(fontSize: 15)));
  }

  Widget _header(String title, double widthFactor) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        child: Text(
          title,
          style: _headerStyle(),
        ));
  }
}
