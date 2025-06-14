import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/menu/RecipeController.dart';
import 'package:gestion_menu_ult_frontend/models/Recipe.dart'; // Importa tu modelo
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import 'Ventas.dart';

class MenuVentas extends StatefulWidget {
  const MenuVentas({super.key});

  @override
  State<MenuVentas> createState() => _MenuVentasState();
}

class _MenuVentasState extends State<MenuVentas> {
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

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: CustomAppBar(title: 'Menús a vender'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Menús listos para la venta:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
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
          'No se encontraron menús para la venta',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return _buildRecipeList();
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
        onTap: () {
          Navigator.push(context, createFadeRoute(Ventas()));
        },
      ),
    );
  }
}
