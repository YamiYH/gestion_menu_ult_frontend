import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/RecipeTextField.dart';
import 'package:http/http.dart' as http;

import '../../widgets/Button.dart';

class RecetaModelo extends StatefulWidget {
  final Map<String, dynamic>? receta;
  final bool isEditMode;

  const RecetaModelo({
    Key? key,
    this.receta,
    required this.isEditMode,
  }) : super(key: key);

  @override
  State<RecetaModelo> createState() => _RecetaModeloState();
}

class _RecetaModeloState extends State<RecetaModelo> {
  // Controladores para campos editables
  late TextEditingController nombreController;
  late TextEditingController recetaNumController;
  late TextEditingController proteinasController;
  late TextEditingController grasasController;
  late TextEditingController carbohidratosController;
  late TextEditingController energiaController;
  late TextEditingController pesoPorcionController;
  late TextEditingController ingredientesController;
  late TextEditingController pesoBrutoController;
  late TextEditingController pesoNetoController;
  late TextEditingController preparacionController;
  late TextEditingController coccionController;
  late TextEditingController observacionesController;
  late TextEditingController temperaturaController;
  late TextEditingController tiempoCoccionController;

  // Lista de controladores para las filas de ingredientes
  List<Map<String, TextEditingController>> ingredientesControllerMap = [];

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
        text: widget.receta != null ? widget.receta!['name'] : '');
    recetaNumController = TextEditingController(
        text: widget.receta != null ? widget.receta!['recipeNum'] : '');
    proteinasController = TextEditingController(
        text: widget.receta != null ? widget.receta!['proteins'] : '0');
    grasasController = TextEditingController(
        text: widget.receta != null ? widget.receta!['fats'] : '0');
    carbohidratosController = TextEditingController(
        text: widget.receta != null ? widget.receta!['carbs'] : '0');
    energiaController = TextEditingController(
        text: widget.receta != null ? widget.receta!['energy'] : '0');
    pesoPorcionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['portionWeight'] : '0');
    ingredientesController = TextEditingController(
        text: widget.receta != null ? widget.receta!['ingredients'] : '');
    pesoBrutoController = TextEditingController(
        text: widget.receta != null ? '${widget.receta!['grossWeight']}' : '0');
    pesoNetoController = TextEditingController(
        text: widget.receta != null ? '${widget.receta!['netWeight']}' : '0');
    preparacionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['preparation'] : '');
    coccionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['cookingSteps'] : '');
    observacionesController = TextEditingController(
        text: widget.receta != null ? widget.receta!['observations'] : '');
    temperaturaController = TextEditingController(
        text: widget.receta != null ? widget.receta!['temperature'] : '0');
    tiempoCoccionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['cookingTime'] : '0');

    final List<dynamic> ingredientes = widget.receta?['ingredients'] ?? [];
    for (var ingrediente in ingredientes) {
      ingredientesControllerMap.add({
        'name': TextEditingController(text: ingrediente['name'] ?? ''),
        'grossWeight':
            TextEditingController(text: '${ingrediente['grossWeight'] ?? 0}'),
        'netWeight':
            TextEditingController(text: '${ingrediente['netWeight'] ?? 0}'),
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    recetaNumController.dispose();
    proteinasController.dispose();
    grasasController.dispose();
    carbohidratosController.dispose();
    energiaController.dispose();
    pesoPorcionController.dispose();
    ingredientesController.dispose();
    pesoBrutoController.dispose();
    pesoNetoController.dispose();
    preparacionController.dispose();
    coccionController.dispose();
    observacionesController.dispose();
    temperaturaController.dispose();
    tiempoCoccionController.dispose();

    for (var controllerMap in ingredientesControllerMap) {
      controllerMap['name']?.dispose();
      controllerMap['grossWeight']?.dispose();
      controllerMap['netWeight']?.dispose();
    }
    super.dispose();
  }

  final List<String> _categoryOptions = const [
    'Seleccionar',
    'Carnes',
    'Viandas',
    'Vegetales',
    'Especias',
    'Carbohidratos',
    'Refrescos'
  ];

  String? _selectedCategory;

  void addIngredienteRow() {
    setState(() {
      ingredientesControllerMap.add({
        'name': TextEditingController(),
        'grossWeight': TextEditingController(),
        'netWeight': TextEditingController(),
      });
    });
  }

  void _removeIngredienteRow(int index) {
    setState(() {
      if (ingredientesControllerMap.isNotEmpty &&
          index >= 0 &&
          index < ingredientesControllerMap.length) {
        ingredientesControllerMap[index]['name']?.dispose();
        ingredientesControllerMap[index]['grossWeight']?.dispose();
        ingredientesControllerMap[index]['netWeight']?.dispose();
        ingredientesControllerMap.removeAt(index);
      }
    });
  }

  Future<void> saveRecipe() async {
    try {
      if (nombreController.text.isEmpty || recetaNumController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Todos los campos obligatorios deben ser llenados')),
        );
        return;
      }

      final Map<String, dynamic> recipeData = {
        'name': nombreController.text,
        'recipeNum': recetaNumController.text,
        'proteins': double.tryParse(proteinasController.text) ?? 0,
        'fats': double.tryParse(grasasController.text) ?? 0,
        'carbs': double.tryParse(carbohidratosController.text) ?? 0,
        'energy': double.tryParse(energiaController.text) ?? 0,
        'portionWeight': double.tryParse(pesoPorcionController.text) ?? 0,
        'ingredients': ingredientesControllerMap
            .map((controllerMap) => {
                  'name': controllerMap['name']?.text ?? '',
                  'grossWeight': double.tryParse(
                          controllerMap['grossWeight']?.text ?? '0') ??
                      0,
                  'netWeight': double.tryParse(
                          controllerMap['netWeight']?.text ?? '0') ??
                      0,
                })
            .toList(),
        'preparation': preparacionController.text,
        'cookingSteps': coccionController.text,
        'observations': observacionesController.text,
        'temperature': double.tryParse(temperaturaController.text) ?? 0,
        'cookingTime': double.tryParse(tiempoCoccionController.text) ?? 0,
      };

      final response = await http.post(
        Uri.parse('https://tu-backend.com/api/recetas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipeData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta guardada exitosamente')),
        );
        Navigator.pop(context, {'success': true});
      } else {
        throw Exception('Error al guardar la receta.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Receta'),
      body: Padding(
        padding: isMobile ? EdgeInsets.all(20.0) : EdgeInsets.all(30.0),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RecipeTextField(
                      controller: nombreController,
                      enabled: widget.isEditMode,
                      text: isMobile ? 'Nombre plato' : 'Nombre del plato',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: CategoryDropdown(isMobile)),
                ],
              ),
              SizedBox(
                height: 16,
                width: isMobile ? 5 : 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: RecipeTextField(
                      controller: recetaNumController,
                      enabled: widget.isEditMode,
                      text: 'No. Receta',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                      child: RecipeTextField(
                          controller: pesoPorcionController,
                          enabled: widget.isEditMode,
                          text: 'Peso de la porción (g)')),
                ],
              ),

              SizedBox(height: 16),
              // Información nutricional
              Text(
                'Valor Nutricional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RecipeTextField(
                      controller: proteinasController,
                      enabled: widget.isEditMode,
                      text: 'Proteínas (g)',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: RecipeTextField(
                      controller: grasasController,
                      enabled: widget.isEditMode,
                      text: 'Grasas (g)',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: RecipeTextField(
                      controller: carbohidratosController,
                      enabled: widget.isEditMode,
                      text: 'Carbohidratos (g)',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: RecipeTextField(
                      controller: energiaController,
                      enabled: widget.isEditMode,
                      text: 'Energía (kcal)',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              // Ingredientes
              Text(
                'Ingredientes para una ración',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),

              // Encabezado de la tabla con botón "Agregar ingrediente"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isMobile ? HeaderIngredientesMobile() : HeaderIngredientes(),
                  if (widget.isEditMode)
                    IconButton(
                      onPressed: addIngredienteRow,
                      icon:
                          Icon(Icons.add_circle, color: Colors.green, size: 30),
                    ),
                ],
              ),

              // Filas de ingredientes
              ...List.generate(
                ingredientesControllerMap.length,
                (index) {
                  final controllers = ingredientesControllerMap[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controllers['name'],
                              enabled: widget.isEditMode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black54)),
                                labelStyle: TextStyle(
                                    color: widget.isEditMode
                                        ? Colors.black
                                        : Colors.black87),
                              ),
                              style: TextStyle(
                                  color: widget.isEditMode
                                      ? Colors.black
                                      : Colors.black87),
                            ),
                          ),
                          SizedBox(width: 10, height: 16),
                          Expanded(
                            child: TextField(
                              controller: controllers['grossWeight'],
                              enabled: widget.isEditMode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black45)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10, height: 16),
                          Expanded(
                            child: TextField(
                              controller: controllers['netWeight'],
                              enabled: widget.isEditMode,
                              decoration: InputDecoration(
                                labelText: '',
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black45)),
                              ),
                            ),
                          ),
                          if (widget.isEditMode)
                            IconButton(
                              onPressed: () => _removeIngredienteRow(index),
                              icon: Icon(Icons.remove_circle,
                                  color: Colors.red, size: 30),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  );
                },
              ),

              SizedBox(height: 16),

              // Parámetros de cocción
              Text(
                'Parámetros de Cocción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RecipeTextField(
                      controller: temperaturaController,
                      enabled: widget.isEditMode,
                      text: 'Temperatura (°C)',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: RecipeTextField(
                      controller: tiempoCoccionController,
                      enabled: widget.isEditMode,
                      text: 'Tiempo cocción (min)',
                    ),
                  ),
                ],
              ),
              Divider(),

              // Preparación
              Text(
                'Preparación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              RecipeTextField(
                controller: preparacionController,
                enabled: widget.isEditMode,
                lines: isMobile ? 5 : 3,
                text: '',
              ),

              // Cocción
              SizedBox(height: 16),
              Text(
                'Cocción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              RecipeTextField(
                controller: coccionController,
                enabled: widget.isEditMode,
                text: '',
                lines: isMobile ? 5 : 3,
              ),

              SizedBox(height: 16),
              Text(
                'Observaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              RecipeTextField(
                controller: observacionesController,
                enabled: widget.isEditMode,
                text: '',
                lines: isMobile ? 5 : 3,
              ),
              SizedBox(height: 20),
              // Botón de guardar cambios (solo en modo edición)
              if (widget.isEditMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(onPressed: saveRecipe, text: 'Guardar'),
                  ],
                ),
              SizedBox(height: 20)
            ],
          ),
        ]),
      ),
    );
  }

  DropdownButtonFormField<String> CategoryDropdown(bool isMobile) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      onChanged: widget.isEditMode
          ? (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          : null,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      ),
      isExpanded: true,
      items: _categoryOptions.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccionar';
        }
        return null;
      },
    );
  }

  Widget HeaderIngredientes() {
    return Row(
      children: [
        SizedBox(width: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Text(
            'Nombre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Text(
            'Peso bruto (g)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          child: Text(
            'Peso neto (g)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget HeaderIngredientesMobile() {
    return Row(
      children: [
        SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Text(
            'Nombre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Text(
            'P.Bruto(g)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          child: Text(
            'P.Neto(g)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
