import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/CustomTextFormField.dart';
import '../../widgets/MultiSelectAccessDropdown.dart';
import '../../widgets/StatusCheckboxRow.dart'; // Ajusta la ruta

class RolModelo extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const RolModelo({super.key, this.initialData /*, this.user*/
      });

  @override
  State<RolModelo> createState() => _RolModeloState();
}

class _RolModeloState extends State<RolModelo> {
  final _formKey = GlobalKey<FormState>();

  // Controladores

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variables desplegables
  List<String> _selectedAccess = [];
  String? _selectedStatus;

  // --- AÑADIDO: Variable para saber si estamos editando ---
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      // Asegurarse de que access sea una lista de Strings
      _selectedAccess = List<String>.from(widget.initialData!['access'] ?? []);
      _selectedStatus = widget.initialData![
          'status']; // Asume que status siempre existe y es String?
    } else {
      //_selectedStatus = 'Activo'; // Ejemplo
      _selectedAccess = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Crea el mapa de datos del rol (nuevo o actualizado)
      final rolData = {
        // Si estamos editando, usa el ID existente, si no, genera uno nuevo
        'id':
            widget.initialData?['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'access': _selectedAccess,
        'status': _selectedStatus,
      };
      print('Rol a guardar/actualizar: $rolData');
      if (mounted) {
        // --- AÑADIDO: Devolver los datos al hacer pop ---
        Navigator.pop(context, rolData); // Devuelve el mapa con los datos
      }
    } else {
      print('Formulario inválido');
    }
  }

  Widget _buildButtonRow(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text('Cancelar',
                style: TextStyle(
                    fontSize: isMobile ? 15 : 18)), // Ajuste de tamaño
          ),
          SizedBox(width: 15),
          // Usando tu widget Button personalizado
          Button(
              size: Size(isMobile ? 160 : 180, 45), // Tamaño ajustado
              onPressed: _saveForm,
              text: 'Guardar',
              icon: Icons.save_alt),
          // SizedBox(height: 50) // Este SizedBox(height) en una Row no tiene sentido
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: _isEditing ? 'Editar Rol' : 'Añadir Rol'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 600 : 1000),
              // Ancho máx
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 0 : 40),
                    Form(key: _formKey, child: _buildRolModel(isMobile)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRolModel(bool isMobile) {
    return SizedBox(
      width: isMobile ? MediaQuery.of(context).size.width * 0.85 : 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          CustomTextFormField(
            controller: _nameController,
            labelText: 'Nombre de rol',
            suffixIcon: Icon(Icons.person, color: Colors.grey[600]),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo requerido' : null,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20),
          CustomTextFormField(
            controller: _descriptionController,
            labelText: 'Descripción',
            suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo requerido' : null,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20),
          MultiSelectAccessDropdown(
            selectedValues: _selectedAccess,
            onSelectionChanged: (List<String> newSelection) {
              // Actualiza la lista en el estado del padre
              setState(() {
                _selectedAccess = newSelection;
              });
              // _formKey.currentState?.validate();
            },
            // Añade validación si es necesario
            validator: (values) {
              if (values == null || values.isEmpty) {
                return 'Debe seleccionar al menos un acceso';
              }
              return null; // Es válido
            },
          ),
          SizedBox(height: 20),

          // Envuélvelo en Expanded si está en una Row con otro Expanded
          StatusCheckboxRow(
            currentStatus: _selectedStatus, // Pasa el estado actual
            onStatusChanged: (newStatus) {
              setState(() {
                _selectedStatus = newStatus;
              });
            },
          ),

          SizedBox(height: 40),
          // Divider(),
          _buildButtonRow(isMobile)
        ],
      ),
    );
  }
} // Fin de _UserModeloState
