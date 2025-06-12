import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/RecipeController.dart';
import 'package:gestion_menu_ult_frontend/models/Recipe.dart'; // Importa tu modelo
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart';

import '../../widgets/Confirm.dart';
import '../../widgets/CustomTextFormField.dart';
import 'RecetaModelo.dart';

class LibroRecetas extends StatefulWidget {
  const LibroRecetas({super.key});

  @override
  State<LibroRecetas> createState() => _LibroRecetasState();
}

class _LibroRecetasState extends State<LibroRecetas> {
  final RecipeController _recipeController = RecipeController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Datos y estado de la UI
  bool _isLoading = true;
  bool _isSaving = true;
  String? _errorMessage;
  List<Recipe> _displayedRecetas = [];
  List<String> _allCategories = [];
  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
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
        _fetchRecipes(),
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

  Future<void> _fetchCategories() async {
    try {
      final categories = await _recipeController.fetchCategories();
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

  Future<void> _fetchRecipes({String? category}) async {
    if (!_isLoading) setState(() => _isLoading = true);

    final categoryToFilter = category ?? _selectedCategory;

    final filters = <String, String>{};
    if (_searchController.text.isNotEmpty) {
      filters['name'] = _searchController.text;
    }
    if (categoryToFilter != 'Todas') {
      filters['category'] = categoryToFilter;
    }

    try {
      final recipes = await _recipeController.fetchRecipe(filters: filters);
      if (mounted) {
        setState(() {
          _displayedRecetas = recipes;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al buscar recetas: ${e.toString()}";
          _displayedRecetas = [];
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _recipeController.currentPage = 0;
      _fetchRecipes();
    });
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null && newValue != _selectedCategory) {
      setState(() {
        _selectedCategory = newValue;
        _recipeController.currentPage = 0;
      });
      // Se llama a fetchRecipes con el nuevo valor para garantizar que el filtro se aplique inmediatamente.
      _fetchRecipes(category: newValue);
    }
  }

  void _onPageChanged(int newPage) {
    if (_recipeController.currentPage != newPage) {
      setState(() {
        _recipeController.currentPage = newPage;
      });
      _fetchRecipes();
    }
  }

  Future<void> _handleDeleteRecipe(String recipeId) async {
    try {
      await _recipeController.deleteRecipe(recipeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta eliminada con éxito.')),
        );
        _fetchRecipes();
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

  Future<void> _navigateToRecipeForm({Recipe? receta}) async {
    // Usa 'await' para esperar a que la pantalla RecetaModelo se cierre
    final result = await Navigator.push(
      context,
      createFadeRoute(RecetaModelo(
        // Si no hay receta, es para crear, por lo tanto isEditMode es true
        isEditMode: true,
        receta: receta,
      )),
    );

    // Si `RecetaModelo` devolvió `true`, significa que se guardó algo
    if (result == true && mounted) {
      // Recarga los datos para reflejar los cambios (creación o edición)
      _fetchRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
        appBar: CustomAppBar(title: 'Libro de Recetas'),
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
          currentPage: _recipeController.currentPage,
          totalPages: _recipeController.totalPages,
          itemsPerPage: _recipeController.pageSize,
          onPageChanged: (newPage) {
            if (_recipeController.currentPage != newPage) {
              _recipeController.currentPage = newPage;
              _loadInitialData();
            }
          },
          onItemsPerPageChanged: (newSize) {
            if (_recipeController.pageSize != newSize) {
              _recipeController.pageSize = newSize;
              _recipeController.currentPage = 0;
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
    if (_displayedRecetas.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron recetas con los filtros aplicados.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return _buildRecipeList();
  }

  Widget _buildMobileHeader(isMobile) {
    return Column(
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildCategoryDropdown(),
        const SizedBox(height: 16),
        AddButton(
          size: Size(isMobile ? 140 : 150, 45),
          onPressed: () => _navigateToRecipeForm(),
          text: 'Añadir Receta',
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: _buildSearchField()),
        const SizedBox(width: 16),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: _buildCategoryDropdown()),
        const SizedBox(width: 16),
        AddButton(
          size: Size(isMobile ? 140 : 150, 50),
          onPressed: () => _navigateToRecipeForm(),
          text: 'Receta',
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return CustomTextFormField(
      controller: _searchController,
      labelText: 'Buscar por nombre',
      prefixIcon: const Icon(Icons.search),
    );
  }

  // *** WIDGET REFACTORIZADO PARA CARGAR DATOS ASÍNCRONAMENTE ***
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

  Widget _buildRecipeList() {
    return ListView.builder(
      itemCount: _displayedRecetas.length,
      itemBuilder: (context, index) {
        final receta = _displayedRecetas[index];
        return _buildRecipeCard(receta);
      },
    );
  }

  Widget _buildRecipeCard(Recipe receta) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
        title: Text(receta.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 22),
              tooltip: 'Editar Receta',
              onPressed: () => _navigateToRecipeForm(receta: receta),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade700, size: 22),
              tooltip: 'Eliminar Receta',
              onPressed: () {
                showConfirmDeleteDialog(
                  context: context,
                  itemName: receta.name,
                  itemType: 'la receta',
                  onConfirm: () => _handleDeleteRecipe(receta.id),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(context,
              createFadeRoute(RecetaModelo(isEditMode: false, receta: receta)));
        },
      ),
    );
  }
}
