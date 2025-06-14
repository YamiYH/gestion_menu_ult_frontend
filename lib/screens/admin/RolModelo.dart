import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/utils/Validators.dart';
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../controllers/security/RoleController.dart';
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

  final RoleController _roleController = RoleController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variables desplegables
  List<String> _selectedPermissions = [];
  bool _isActive = true;
  bool _isSaving = false;

  List<String> _allAvailableModules = [];
  bool _isLoadingModules = true; // Para mostrar un indicador de carga
  String? _modulesError; // Para mostrar un mensaje de error si falla la carga

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      _selectedPermissions =
          List<String>.from(widget.initialData!['permissions'] ?? []);
      _isActive = widget.initialData!['enabled'] ?? true;
    } else {
      //_selectedStatus = 'Activo'; // Ejemplo
      _selectedPermissions = [];
    }
    _loadAvailableModules();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableModules() async {
    try {
      final modules = await _roleController.fetchModules();
      if (mounted) {
        setState(() {
          // Añadimos "Todos" a la lista que viene de la API
          _allAvailableModules = ['Todos', ...modules];
          _isLoadingModules = false; // Terminamos la carga
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _modulesError = "Error al cargar accesos.";
          _isLoadingModules = false; // Terminamos la carga (con error)
        });
      }
      debugPrint("Error cargando módulos: $e");
    }
  }

  // EN RolModelo.dart (EJEMPLO CORRECTO)

// Asegúrate de que el método sea async
  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Si el formulario no es válido, no hagas nada.
      return;
    }

    // Opcional: Muestra un indicador de carga para que el usuario sepa que algo está pasando.
    setState(() {
      _isSaving = true; // Necesitarás declarar un bool _isSaving = false;
    });

    try {
      final rolData = {
        'id': widget.initialData?['id'],
        'name': _nameController.text,
        'description': _descriptionController.text,
        'enabled': _isActive,
        'permissions': _selectedPermissions,
      };

      if (_isEditing) {
        await _roleController.updateRole(rolData);
      } else {
        await _roleController.createRole(rolData);
      }

      // 3. Si todo fue bien, cierra la pantalla y devuelve el resultado.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rol guardado exitosamente'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context,
            rolData); // Devuelve los datos para que la lista se refresque
      }
    } catch (e) {
      // 4. Si hay un error, muéstralo y no cierres la pantalla.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar el rol: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      // 5. Oculta el indicador de carga, tanto si hubo éxito como si hubo error.
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
                style: TextStyle(fontSize: isMobile ? 15 : 18)),
          ),
          SizedBox(width: 15),

          Button(
              size: Size(isMobile ? 160 : 180, 45),
              onPressed: _saveForm,
              text: 'Guardar',
              icon: Icons.save_alt),
          // SizedBox(height: 50)
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
            controller: _descriptionController,
            labelText: 'Nombre de rol',
            suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
            validator: Validators.personName,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20),
          CustomTextFormField(
            controller: _nameController,
            labelText: 'Nombre interno del sistema',
            prefixText: 'ROLE_',
            suffixIcon: Icon(Icons.person, color: Colors.grey[600]),
            validator: Validators.roleNamePart,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20),
          if (_isLoadingModules)
            // Si está cargando, muestra este widget
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: const [
                  // Usamos const para mejor rendimiento
                  SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 15),
                  Text('Cargando accesos...'),
                ],
              ),
            )
          else if (_modulesError != null)
            // Si hay un error, muestra este otro widget
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _modulesError!,
                style: const TextStyle(color: Colors.red), // Usamos const
              ),
            )
          else
            // Si la carga fue exitosa, muestra el Dropdown.
            // Esta es la instanciación correcta del widget.
            MultiSelectAccessDropdown(
              label: 'Accesos',
              allOptions: _allAvailableModules,
              selectedValues: _selectedPermissions,
              onSelectionChanged: (List<String> newSelection) {
                setState(() {
                  _selectedPermissions = newSelection;
                });
              },
              validator: (values) {
                if (values == null || values.isEmpty) {
                  return 'Debe seleccionar al menos un acceso';
                }
                return null;
              },
            ),
          SizedBox(height: 20),
          StatusCheckboxRow(
            label: 'Activo',
            value: _isActive,
            onChanged: (newValue) {
              if (newValue == null) return;

              setState(() {
                _isActive = newValue;
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
