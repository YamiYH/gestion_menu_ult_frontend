import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/RecipeTextField.dart';

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

  // Lista de controladores para las 12 filas de ingredientes
  List<Map<String, TextEditingController>> ingredientesControllers = [];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con valores actuales
    nombreController = TextEditingController(
        text: widget.receta != null ? widget.receta!['nombre'] : '');
    recetaNumController = TextEditingController(
        text: widget.receta != null ? widget.receta!['recetaNum'] : '');
    proteinasController = TextEditingController(
        text: widget.receta != null ? widget.receta!['proteinas'] : '0');
    grasasController = TextEditingController(
        text: widget.receta != null ? widget.receta!['grasas'] : '0');
    carbohidratosController = TextEditingController(
        text: widget.receta != null ? widget.receta!['carbohidratos'] : '0');
    energiaController = TextEditingController(
        text: widget.receta != null ? widget.receta!['energia'] : '0');
    pesoPorcionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['pesoPorcion'] : '0');
    ingredientesController = TextEditingController(
        text: widget.receta != null ? widget.receta!['ingredientes'] : '');
    pesoBrutoController = TextEditingController(
        text: widget.receta != null ? '${widget.receta!['pesoBruto']}' : '0');
    pesoNetoController = TextEditingController(
        text: widget.receta != null ? '${widget.receta!['pesoNeto']}' : '0');
    preparacionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['preparacion'] : '');
    coccionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['coccion'] : '');
    observacionesController = TextEditingController(
        text: widget.receta != null ? widget.receta!['observaciones'] : '');
    temperaturaController = TextEditingController(
        text: widget.receta != null ? widget.receta!['temperatura'] : '0');
    tiempoCoccionController = TextEditingController(
        text: widget.receta != null ? widget.receta!['tiempoCoccion'] : '0');

    // Inicializar controladores para ingredientes
    final List<dynamic> ingredientes = widget.receta?['ingredientes'] ?? [];
    for (var ingrediente in ingredientes) {
      ingredientesControllers.add({
        'nombre': TextEditingController(text: ingrediente['nombre'] ?? ''),
        'pesoBruto':
            TextEditingController(text: '${ingrediente['pesoBruto'] ?? 0}'),
        'pesoNeto':
            TextEditingController(text: '${ingrediente['pesoNeto'] ?? 0}'),
      });
    }
  }

  @override
  void dispose() {
    // Liberar recursos
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

    for (var controllerMap in ingredientesControllers) {
      controllerMap['nombre']?.dispose();
      controllerMap['pesoBruto']?.dispose();
      controllerMap['pesoNeto']?.dispose();
    }
    super.dispose();
  }

  // Método para agregar una nueva fila de ingredientes
  void addIngredienteRow() {
    setState(() {
      ingredientesControllers.add({
        'nombre': TextEditingController(),
        'pesoBruto': TextEditingController(),
        'pesoNeto': TextEditingController(),
      });
    });
  }

  // Método para eliminar una fila de ingredientes
  void _removeIngredienteRow(int index) {
    setState(() {
      if (ingredientesControllers.isNotEmpty &&
          index >= 0 &&
          index < ingredientesControllers.length) {
        ingredientesControllers[index]['nombre']?.dispose();
        ingredientesControllers[index]['pesoBruto']?.dispose();
        ingredientesControllers[index]['pesoNeto']?.dispose();
        ingredientesControllers.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Receta'),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              RecipeTextField(
                controller: nombreController,
                enabled: widget.isEditMode,
                text: 'Nombre del plato',
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
                ingredientesControllers.length,
                (index) {
                  final controllers = ingredientesControllers[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controllers['nombre'],
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
                              controller: controllers['pesoBruto'],
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
                              controller: controllers['pesoNeto'],
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
                    Button(onPressed: () {}, text: 'Guardar'),
                  ],
                ),
              SizedBox(height: 20)
            ],
          ),
        ]),
      ),
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
