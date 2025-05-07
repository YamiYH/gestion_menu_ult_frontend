import 'package:collection/collection.dart'; // Necesario para groupBy
import 'package:flutter/material.dart'; // Asegúrate que las rutas de importación sean correctas para TU proyecto
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/Confirm.dart';
import '../../widgets/UserTextFormField.dart';
import 'RecetaModelo.dart';

class LibroRecetas extends StatefulWidget {
  const LibroRecetas({super.key});

  @override
  State<LibroRecetas> createState() => _LibroRecetasState();
}

class _LibroRecetasState extends State<LibroRecetas> {
  // --- DATOS DE EJEMPLO ---
  // !!! Reemplaza con tu fuente de datos real !!!
  // !!! AÑADE UN 'id' ÚNICO a cada receta para borrado/edición robusta !!!
  final List<Map<String, dynamic>> recetas = [
    {'id': 1, 'nombre': 'Ensalada de acelga', 'categoria': 'Ensaladas'},
    {'id': 2, 'nombre': 'Ensalada de aguacate', 'categoria': 'Ensaladas'},
    {'id': 3, 'nombre': 'Arroz con Pollo', 'categoria': 'Arroces'},
    {'id': 4, 'nombre': 'Arroz blanco', 'categoria': 'Arroces'},
    {
      'id': 5,
      'nombre': 'Potaje de Frijoles Negros',
      'categoria': 'Sopas y Potajes'
    },
    {'id': 6, 'nombre': 'Ajiaco', 'categoria': 'Sopas y Potajes'},
    {'id': 7, 'nombre': 'Picadillo de Res', 'categoria': 'Carnes'},
    {'id': 8, 'nombre': 'Aporreado de pollo', 'categoria': 'Carnes'},
    {'id': 9, 'nombre': 'Pescado frito', 'categoria': 'Pescados'},
  ];

  // --------------------------

  List<String> _allCategories = [];

  // Mapa para la vista de acordeón (cuando no se busca)
  Map<String, List<Map<String, dynamic>>> _groupedRecetas = {};

  // Lista PLANA para los resultados de búsqueda (cuando SÍ se busca)
  List<Map<String, dynamic>> _filteredRecetas = [];

  final TextEditingController _searchController = TextEditingController();

