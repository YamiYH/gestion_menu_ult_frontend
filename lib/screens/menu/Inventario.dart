import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart';
import 'package:gestion_menu_ult_frontend/widgets/UserTextFormField.dart';

import '../../widgets/Button.dart';
import '../../widgets/NumField.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  _InventarioState createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  // Controladores para los campos de texto
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();

  // Variables para filtros
  String? _selectedCategory;

  List<Map<String, dynamic>> _filteredProducts = [];

  // Lista de productos con categorías y cantidades (simulada)
  final List<Map<String, dynamic>> _productos = [
    {
      'code': '001',
      'name': 'Arroz',
      'category': 'Carbohidratos',
      'quantity': 150,
      'unit': 'kg'
    },
    {
      'code': '002',
      'name': 'Res',
      'category': 'Carnes',
      'quantity': 80,
      'unit': 'kg'
    },
    {
      'code': '003',
      'name': 'Cerdo',
      'category': 'Carnes',
      'quantity': 60,
      'unit': 'kg'
    },
    {
      'code': '004',
      'name': 'Espagueti',
      'category': 'Carbohidratos',
      'quantity': 120,
      'unit': 'Kg'
    },
    {
      'code': '005',
      'name': 'Plátano',
      'category': 'Viandas',
      'quantity': 200,
      'unit': 'Lb'
    },
    {
      'code': '006',
      'name': 'Yuca',
      'category': 'Viandas',
      'quantity': 90,
      'unit': 'Lb'
    },
    {
      'code': '007',
      'name': 'Pepino',
      'category': 'Vegetales',
      'quantity': 150,
      'unit': 'Lb'
    },
    {
      'code': '008',
      'name': 'Tomate',
      'category': 'Vegetales',
      'quantity': 75,
      'unit': 'Lb'
    },
    {
      'code': '009',
      'name': 'Lechuga',
      'category': 'Vegetales',
      'quantity': 40,
      'unit': 'Lb'
    },
    {
      'code': '010',
      'name': 'Ají',
      'category': 'Especias',
      'quantity': 30,
      'unit': 'Kg'
    },
    {
      'code': '011',
      'name': 'Cebolla',
      'category': 'Vegetales',
      'quantity': 100,
      'unit': 'Lb'
    },
    {
      'code': '012',
      'name': 'Ajo',
      'category': 'Especias',
      'quantity': 25,
      'unit': 'Lb'
    },
  ];

  // Lista de categorías
  final List<String> _categorias = [
    'Seleccione categoría', // Placeholder
    'Carnes',
    'Viandas',
    'Vegetales',
    'Especias',
    'Carbohidratos',
    'Refrescos'
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Inventario'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  // Filtros responsivos
                  _buildFilterSection(isMobile),
            ),
            const SizedBox(height: 20),
            // Encabezados de la lista
            _buildHeaderRow(isMobile),
            const SizedBox(height: 10),
            // Lista de productos
            _buildProductList(isMobile),
          ],
        ),
      ),
      bottomNavigationBar: Pagination(
        itemBuilder: (context, item) {
          return ListTile(
            title: Text(item as String),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_productos); // Mostrar todos por defecto
    _selectedCategory = _categorias.first; // Inicializar con el placeholder
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minQuantityController.dispose();
    _maxQuantityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _productos.where((product) {
        // Filtro por nombre: Si el campo está vacío, nameMatch es true.
        final nameMatch = _searchController.text.isEmpty ||
            product['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // Filtro por categoría: Si está en "Seleccione categoría", categoryMatch es true.
        final categoryMatch = _selectedCategory == 'Seleccione categoría' ||
            product['category'] == _selectedCategory;

        // Filtro por cantidad: Si los campos min/max están vacíos, quantityMatch es true.
        final minQtyText = _minQuantityController.text;
        final maxQtyText = _maxQuantityController.text;
        final quantity = product['quantity'] as num;
        final quantityMatch = (minQtyText.isEmpty && maxQtyText.isEmpty)
            ? true
            : (num.tryParse(minQtyText) ?? 0) <= quantity &&
                quantity <= (num.tryParse(maxQtyText) ?? double.infinity);

        // El producto se incluye si CUMPLE TODOS los filtros activos.
        // Si un filtro no se especificó (campo vacío, categoría placeholder),
        // su respectiva variable (nameMatch, categoryMatch, quantityMatch) será `true`
        // y no impedirá que el producto se muestre.
        return nameMatch && categoryMatch && quantityMatch;
      }).toList();
    });
  }

  // Sección de filtros (adaptativa)
  Widget _buildFilterSection(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildCategoryDropdown(isMobile),
              const SizedBox(height: 20),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: _buildQuantityRange()),
              const SizedBox(height: 20),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _buildSearchField()),
              const SizedBox(width: 20),
              SizedBox(width: 300, child: _buildCategoryDropdown(isMobile)),
              const SizedBox(width: 20),
              SizedBox(width: 300, child: _buildQuantityRange()),
              const SizedBox(width: 20),
              Button(
                  onPressed: () {
                    _applyFilters();
                  },
                  text: 'BUSCAR',
                  icon: Icons.search),
            ],
          );
  }

  // Campo de búsqueda por nombre
  Widget _buildSearchField() {
    return UserTextFormField(
      text: 'Producto',
      controller: _searchController,
      onChanged: (value) {
        _applyFilters();
      },
    );
  }

  // Dropdown de categorías
  Widget _buildCategoryDropdown(isMobile) {
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.90
          : MediaQuery.of(context).size.width * 0.14,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.07
          : MediaQuery.of(context).size.height * 0.10,
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          //labelText: 'Categoría',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        items: _categorias
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  // Rango de cantidad
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

  // Encabezados de la tabla
  Widget _buildHeaderRow(bool isMobile) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: isMobile
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text('Producto', style: _headerStyle())),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text('Cantidad', style: _headerStyle())),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text('Unidad', style: _headerStyle())),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 100, child: Text('Código', style: _headerStyle())),
                  SizedBox(
                      width: 200,
                      child: Text('Producto', style: _headerStyle())),
                  SizedBox(
                      width: 210,
                      child: Text('Categoría', style: _headerStyle())),
                  SizedBox(
                      width: 90,
                      child: Text('Cantidad', style: _headerStyle())),
                  SizedBox(
                      width: 90, child: Text('Unidad', style: _headerStyle())),
                ],
              ),
      ),
    );
  }

// Lista de productos con encabezados
  Widget _buildProductList(bool isMobile) {
    return Column(
      children: [
        if (_filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No hay productos disponibles')),
          )
        else
          ..._filteredProducts.map((product) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: isMobile
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  product['name'],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  product['quantity'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  product['unit'] ?? 'N/A',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              //Divider(),
                            ],
                          ),
                          Divider()
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    product['code'] ?? 'N/A',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    product['name'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    product['category'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    product['quantity'].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    product['unit'] ?? 'N/A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // Estilo para encabezados
  TextStyle _headerStyle() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red[900],
        fontSize: isMobile ? 13 : 16);
  }
}
