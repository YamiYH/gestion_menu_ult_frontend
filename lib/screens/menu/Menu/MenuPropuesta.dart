import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
import 'package:gestion_menu_ult_frontend/models/Recipe.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';

import '../../../controllers/menu/MenuController.dart';
import '../../../controllers/menu/RecipeController.dart';
import '../../../widgets/AddButton.dart';
import '../../../widgets/Button.dart';
import '../../../widgets/CustomAppbar.dart';
import '../../../widgets/CustomTextFormField.dart';
import '../../../widgets/Date.dart';
import 'MenuList.dart';

// --- MODELO AUXILIAR ---
class RecipeItem {
  final TextEditingController controller;
  String? selectedRecipe;
  String? selectedRecipeId;

  RecipeItem(
      {this.selectedRecipe, this.selectedRecipeId, required this.controller});

  dispose() {
    controller.dispose();
  }
}

// --- WIDGET PRINCIPAL ---
class MenuPropuesta extends StatefulWidget {
  final MenuEntity? menu;

  const MenuPropuesta({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<MenuPropuesta> createState() => _MenuPropuestaState();
}

class _MenuPropuestaState extends State<MenuPropuesta> {
  // --- ESTADO Y CONTROLADORES ---
  final RecipeController _recipeController = RecipeController();
  final MenuEntityController _menuController = MenuEntityController();

  String? selectedMealType = 'Almuerzo';
  DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));
  bool isEstudiantesEnabled = true;
  bool isTrabajadoresEnabled = true;
  bool isMenuProposed = false;

  List<RecipeItem> _studentMenuItems = [];
  List<RecipeItem> _workerMenuItems = [];
  List<Recipe> _availableRecipes = [];
  bool _isLoadingRecipes = true;

