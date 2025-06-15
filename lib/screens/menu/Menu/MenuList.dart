import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/menu/MenuController.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Menu/MenuPropuesta.dart';

import '../../../routes/PageRouteBuilder.dart';
import '../../../widgets/Button.dart';
import '../../../widgets/Confirm.dart';
import '../../../widgets/CustomAppbar.dart';
import '../../../widgets/Pagination.dart';

class MenuList extends StatefulWidget {
  @override
  State<MenuList> createState() => _MenuListState();
}

enum MenuStatus { propuesto, aprobado, rechazado, enVenta }

class _MenuListState extends State<MenuList> {
  List<MenuEntity> _displayedMenus = [];
  bool _isLoading = true;
  bool _isSaving = true;
  String? _errorMessage;
  List<String> _allCategories = [];
  List<String> _allTypes = [];
  List<String> _allStatus = [];
  String _selectedCategory = 'Todas';
  String _selectedType = 'Todos';
  String _selectedStatus = 'Todos';
  MenuEntityController _menuEntityController = MenuEntityController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _fetchCategories(),
        _fetchStatus(),
        _fetchTypes(),
        _fetchMenus(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar datos: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToMenuProposal({MenuEntity? menu}) async {
    final result = await Navigator.push(
      context,
      createFadeRoute(MenuPropuesta(menu: menu)),
    );

    if (result == true && mounted) {
      _fetchMenus();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _menuEntityController.fetchMenuCategories();
      if (mounted) {
        setState(() {
          _allCategories = ['Todas', ...categories];
        });
      }
    } catch (e) {
      debugPrint("No se pudieron cargar las categorías: $e");
      if (mounted) setState(() => _allCategories = ['Todas']);
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await _menuEntityController.fetchMenuStatus();
      if (mounted) {
        setState(() {
          _allStatus = ['Todos', ...status];
        });
      }
    } catch (e) {
      debugPrint("No se pudieron cargar las categorías: $e");
      if (mounted) setState(() => _allStatus = ['Todos']);
    }
  }

  Future<void> _fetchTypes() async {
    try {
      final types = await _menuEntityController.fetchMenuTypes();
      if (mounted) {
        setState(() {
          _allTypes = ['Todos', ...types];
        });
      }
    } catch (e) {
      debugPrint("No se pudieron cargar las categorías: $e");
      if (mounted) setState(() => _allTypes = ['Todos']);
    }
  }

  Future<void> _fetchMenus() async {
    if (!_isLoading) setState(() => _isLoading = true);

    final categoryToFilter = _selectedCategory;
    final statusToFilter = _selectedStatus;
    final typeToFilter = _selectedType;

    final filters = <String, String>{};

    if (categoryToFilter != 'Todas') {
      filters['category'] = categoryToFilter;
    }
    if (statusToFilter != 'Todos') {
      filters['status'] = statusToFilter;
    }
    if (typeToFilter != 'Todos') {
      filters['type'] = typeToFilter;
    }

    try {
      final menus = await _menuEntityController.fetchMenu(filters: filters);
      if (mounted) {
        setState(() {
          _displayedMenus = menus;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al buscar menus: ${e.toString()}";
          _displayedMenus = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteMenu(String menuId) async {
    try {
      await _menuEntityController.deleteMenu(menuId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta eliminada con éxito.')),
        );
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null && newValue != _selectedCategory) {
      setState(() {
        _selectedCategory = newValue;
        _menuEntityController.currentPage = 0;
      });
      _fetchMenus();
    }
  }

  void _handleTypeChanged(String? newValue) {
    if (newValue != null && newValue != _selectedCategory) {
      setState(() {
        _selectedType = newValue;
        _menuEntityController.currentPage = 0;
      });
      _fetchMenus();
    }
  }

  void _handleStatusChanged(String? newValue) {
    if (newValue != null && newValue != _selectedCategory) {
      setState(() {
        _selectedStatus = newValue;
        _menuEntityController.currentPage = 0;
      });

      _fetchMenus();
    }
  }

  Widget _buildMenuList() {
    return ListView.builder(
      itemCount: _displayedMenus.length,
      itemBuilder: (context, index) {
        final menu = _displayedMenus[index];
        return _buildMenuCard(menu);
      },
    );
  }

  Widget _buildMenuCard(MenuEntity menu) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'Menú de ${menu.category}',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${menu.type} (${menu.date})',
                          style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: menu.status == 'Propuesto' ||
                              menu.status == 'Rechazado'
                          ? 'Editar menú'
                          : 'Este menú no se puede editar',
                      child: IconButton(
                        icon: Icon(Icons.edit,
                            color: menu.status == 'Propuesto' ||
                                    menu.status == 'Rechazado'
                                ? Colors.blueAccent
                                : Colors.grey),
                        onPressed: menu.status == 'Propuesto' ||
                                menu.status == 'Rechazado'
                            ? () {
                                _navigateToMenuProposal(menu: menu);
                              }
                            : null,
                      ),
                    ),
                    Tooltip(
                      message: menu.status == 'Propuesto' ||
                              menu.status == 'Rechazado'
                          ? 'Eliminar menú'
                          : 'Este menú no se puede eliminar',
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: menu.status == 'Propuesto' ||
                                  menu.status == 'Rechazado'
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: menu.status == 'Propuesto' ||
                                menu.status == 'Rechazado'
                            ? () {
                                if (menu.id != null) {
                                  showConfirmDeleteDialog(
                                    context: context,
                                    itemName: menu.date,
                                    itemType: 'el menú',
                                    onConfirm: () =>
                                        _handleDeleteMenu(menu.id as String),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 20),
                    _buildStatusChip(menu.status),
                    SizedBox(width: 20)
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Platos:',
                        style: TextStyle(
                            fontSize: isMobile ? 16 : 17,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...menu.recipes.map((recipe) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: isMobile ? 18 : 20,
                                color: Colors.red[700]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '- ${recipe.name}',
                                  style:
                                      TextStyle(fontSize: isMobile ? 15 : 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '\$ ${recipe.price}',
                              style: TextStyle(
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Precio Total: \$ ${menu.totalPrice}',
                        style: TextStyle(
                            fontSize: isMobile ? 15 : 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'Menú de ${menu.category}',
                          style: TextStyle(
                              fontSize: isMobile ? 14 : 17,
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${menu.type} (${menu.date})',
                          style: TextStyle(
                              fontSize: isMobile ? 13 : 16,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: menu.status == 'Propuesto' ||
                              menu.status == 'Rechazado'
                          ? 'Editar menú'
                          : 'Este menú no se puede editar',
                      child: IconButton(
                        icon: Icon(Icons.edit,
                            color: menu.status == 'Propuesto' ||
                                    menu.status == 'Rechazado'
                                ? Colors.blueAccent
                                : Colors.grey),
                        onPressed: menu.status == 'Propuesto' ||
                                menu.status == 'Rechazado'
                            ? () {
                                _navigateToMenuProposal(menu: menu);
                              }
                            : null,
                      ),
                    ),
                    Tooltip(
                      message: menu.status == 'Propuesto' ||
                              menu.status == 'Rechazado'
                          ? 'Eliminar menú'
                          : 'Este menú no se puede eliminar',
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: menu.status == 'Propuesto' ||
                                  menu.status == 'Rechazado'
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: menu.status == 'Propuesto' ||
                                menu.status == 'Rechazado'
                            ? () {
                                if (menu.id != null) {
                                  showConfirmDeleteDialog(
                                    context: context,
                                    itemName: menu.date,
                                    itemType: 'el menú',
                                    onConfirm: () =>
                                        _handleDeleteMenu(menu.id as String),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                    SizedBox(width: 20),
                    _buildStatusChip(menu.status),
                    SizedBox(width: 20)
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Platos:',
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 17,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...menu.recipes.map((recipe) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: isMobile ? 16 : 20,
                                color: Colors.red[700]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '- ${recipe.name}',
                                  style:
                                      TextStyle(fontSize: isMobile ? 13 : 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '\$ ${recipe.price}',
                              style: TextStyle(
                                  fontSize: isMobile ? 13 : 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Precio Total: \$ ${menu.totalPrice}',
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
        appBar: CustomAppBar(title: 'Lista de Menús'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: isMobile
                    ? _buildMobileHeader(isMobile)
                    : _buildDesktopHeader(isMobile),
              ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Pagination(
          currentPage: _menuEntityController.currentPage,
          totalPages: _menuEntityController.totalPages,
          itemsPerPage: _menuEntityController.pageSize,
          onPageChanged: (newPage) {
            if (_menuEntityController.currentPage != newPage) {
              _menuEntityController.currentPage = newPage;
              _loadInitialData();
            }
          },
          onItemsPerPageChanged: (newSize) {
            if (_menuEntityController.pageSize != newSize) {
              _menuEntityController.pageSize = newSize;
              _menuEntityController.currentPage = 0;
              _loadInitialData();
            }
          },
        ));
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.red,
      ));
    }
    if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_displayedMenus.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron menús con los filtros aplicados.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return _buildMenuList();
  }

  Widget _buildMobileHeader(isMobile) {
    return Column(
      children: [
        _buildCategoryDropdown(),
        SizedBox(height: 15),
        _buildStatusDropdown(),
        SizedBox(height: 15),
        _buildTypeDropdown()
      ],
    );
  }

  Widget _buildDesktopHeader(isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 16),
        _buildHeader(_buildCategoryDropdown()),
        const SizedBox(width: 16),
        _buildHeader(_buildStatusDropdown()),
        const SizedBox(width: 16),
        _buildHeader(_buildTypeDropdown()),
        _buildNavigationButton(isMobile),
      ],
    );
  }

  Padding _buildNavigationButton(isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Button(
        icon: Icons.replay,
        onPressed: () =>
            Navigator.push(context, createFadeRoute(MenuPropuesta())),
        text: "Volver",
        colorButton: Colors.blue,
        size: Size(isMobile ? 320 : 160, 50),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey[600] ?? Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      ),
      items: _allCategories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: _handleCategoryChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey[600] ?? Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      ),
      items: _allStatus.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: _handleStatusChanged,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey[600] ?? Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      ),
      items: _allTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: _handleTypeChanged,
    );
  }

  Widget _buildStatusChip(String status) {
    Color? color;
    String? label;
    IconData? icon;
    switch (status) {
      case 'Propuesto':
        color = Colors.blue;
        label = 'Propuesto';
        icon = Icons.hourglass_top;
        break;
      case 'Aprobado':
        color = Colors.green;
        label = 'Aprobado';
        icon = Icons.check_circle;
        break;
      case 'Rechazado':
        color = Colors.red;
        label = 'Rechazado';
        icon = Icons.cancel;
        break;
      case 'Venta':
        color = Colors.orange;
        label = 'En Venta';
        icon = Icons.point_of_sale;
        break;
      case 'Vendido':
        color = Colors.grey;
        label = 'Vendido';
        icon = Icons.receipt;
        break;
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(label!,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildHeader(Widget child) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.2, child: child);
  }
}
