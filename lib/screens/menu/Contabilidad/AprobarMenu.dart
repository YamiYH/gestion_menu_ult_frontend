import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para FilteringTextInputFormatter
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/DynamicButton.dart';

import '../../../controllers/menu/MenuController.dart';
import '../../../widgets/SmallButton.dart';
import 'Contabilidad.dart';

class AprobarMenu extends StatefulWidget {
  final MenuEntity? menu;

  const AprobarMenu({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<AprobarMenu> createState() => _AprobarMenuState();
}

class _AprobarMenuState extends State<AprobarMenu> {
  final MenuEntityController _menuController = MenuEntityController();
  bool _isProcessingStatusChange = false;
  bool _isSaving = false;

  Map<String, TextEditingController> _priceControllers = {};
  @override
  void initState() {
    super.initState();
    for (var item in widget.menu!.recipes) {
      final String itemId = item.id as String;
      final double initialPrice = item.price?.toDouble() ?? 0.0;
      final controller = TextEditingController(
        text: initialPrice.toStringAsFixed(2), // Formato con 2 decimales
      );
      controller.addListener(_updateTotal);
      _priceControllers[itemId] = controller;
    }
  }

  // --- Función para actualizar el estado (y recalcular el total) ---
  void _updateTotal() {
    // Simplemente llama a setState para forzar la reconstrucción y
    // que el getter 'totalPrice' se vuelva a evaluar.
    setState(() {});
  }

  Future<void> _saveChanges() async {
    // 1. Validar que no estemos guardando ya y que el menú exista.
    if (_isSaving || widget.menu == null) return;

    // 2. Activar el estado de carga y reconstruir la UI
    setState(() {
      _isSaving = true;
    });

    try {
      // 3. Actualizar los precios en el objeto `widget.menu`
      // Iteramos sobre las recetas del menú para asegurar que actualizamos las correctas.
      for (var recipe in widget.menu!.recipes) {
        final String recipeId = recipe.id as String;
        if (_priceControllers.containsKey(recipeId)) {
          final controller = _priceControllers[recipeId]!;
          final newPrice = double.tryParse(controller.text) ?? 0.0;
          recipe.price = newPrice; // ¡Actualizamos el precio en el objeto!
        }
      }

      // 4. Actualizar el precio total del menú usando nuestro getter
      widget.menu!.totalPrice = totalPrice;

      // 5. Enviar el objeto menú actualizado al backend
      await _menuController.updateMenu(widget.menu!.toJson());

      // 6. Mostrar feedback de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los cambios en los precios se guardaron con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 7. Manejar errores y mostrar feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar los cambios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 8. Desactivar el estado de carga, sin importar si hubo éxito o error
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _changeMenuStatus(String newStatus) async {
    if (_isProcessingStatusChange || widget.menu == null) return;

    setState(() {
      _isProcessingStatusChange = true;
    });

    try {
      await _menuController.changeStatusMenu(widget.menu!.id!, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('El menú ha sido marcado como "$newStatus" con éxito.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Contabilidad()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar el estado del menú: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingStatusChange = false;
        });
      }
    }
  }

  Future<void> _showConfirmationDialog(String statusToSet) async {
    final bool isApproving = statusToSet == 'Aprobado';
    final String actionText = isApproving ? 'Aprobar' : 'Rechazar';
    final Color actionColor = isApproving ? Colors.green : Colors.red;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Acción'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres $actionText este menú?'),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: actionColor),
              child: Text(actionText,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _changeMenuStatus(statusToSet); // Ejecuta la acción
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _priceControllers.values.forEach((controller) {
      controller.removeListener(_updateTotal);
      controller.dispose();
    });
    super.dispose();
  }

  double get totalPrice {
    double total = 0.0;
    _priceControllers.forEach((id, controller) {
      // double.tryParse para evitar errores si el campo está vacío o mal formateado
      total += double.tryParse(controller.text) ?? 0.0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
        appBar: CustomAppBar(title: 'Aprobar Menú'),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MenuApprovalSection(isMobile, context),
                        BuildButtons(isMobile)
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          MenuApprovalSection(isMobile, context),
                          BuildButtons(isMobile),
                        ])),
        ));
  }

  Widget MenuApprovalSection(bool isMobile, BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.65,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustar Precios', // Título más específico
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Menú ${widget.menu!.date} : ${widget.menu!.category}', // Título más específico
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.menu!.recipes.length,
                itemBuilder: (context, index) {
                  final menuItem = widget.menu!.recipes[index];
                  final String itemId = menuItem.id as String;
                  return BuildCard(menuItem, _priceControllers[itemId]!);
                }),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30), // Espacio antes de los botones

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.grey[800]),
                  child: Text('Cancelar',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15), // Espacio entre botones
                SmallButton(
                  onPressed: _saveChanges,
                  size: Size(isMobile ? 120 : 180, 45),
                  isLoading: _isSaving, // Simplemente pasas el flag
                  text: isMobile
                      ? 'Guardar'
                      : 'Guardar Cambios', // Pasas el texto como hijo
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget BuildButtons(bool isMobile) {
    final bool isAnyActionLoading = _isSaving || _isProcessingStatusChange;

    return Container(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          SizedBox(
            height: isMobile ? 50 : 0,
          ),
          DynamicButton(
            onPressed: isAnyActionLoading
                ? null
                : () => _showConfirmationDialog('Aprobado'),
            isLoading: _isProcessingStatusChange,
            text: 'Aprobar',
            colorButton: Colors.red.shade700,
            icon: Icons.check,
            size: Size(isMobile ? 180 : 230, 50),
          ),
          const SizedBox(
            height: 20,
          ),
          DynamicButton(
            onPressed: isAnyActionLoading
                ? null
                : () => _showConfirmationDialog('Rechazado'),
            isLoading: _isProcessingStatusChange,
            text: 'Rechazar',
            colorButton: Colors.red[800]!, // Usamos un rojo estándar
            icon: Icons.close,
            size: Size(isMobile ? 180 : 230, 50),
          ),
        ],
      ),
    );
  }

  Widget BuildCard(MenuRecipe menuItem, TextEditingController priceController) {
    return Card(
        shadowColor: Colors.grey.shade200,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300) // Borde ligero
            ),
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            menuItem.name as String,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: SizedBox(
              width: 100,
              child: TextFormField(
                controller: priceController,
                // Asigna el controlador
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Permite números y un solo punto decimal
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  // Símbolo de dólar como prefijo
                  isDense: true,
                  // Hace el campo más compacto
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  // Relleno interno
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Borde cuando está habilitado
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Borde cuando tiene foco
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.red.shade900, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (double.tryParse(value!) == null) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              )),
        ));
  }
}