  Future<void> _initializeControllers() async {
    if (widget.menu == null) {
    } else {
      final r = widget.menu;
      List<RecipeItem> recipeRows = [];
      if (r?.recipes != null) {
        recipeRows = r!.recipes.map((ing) {
          return RecipeItem(
            // Se asume que el ID del ingrediente es el ID del producto.
            // Si el ID del ingrediente es diferente, necesitarías pasarlo por separado.
            selectedRecipeId: ing.id,
            selectedRecipe: ing.name,
            controller: TextEditingController(text: ing.name),
          );
        }).toList();
        if (r.category == 'Estudiantes') {
          _studentMenuItems = recipeRows;
        } else if (r.category == 'Trabajadores') {
          _workerMenuItems = recipeRows;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuRecipe();
    _initializeControllers();
  }

  @override
  void dispose() {
    // Limpiamos los controladores para evitar fugas de memoria
    for (var item in _studentMenuItems) {
      item.controller.dispose();
    }
    for (var item in _workerMenuItems) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMenuRecipe() async {
    setState(() {
      _isLoadingRecipes = true;
    });
    try {
      final recipe = await _recipeController.fetchAllRecipe();
      if (mounted) {
        setState(() {
          _availableRecipes = recipe;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar recetas: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar recetas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecipes = false;
        });
      }
    }
  }

  void _addMenuItem(RecipeItem recipe, {required bool isEstudiantes}) {
    setState(() {
      if (isEstudiantes) {
        _studentMenuItems.add(recipe);
      } else {
        _workerMenuItems.add(recipe);
      }
    });
  }

  void _removeMenuItem({required bool isEstudiantes, required int index}) {
    setState(() {
      if (isEstudiantes) {
        _studentMenuItems[index].controller.dispose();
        _studentMenuItems.removeAt(index);
      } else {
        _workerMenuItems[index].controller.dispose();
        _workerMenuItems.removeAt(index);
      }
    });
  }

  void _resetForm() async {
    for (var item in _studentMenuItems) {
      item.controller.dispose();
    }
    for (var item in _workerMenuItems) {
      item.controller.dispose();
    }
    setState(() {
      _studentMenuItems = [];
      _workerMenuItems = [];
    });
  }

  Future<bool> _isCurrentProposalMade(bool isStudent) async {
    if (widget.menu == null) {
      if (isStudent) {
        return await _menuController.isMenuProposal(
            selectedDate!.toIso8601String().split('T').first,
            "Estudiantes",
            selectedMealType!);
      } else {
        return await _menuController.isMenuProposal(
            selectedDate!.toIso8601String().split('T').first,
            "Trabajadores",
            selectedMealType!);
      }
    }
    return false;
  }

  Future<void> _proposeMenu() async {
    if (_isLoadingRecipes) return;

    setState(() {
      _isLoadingRecipes = true;
    });

    try {
      final String date = selectedDate!.toIso8601String().split('T').first;
      bool atLeastOneSuccess = false;

      if (_studentMenuItems.isNotEmpty) {
        final success = await _processMenuCategory(
          category: 'Estudiantes',
          menuItems: _studentMenuItems,
          date: date,
          isStudentCategory: true,
        );

        if (success) atLeastOneSuccess = true;
      }

      if (_workerMenuItems.isNotEmpty) {
        final success = await _processMenuCategory(
          category: 'Trabajadores',
          menuItems: _workerMenuItems,
          date: date,
          isStudentCategory: false,
        );

        if (success) atLeastOneSuccess = true;
      }

      if (atLeastOneSuccess && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.push(context, createFadeRoute(MenuList()));
      }
    } catch (e) {
      _showSnackBar('Ocurrió un error inesperado: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecipes = false;
        });
      }
    }
  }

  Future<bool> _processMenuCategory({
    required String category,
    required List<RecipeItem> menuItems,
    required String date,
    required bool isStudentCategory,
  }) async {
    if (menuItems.isEmpty) {
      return false;
    }

    if (await _isCurrentProposalMade(isStudentCategory)) {
      print("$category verdadero");
      _showSnackBar('Ya se ha propuesto un menú de $category para esta fecha.',
          isError: true);
      return false;
    }

    final recipes = menuItems
        .where((item) => item.selectedRecipeId != null)
        .map((item) => MenuRecipe(id: item.selectedRecipeId))
        .toList();

    if (recipes.isEmpty) {
      return true;
    }

    final menu = MenuEntity(
      category: category,
      date: date,
      recipes: recipes,
      status: 'Propuesto',
      type: selectedMealType!,
    );

    await _menuController.createMenu(menu.toJson());
    _showSnackBar('Propuesta de menú de $category enviada con éxito.');
    return true; // Éxito
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        bool isMobile = MediaQuery.of(context).size.width < 600;
        return AlertDialog(
          title: const Center(child: Text('Confirmar Propuesta')),
          content: const SingleChildScrollView(
              child: ListBody(children: <Widget>[
            Text('¿Está seguro de que desea proponer este menú?'),
            Text('Una vez propuesto, no podrá editarlo en esta pantalla.')
          ])),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: isMobile ? 16 : 18)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirmar',
                  style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 18)),
              onPressed: () {
                _proposeMenu();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: isMobile ? 'Propuestas' : 'Propuestas de Menú',
        ),
        body: _buildProposalView(isMobile),
      ),
    );
  }

  Widget _buildProposalView(bool isMobile) {
    final bool isMenuView = widget.menu != null;

    // Si hay menú, usa sus datos
    final String? menuMealType =
        isMenuView ? widget.menu!.type : selectedMealType;
    final DateTime? menuDate =
        isMenuView ? DateTime.tryParse(widget.menu!.date) : selectedDate;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 15),
            isMobile
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 58,
                            child: isMenuView
                                ? InputDecorator(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                    child: Text(
                                      menuMealType ?? '',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  )
                                : FoodDropDown(selectedMealType, (newValue) {
                                    setState(() => selectedMealType = newValue);
                                    _resetForm();
                                  }, isMobile),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: isMenuView
                                ? InputDecorator(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                    child: Text(
                                      menuDate != null
                                          ? "${menuDate.day.toString().padLeft(2, '0')}/${menuDate.month.toString().padLeft(2, '0')}/${menuDate.year}"
                                          : '',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  )
                                : DateWidget(
                                    selectedDate: selectedDate,
                                    onDateSelected: (date) {
                                      setState(() => selectedDate = date);
                                      _resetForm();
                                    },
                                    size: MediaQuery.of(context).size.width *
                                        0.45,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Button(
                        onPressed: isMenuView || _isLoadingRecipes
                            ? null
                            : () => _showConfirmationDialog(),
                        text: isMenuView ? 'Propuesto' : 'Proponer',
                        colorButton: (isMenuView || _isLoadingRecipes)
                            ? Colors.grey
                            : null,
                        size: Size(isMobile ? 340 : 180, isMobile ? 60 : 50),
                      ),
                      SizedBox(height: isMobile ? 30 : 40),
                      if (_isLoadingRecipes)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              SizedBox(height: 100),
                              CircularProgressIndicator(
                                color: Colors.red,
                              ),
                              SizedBox(height: 10),
                              Text("Cargando platos..."),
                            ],
                          ),
                        )),
                      if (!_isLoadingRecipes)
                        Column(children: _buildMenuCards(isMobile)),
                      const SizedBox(height: 20)
                    ],
                  )
                : Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: isMenuView
                                  ? InputDecorator(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none),
                                      ),
                                      child: Text(
                                        menuMealType ?? '',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    )
                                  : FoodDropDown(selectedMealType, (newValue) {
                                      setState(
                                          () => selectedMealType = newValue);
                                      _resetForm();
                                    }, isMobile),
                            ),
                            const SizedBox(width: 20),
                            // Fecha
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: isMenuView
                                  ? InputDecorator(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none),
                                      ),
                                      child: Text(
                                        menuDate != null
                                            ? "${menuDate.day.toString().padLeft(2, '0')}/${menuDate.month.toString().padLeft(2, '0')}/${menuDate.year}"
                                            : '',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    )
                                  : DateWidget(
                                      selectedDate: selectedDate,
                                      onDateSelected: (date) {
                                        setState(() => selectedDate = date);
                                        _resetForm();
                                      },
                                      size: MediaQuery.of(context).size.width *
                                          0.15,
                                    ),
                            ),
                            const SizedBox(width: 20),
                            // Botón proponer
                            Button(
                              onPressed: isMenuView || _isLoadingRecipes
                                  ? null
                                  : () => _showConfirmationDialog(),
                              text: isMenuView ? 'Propuesto' : 'Proponer',
                              colorButton: (isMenuView || _isLoadingRecipes)
                                  ? Colors.grey
                                  : null,
                              size: Size(
                                  isMobile ? 320 : 180, isMobile ? 60 : 50),
                            ),
                            const SizedBox(width: 20),
                            // Botón lista de menús
                            Button(
                              onPressed: () {
                                Navigator.push(
                                    context, createFadeRoute(MenuList()));
                              },
                              text: 'Lista de Menús',
                              size: Size(
                                  isMobile ? 320 : 220, isMobile ? 60 : 50),
                            ),
                            SizedBox(height: isMobile ? 10 : 40),
                          ]),
                      SizedBox(height: isMobile ? 10 : 40),
                      Row(
                        children: [
                          Expanded(
                            child: _isLoadingRecipes
                                ? const Center(
                                    child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 100),
                                        CircularProgressIndicator(
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 10),
                                        Text("Cargando platos..."),
                                      ],
                                    ),
                                  ))
                                : Row(
                                    children: _buildMenuCards(isMobile),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuCards(bool isMobile) {
    Widget estudiantes = MenuCard(
      isMobile: isMobile,
      title: 'Menú Estudiantes',
      isEstudiantes: true,
      menu: widget.menu,
    );
    Widget trabajadores = MenuCard(
      isMobile: isMobile,
      title: 'Menú Trabajadores',
      isEstudiantes: false,
      menu: widget.menu,
    );
    Widget espacio =
        SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0);

    if (isMobile) {
      return [estudiantes, espacio, trabajadores];
    } else {
      return [
        Expanded(child: estudiantes),
        espacio,
        Expanded(child: trabajadores),
      ];
    }
  }

  Widget MenuCard({
    required bool isMobile,
    required String title,
    required bool isEstudiantes,
    MenuEntity? menu,
  }) {
    if (menu != null &&
        ((isEstudiantes && menu.category != 'Estudiantes') ||
            (!isEstudiantes && menu.category != 'Trabajadores'))) {
      return Card(
        elevation: 2,
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          height: 70,
          child: Center(
            child: Text(
              'No disponible',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isMobile ? 16 : 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    final isEditing = menu != null;
    final menuItems = isEstudiantes ? _studentMenuItems : _workerMenuItems;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900])),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final menuItem = menuItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Autocomplete<Recipe>(
                              displayStringForOption: (Recipe option) =>
                                  option.name,
                              initialValue: TextEditingValue(
                                  text: menuItem.controller.text),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty ||
                                    _isLoadingRecipes) {
                                  return const Iterable<Recipe>.empty();
                                }
                                return _availableRecipes.where(
                                    (Recipe option) => option.name
                                        .toLowerCase()
                                        .contains(textEditingValue.text
                                            .toLowerCase()));
                              },
                              onSelected: (Recipe selection) {
                                setState(() {
                                  menuItem.selectedRecipeId = selection.id;
                                  menuItem.controller.text = selection.name;
                                });
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                return CustomTextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  labelText: 'Plato ${index + 1}',
                                  onChanged: (value) {
                                    menuItem.controller.text = value;
                                    menuItem.selectedRecipeId = null;
                                  },
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (isEditing) {
                                  menuItems.removeAt(index);
                                } else {
                                  _removeMenuItem(
                                      isEstudiantes: isEstudiantes,
                                      index: index);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    AddButton(
                      onPressed: () {
                        setState(() {
                          if (isEditing) {
                            menuItems.add(RecipeItem(
                                controller: TextEditingController()));
                          } else {
                            _addMenuItem(
                                RecipeItem(controller: TextEditingController()),
                                isEstudiantes: isEstudiantes);
                          }
                        });
                      },
                      text: 'Plato',
                      size: Size(isMobile ? double.infinity : 170, 45),
                    ),
                    Expanded(child: SizedBox()),
                    if (isEditing)
                      Padding(
                        padding: const EdgeInsets.only(right: 40.0),
                        child: Button(
                          onPressed: () async {
                            await _updateMenu(menu, menuItems);
                          },
                          text: 'Guardar',
                          colorButton: Colors.blue,
                          size: Size(isMobile ? 320 : 180, isMobile ? 60 : 50),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMenu(MenuEntity menu, List<RecipeItem> menuItems) async {
    // Solo guarda los platos con receta seleccionada
    menu.recipes.clear();
    menu.recipes = menuItems
        .where((item) => item.selectedRecipeId != null)
        .map((item) => MenuRecipe(id: item.selectedRecipeId))
        .toList();
    menu.status = "Propuesto";
    await _menuController.updateMenu(menu.toJson());
    Navigator.pushReplacement(
      context,
      createFadeRoute(MenuList()),
    );
  }

// Widget sin cambios
  Widget FoodDropDown(
      String? selectedMealType, Function(String?) onChanged, bool isMobile) {
    return SizedBox(
      width: isMobile ? 160 : 200,
      height: isMobile ? 55 : 50,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMealType,
            onChanged: onChanged,
            items: ['Desayuno', 'Almuerzo', 'Comida', 'Merienda']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 18)));
            }).toList(),
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.red[900]),
            dropdownColor: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            isExpanded: false,
          ),
        ),
      ),
    );
  }
}
