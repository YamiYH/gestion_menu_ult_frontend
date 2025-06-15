import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/inventory/InventoryController.dart';
import 'package:gestion_menu_ult_frontend/models/Inventory.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomTextFormField.dart';

import '../../../controllers/menu/RecipeController.dart';
import '../../../models/Recipe.dart';
import '../../../utils/Validators.dart';
import '../../../widgets/Button.dart';

// Clase auxiliar para gestionar los datos de cada fila de ingrediente
class IngredientRowData {
  String? product;
  String? ingredientId; // Almacena el ID del producto seleccionado
  final TextEditingController productController;
  final TextEditingController weightController;
  final TextEditingController netWeightController;

  IngredientRowData({
    this.product,
    this.ingredientId,
    required this.productController,
    required this.weightController,
    required this.netWeightController,
  });

  void dispose() {
    productController.dispose();
    weightController.dispose();
    netWeightController.dispose();
  }
}

class RecetaModelo extends StatefulWidget {
  final bool isEditMode;
  final Recipe? receta;

  const RecetaModelo({
    Key? key,
    this.receta,
    required this.isEditMode,
  }) : super(key: key);

  @override
  State<RecetaModelo> createState() => _RecetaModeloState();
}

class _RecetaModeloState extends State<RecetaModelo> {
  final _formKey = GlobalKey<FormState>();
  final RecipeController _recipeController = RecipeController();
  final InventoryController _inventoryController = InventoryController();

  bool _isSaving = false;
  bool _isLoadingDependencies = true;

  late TextEditingController nombreController;
  late TextEditingController proteinasController;
  late TextEditingController grasasController;
  late TextEditingController carbohidratosController;
  late TextEditingController energiaController;
  late TextEditingController pesoPorcionController;
  late TextEditingController preparacionController;
  late TextEditingController coccionController;
  late TextEditingController observacionesController;
  late TextEditingController temperaturaController;
  late TextEditingController tiempoCoccionController;

  List<IngredientRowData> ingredientRows = [];
  String? _selectedCategory;