  // Controlador para diálogo de categoría
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndGroup();
    _searchController.addListener(_applyFilters);
  }

  // Combina inicialización y primer agrupamiento
  void _initializeAndGroup() {
    // Extraer categorías únicas de las recetas fuente
    _allCategories = recetas
        .map((r) => r['categoria'] as String? ?? 'Sin Categoría')
        .toSet() // Obtiene valores únicos
        .toList()
      ..sort(); // Ordena alfabéticamente
    // Agrupa las recetas iniciales para la vista por defecto
    _groupAndSetRecetas(recetas);
    // La lista filtrada plana está vacía inicialmente
    _filteredRecetas = [];
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  // Agrupa una lista de recetas dada por categoría
  Map<String, List<Map<String, dynamic>>> _groupRecetasByCategory(
      List<Map<String, dynamic>> recetasList) {
    final groupedExisting = groupBy(recetasList,
        (Map receta) => receta['categoria'] as String? ?? 'Sin Categoría');
    final finalGroupedMap = <String, List<Map<String, dynamic>>>{};
    // Asegura que todas las categorías definidas estén en el mapa, incluso si están vacías
    for (String category in _allCategories) {
      finalGroupedMap[category] = groupedExisting[category] ?? [];
    }
    // Ordena el mapa resultante por nombre de categoría
    return Map.fromEntries(finalGroupedMap.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  void _groupAndSetRecetas(List<Map<String, dynamic>> recetasList) {
    _groupedRecetas = _groupRecetasByCategory(recetasList);
  }

  void _applyFilters() {
    final searchTerm = _searchController.text.trim().toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        _groupAndSetRecetas(recetas);
        _filteredRecetas = []; // Limpia la lista plana
      } else {
        _filteredRecetas = recetas.where((receta) {
          final nombre = receta['nombre'] as String? ?? '';
          return nombre
              .toLowerCase()
              .contains(searchTerm); // Busca solo por nombre
        }).toList();
      }
    });
  }

  void _handleDeleteRecipe(Map<String, dynamic> recetaToDelete) async {
    final idToDelete = recetaToDelete['id'] as int?;
    if (idToDelete == null) {
      print("Error: No se puede eliminar receta sin ID.");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: La receta no tiene un ID válido.')),
        );
      }
      return;
    }

    final String recetaName =
        recetaToDelete['nombre'] as String? ?? 'ID: $idToDelete';

    final bool? confirmed = await showConfirmDeleteDialog(
      context: context,
      itemName: recetaName, // Pasa el nombre de la receta
      itemType: 'la receta', // Pasa el tipo de ítem
      onConfirm: () {
        final initialLength = recetas.length;
        recetas.removeWhere(
            (r) => r['id'] == idToDelete); // Modifica la lista original
        final bool actuallyRemoved = recetas.length < initialLength;

        if (actuallyRemoved) {
          print(
              "Receta con ID $idToDelete marcada para eliminar de la lista principal.");
        } else {
          print(
              "Receta con ID $idToDelete no encontrada en la lista principal al intentar borrar.");
        }
      },
    );

    if (!mounted) return;
    if (confirmed == true) {
      print('Confirmada la eliminación de la receta: $recetaName');

      setState(() {
        _applyFilters();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receta "$recetaName" eliminada.')),
      );
    } else {
      // El usuario presionó CANCELAR o cerró el diálogo
      print('Eliminación cancelada para la receta: $recetaName');
    }
  }

  // --- Métodos para manejar categorías ---
  Future<void> _showAddEditCategoryDialog({String? existingCategory}) async {
    _categoryNameController.text = existingCategory ?? '';
    final isEditing = existingCategory != null;
    final formKey =
        GlobalKey<FormState>(); // Key para validar el form del diálogo

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isMobile = MediaQuery.of(context).size.width < 600;
        return AlertDialog(
          title: Center(
              child: Text(isEditing ? 'Editar Categoría' : 'Añadir Categoría')),
          content: Form(
            // Envuelve en Form para validación
            key: formKey,
            child: TextFormField(
              controller: _categoryNameController,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Nombre de la categoría'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                final potentialName = value.trim();
                // Comprueba duplicados (insensible a mayúsculas/minúsculas y diferente al original si edita)
                if (_allCategories.any((cat) =>
                    cat.toLowerCase() == potentialName.toLowerCase() &&
                    (!isEditing || cat != existingCategory))) {
                  return 'Esta categoría ya existe';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.grey[700], fontSize: 17)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[900]),
              child: Text(isEditing ? 'Guardar' : 'Añadir',
                  style: TextStyle(fontSize: 17)),
              onPressed: () {
                // Valida el formulario del diálogo ANTES de guardar
                if (formKey.currentState?.validate() ?? false) {
                  final newCategoryName = _categoryNameController.text.trim();
                  if (isEditing) {
                    _handleEditCategory(existingCategory!, newCategoryName);
                  } else {
                    _handleAddCategory(newCategoryName);
                  }
                  Navigator.of(context).pop(); // Cierra diálogo si es válido
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleAddCategory(String newCategoryName) {
    setState(() {
      _allCategories.add(newCategoryName);
      _allCategories.sort(); // Mantener ordenado
      // Vuelve a aplicar filtros/agrupación para reflejar la nueva categoría (vacía)
      _applyFilters();
    });
    print("Categoría añadida: $newCategoryName");
    // !!! Llama a tu backend para guardar la nueva categoría !!!
  }

  void _handleEditCategory(String oldCategoryName, String newCategoryName) {
    setState(() {
      // 1. Actualizar la lista de todas las categorías
      final index = _allCategories.indexOf(oldCategoryName);
      if (index != -1) {
        _allCategories[index] = newCategoryName;
        _allCategories.sort(); // Reordenar
      }
      // 2. Actualizar la categoría en la lista ORIGINAL de recetas
      for (var receta in recetas) {
        if (receta['categoria'] == oldCategoryName) {
          receta['categoria'] = newCategoryName;
        }
      }
      // 3. Vuelve a aplicar filtros/agrupación para reflejar el cambio
      _applyFilters();
    });
    print("Categoría editada: $oldCategoryName -> $newCategoryName");
    // !!! Llama a tu backend para guardar el cambio de categoría !!!
  }

  Future<void> _showDeleteCategoryConfirmationDialog(
      String categoryToDelete) async {
    // Verifica si la categoría contiene recetas ANTES de mostrar el diálogo
    final bool hasRecipes =
        recetas.any((receta) => receta['categoria'] == categoryToDelete);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isMobile = MediaQuery.of(context).size.width < 600;
        return AlertDialog(
          title: Center(child: Text('Eliminar Categoría')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '¿Seguro que desea eliminar la categoría "$categoryToDelete"?',
                    textAlign: TextAlign.center),
                if (hasRecipes) SizedBox(height: 15),
                if (hasRecipes)
                  Text(
                    'Advertencia: Esta categoría contiene recetas. Eliminarlas también o reasignarlas antes de borrar la categoría.',
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: isMobile ? 14 : 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Solo permitir eliminar si NO tiene recetas asociadas
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: hasRecipes ? Colors.grey : Colors.red[800]),
              // Deshabilita el botón si tiene recetas
              onPressed: hasRecipes
                  ? null
                  : () {
                      _handleDeleteCategory(categoryToDelete);
                      Navigator.of(context).pop();
                    },
              // Deshabilita visualmente si tiene recetas
              child: Text('Eliminar',
                  style: TextStyle(fontSize: isMobile ? 14 : 16)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteCategory(String categoryToDelete) {
    // Doble chequeo por seguridad
    final bool hasRecipes =
        recetas.any((receta) => receta['categoria'] == categoryToDelete);
    if (hasRecipes) return;

    setState(() {
      _allCategories.remove(categoryToDelete);
      // Volver a aplicar filtros/agrupación
      _applyFilters();
    });
    print("Categoría eliminada: $categoryToDelete");
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(title: 'Libro de Recetas'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    children: SearchAndAddButtons(
                        isMobile, context, _searchController))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: SearchAndAddButtons(
                        isMobile, context, _searchController)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: isSearching
                  ? _buildSearchResultsList() // <-- Muestra lista plana si busca
                  : _buildCategoryAccordionView(), // <-- Muestra acordeón si NO busca
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAccordionView() {
    final categoriesToShow = _allCategories;
    if (categoriesToShow.isEmpty) {
      return const Center(
          child: Text('No hay categorías. Añada una usando el botón (+).',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: categoriesToShow.length,
      itemBuilder: (context, index) {
        final String category = categoriesToShow[index];
        final List<Map<String, dynamic>> recetasInCategory =
            _groupedRecetas[category] ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: PageStorageKey(category),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            iconColor: Colors.red[700],
            collapsedIconColor: Colors.red[700],
            childrenPadding:
                const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                        fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey, size: 22),
                        tooltip: 'Editar Categoría',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showAddEditCategoryDialog(
                            existingCategory: category)),
                    SizedBox(width: 15),
                    IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red[700], size: 22),
                        tooltip: 'Eliminar Categoría',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            _showDeleteCategoryConfirmationDialog(category)),
                  ],
                )
              ],
            ),
            children: recetasInCategory.isEmpty
                ? [
                    const ListTile(
                        dense: true,
                        title: Center(
                            child: Text('No hay recetas en esta categoría.',
                                style: TextStyle(color: Colors.grey))))
                  ]
                : recetasInCategory.map((receta) {
                    return _buildRecetaCard(
                        receta, context, () => _handleDeleteRecipe(receta));
                  }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsList() {
    if (_filteredRecetas.isEmpty) {
      return Center(
          child: Text(
              'No se encontraron recetas para "${_searchController.text}".'));
    }

    return ListView.separated(
      itemCount: _filteredRecetas.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16), // Divisores
      itemBuilder: (context, index) {
        final receta = _filteredRecetas[index];
        return _buildRecetaCard(
          receta,
          context,
          () => _handleDeleteRecipe(receta),
        );
      },
    );
  }

  List<Widget> SearchAndAddButtons(bool isMobile, BuildContext context,
      TextEditingController searchController) {
    final searchField = SearchTextField(isMobile, context, searchController);
    final addRecipeButton = AddButton(
        onPressed: () {
          Navigator.push(context,
              createFadeRoute(RecetaModelo(isEditMode: true, receta: null)));
        },
        text: 'Receta',
        size: Size(isMobile ? 140 : 150, 45)); // Tamaño ligeramente ajustado
    final addCategoryButton = AddButton(
        onPressed: () {
          _showAddEditCategoryDialog();
        },
        text: 'Categoría',
        icon: Icon(Icons.add_circle_outline, size: 20),
        size: Size(isMobile ? 145 : 150, 45));

    if (isMobile) {
      return [
        searchField,
        SizedBox(height: 15),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [addRecipeButton, addCategoryButton])
      ];
    } else {
      return [
        searchField,
        SizedBox(width: 15),
        addRecipeButton,
        SizedBox(width: 10),
        addCategoryButton
      ];
    }
  }

  Widget SearchTextField(
      bool isMobile, BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: isMobile ? double.infinity : 200,
      height: 45,
      child: UserTextFormField(
        controller: controller,
        text: 'Buscar por plato',
      ),
    );
  }

  // Tarjeta para mostrar CADA receta (en acordeón o lista plana)
  Widget _buildRecetaCard(Map<String, dynamic> receta, BuildContext context,
      VoidCallback onDelete) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final String recetaName =
        receta['nombre'] as String? ?? 'Receta sin nombre';
    // Asume que tienes ID para editar/ver
    final int? recetaId = receta['id'] as int?;

    return ListTile(
      dense: true,
      // Más compacto
      contentPadding: EdgeInsets.only(left: isMobile ? 8 : 16.0, right: 0.0),
      // Menos padding derecho para acomodar botones
      title: Text(
        recetaName,
        style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blueGrey, size: 20),
            onPressed: recetaId == null
                ? null
                : () {
                    Navigator.push(
                        context,
                        createFadeRoute(
                            RecetaModelo(isEditMode: true, receta: receta)));
                  },
            tooltip: 'Editar Receta',
            padding: const EdgeInsets.all(4),
            // Padding reducido
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
            onPressed: recetaId == null
                ? null
                : () {
                    showConfirmDeleteDialog(
                      context: context,
                      itemName: recetaName,
                      itemType: 'la receta',
                      onConfirm: onDelete, // Llama al callback pasado
                    );
                  },
            tooltip: 'Eliminar Receta',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      onTap: recetaId == null
          ? null
          : () {
              Navigator.push(
                  context,
                  createFadeRoute(
                      RecetaModelo(isEditMode: false, receta: receta)));
            },
    );
  }
}