  List<String> _categoryOptions = [];
  List<Inventory> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDependencies();
  }

  void _initializeControllers() {
    final r = widget.receta;
    nombreController = TextEditingController(text: r?.name ?? '');
    proteinasController =
        TextEditingController(text: r?.protein.toString() ?? '0');
    grasasController = TextEditingController(text: r?.fat.toString() ?? '0');
    carbohidratosController =
        TextEditingController(text: r?.carbs.toString() ?? '0');
    energiaController =
        TextEditingController(text: r?.calories.toString() ?? '0');
    pesoPorcionController =
        TextEditingController(text: r?.totalWeight.toString() ?? '0');
    preparacionController = TextEditingController(text: r?.preparation ?? '');
    coccionController = TextEditingController(text: r?.cooking ?? '');
    observacionesController =
        TextEditingController(text: r?.observations ?? '');
    temperaturaController =
        TextEditingController(text: r?.temperature.toString() ?? '0');
    tiempoCoccionController =
        TextEditingController(text: r?.cookingTime.toString() ?? '0');

    if (r?.ingredients != null) {
      ingredientRows = r!.ingredients.map((ing) {
        return IngredientRowData(
          // Se asume que el ID del ingrediente es el ID del producto.
          // Si el ID del ingrediente es diferente, necesitarías pasarlo por separado.
          ingredientId: ing.id,
          product: ing.product,
          productController: TextEditingController(text: ing.productName),
          weightController: TextEditingController(text: ing.weight.toString()),
          netWeightController:
              TextEditingController(text: ing.netWeight.toString()),
        );
      }).toList();
    }
  }

  Future<void> _loadDependencies() async {
    try {
      final results = await Future.wait([
        _recipeController.fetchCategories(),
        _inventoryController.fetchFullListOfProducts(),
      ]);

      if (mounted) {
        final categories = results[0] as List<String>;
        final products = results[1] as List<Inventory>;

        setState(() {
          _categoryOptions = categories;
          _availableProducts = products;

          final r = widget.receta;
          if (r != null && _categoryOptions.contains(r.category)) {
            _selectedCategory = r.category;
          } else if (_categoryOptions.isNotEmpty) {
            _selectedCategory = _categoryOptions.first;
          }
          _isLoadingDependencies = false;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar dependencias: $e");
      if (mounted) {
        setState(() => _isLoadingDependencies = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No se pudieron cargar los datos necesarios.')));
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    proteinasController.dispose();
    grasasController.dispose();
    carbohidratosController.dispose();
    energiaController.dispose();
    pesoPorcionController.dispose();
    preparacionController.dispose();
    coccionController.dispose();
    observacionesController.dispose();
    temperaturaController.dispose();
    tiempoCoccionController.dispose();
    for (var row in ingredientRows) {
      row.dispose();
    }
    super.dispose();
  }

  void addIngredienteRow() {
    setState(() {
      ingredientRows.add(IngredientRowData(
        productController: TextEditingController(),
        weightController: TextEditingController(),
        netWeightController: TextEditingController(),
      ));
    });
  }

  void _removeIngredienteRow(int index) {
    setState(() {
      final row = ingredientRows.removeAt(index);
      row.dispose();
    });
  }

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final ingredientsList = ingredientRows.map((row) {
        return {
          'id': row.ingredientId,
          'product': row.product, // Se usa el ID correcto del producto
          'weight': double.tryParse(row.weightController.text) ?? 0.0,
          'netWeight': double.tryParse(row.netWeightController.text) ?? 0.0,
        };
      }).toList();

      final recipeData = {
        'id': widget.receta?.id,
        'name': nombreController.text,
        'category': _selectedCategory,
        'totalWeight': double.tryParse(pesoPorcionController.text) ?? 0.0,
        'calories': double.tryParse(energiaController.text) ?? 0.0,
        'protein': double.tryParse(proteinasController.text) ?? 0.0,
        'fat': double.tryParse(grasasController.text) ?? 0.0,
        'carbs': double.tryParse(carbohidratosController.text) ?? 0.0,
        'cookingTime': int.tryParse(tiempoCoccionController.text) ?? 0,
        'temperature': int.tryParse(temperaturaController.text) ?? 0,
        'preparation': preparacionController.text,
        'cooking': coccionController.text,
        'observations': observacionesController.text,
        'ingredients': ingredientsList,
      };

      if (widget.receta == null)
        await _recipeController.createRecipe(recipeData);
      else
        await _recipeController.updateRecipe(recipeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Receta "${nombreController.text}" guardada.')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.isEditMode
        ? (widget.receta == null ? 'Crear Receta' : 'Editar Receta')
        : 'Detalles de la Receta';
    return Scaffold(
      appBar: CustomAppBar(title: appBarTitle),
      body: _isLoadingDependencies
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding:
          isMobile ? const EdgeInsets.all(20.0) : const EdgeInsets.all(30.0),
      child: Form(
        key: _formKey,
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                        controller: nombreController,
                        readOnly: !widget.isEditMode,
                        labelText: isMobile ? 'Nombre' : 'Nombre del plato',
                        validator: Validators.recipeName),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCategoryDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                  controller: pesoPorcionController,
                  readOnly: !widget.isEditMode,
                  labelText: 'Peso de la porción (g)',
                  validator: Validators.numeric,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              const Text('Valor Nutricional',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: CustomTextFormField(
                          controller: proteinasController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Proteínas (g)',
                          validator: Validators.numeric,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomTextFormField(
                          controller: grasasController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Grasas (g)',
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: CustomTextFormField(
                          controller: carbohidratosController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Carbohidratos (g)',
                          validator: Validators.numeric,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomTextFormField(
                          controller: energiaController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Energía (kcal)',
                          validator: Validators.numeric,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      isMobile
                          ? 'Ingredientes'
                          : 'Ingredientes para una ración',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (widget.isEditMode)
                    AddButton(
                        onPressed: addIngredienteRow,
                        text: 'Ingrediente',
                        size: Size(isMobile ? 160 : 170, 45))
                ],
              ),
              const Divider(),
              if (ingredientRows.isNotEmpty)
                isMobile
                    ? _buildHeaderIngredientesMobile()
                    : _buildHeaderIngredientes(),
              const SizedBox(height: 8),
              ...ingredientRows.map((rowData) {
                int index = ingredientRows.indexOf(rowData);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Autocomplete<Inventory>(
                          displayStringForOption: (Inventory option) =>
                              option.description,
                          initialValue: TextEditingValue(
                              text: rowData.productController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '')
                              return const Iterable<Inventory>.empty();
                            return _availableProducts.where(
                                (Inventory option) => option.description
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (Inventory selection) {
                            setState(() {
                              rowData.product = selection.code;
                              rowData.productController.text =
                                  selection.description;
                            });
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return CustomTextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              readOnly: !widget.isEditMode,
                              labelText: '',
                              onChanged: (value) =>
                                  rowData.productController.text = value,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 2,
                          child: CustomTextFormField(
                              controller: rowData.weightController,
                              readOnly: !widget.isEditMode,
                              labelText: '',
                              validator: Validators.numeric,
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 2,
                          child: CustomTextFormField(
                              controller: rowData.netWeightController,
                              readOnly: !widget.isEditMode,
                              labelText: '',
                              validator: Validators.numeric,
                              keyboardType: TextInputType.number)),
                      if (widget.isEditMode)
                        IconButton(
                            onPressed: () => _removeIngredienteRow(index),
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red, size: 28))
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              const Text('Parámetros de Cocción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: CustomTextFormField(
                          controller: temperaturaController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Temperatura (°C)',
                          validator: Validators.numeric,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomTextFormField(
                          controller: tiempoCoccionController,
                          readOnly: !widget.isEditMode,
                          labelText: 'Tiempo cocción (min)',
                          validator: Validators.numeric,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Preparación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CustomTextFormField(
                  controller: preparacionController,
                  readOnly: !widget.isEditMode,
                  maxLines: 3,
                  labelText: ''),
              const SizedBox(height: 16),
              const Text('Cocción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CustomTextFormField(
                  controller: coccionController,
                  readOnly: !widget.isEditMode,
                  maxLines: 3,
                  labelText: ''),
              const SizedBox(height: 16),
              const Text('Observaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CustomTextFormField(
                  controller: observacionesController,
                  readOnly: !widget.isEditMode,
                  maxLines: 3,
                  labelText: ''),
              const SizedBox(height: 30),
              if (widget.isEditMode)
                Center(
                    child: Button(
                  icon: Icons.save_alt,
                  onPressed: _isSaving ? null : saveRecipe,
                  text: _isSaving ? 'Guardando...' : 'Guardar',
                )),
              const SizedBox(height: 20)
            ],
          ),
        ]),
      ),
    );
  }

  DropdownButtonFormField<String> _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      onChanged: widget.isEditMode
          ? (String? newValue) => setState(() => _selectedCategory = newValue)
          : null,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13.0),
      ),
      isExpanded: true,
      items: _categoryOptions.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Seleccione una categoría' : null,
    );
  }

  Widget _buildHeaderIngredientes() {
    return Row(
      children: [
        _header('Producto', 0.3),
        SizedBox(width: 10),
        _header('Peso Bruto (g)', 0.2),
        SizedBox(width: 10),
        _header('Peso Neto (g)', 0.2),
        SizedBox(width: 48),
      ],
    );
  }

  Widget _buildHeaderIngredientesMobile() {
    return Row(
      children: [
        _header('Producto', 0.31),
        SizedBox(width: 10),
        _header('P. Bruto', 0.22),
        SizedBox(width: 10),
        _header('P. Neto', 0.17),
        SizedBox(width: 48),
      ],
    );
  }

  Widget _header(String title, double widthFactor) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
  }
}
