import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/security/RoleController.dart';
import 'package:gestion_menu_ult_frontend/models/RoleEntity.dart';
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/StatusCheckboxRow.dart';

import '../../../controllers/security/user/UserController.dart';
import '../../../utils/Validators.dart';
import '../../../widgets/CustomTextFormField.dart';
import '../../../widgets/RoleDropDown.dart';

class UserModelo extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const UserModelo({
    super.key,
    this.initialData,
  });

  @override
  State<UserModelo> createState() => _UserModeloState();
}

class _UserModeloState extends State<UserModelo> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = RoleController();
  final _userController = UserController();

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estado
  String? _selectedRoleId;
  String? _selectedRole;
  String? _selectedType;
  bool _isUserActive = true;
  bool _isLoadingData = true;
  bool _isSaving = false;

  // Listas para dropdowns

  List<String> _availableTypes = [];
  List<RoleEntity> _availableRoles = [];

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingData = true;
    });

    try {
      debugPrint("[UserModelo] Iniciando carga de datos para el formulario...");

      final futureRoles = _roleController.fetchRoles();
      final futureTypes = _userController.fetchUserTypes();

      final results = await Future.wait([futureRoles, futureTypes]);

      final rolesFromApi = results[0] as List<RoleEntity>;
      final typesFromApi = results[1] as List<String>;

      setState(() {
        _availableRoles = rolesFromApi;
        _availableTypes = typesFromApi;

        if (_isEditing && widget.initialData != null) {
          _populateFormFields();
        } else {
          if (_availableRoles.isNotEmpty) {
            _selectedRoleId = _availableRoles.first.id;
          }
          if (_availableTypes.isNotEmpty) _selectedType = _availableTypes.first;
        }
      });
    } catch (e) {
      if (mounted) {
        final errorMessage = 'Error al cargar datos: ${e.toString()}';
        debugPrint("[UserModelo] $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage), backgroundColor: Colors.red[700]),
        );
        // Si falla la carga, usamos listas de respaldo para que la UI no se rompa
        setState(() {
          _availableRoles = [];
          _availableTypes = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _populateFormFields() async {
    _usernameController.text = widget.initialData!['username'] ?? '';
    _nameController.text = widget.initialData!['name'] ?? '';
    _lastnameController.text = widget.initialData!['lastname'] ?? '';
    _emailController.text = widget.initialData!['email'] ?? '';
    _selectedRole = widget.initialData!['role'];
    _isUserActive = (widget.initialData!['enabled'] == 'Activo');
    _selectedType = widget.initialData!['type'];

    // Obtenemos la descripción del rol que viene en initialData
    final roleDescription = widget.initialData!['role'];
    if (roleDescription != null) {
      // Usamos el controller para encontrar el ID correspondiente a esa descripción
      final roleId =
          await _roleController.getRoleIdByDescription(roleDescription);
      setState(() {
        _selectedRoleId = roleId;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _selectedRoleId =
          await _roleController.getRoleIdByDescription(_selectedRole!);
      final rolesToSend = _selectedRoleId != null ? [_selectedRoleId] : [];

      final userData = {
        'username': _usernameController.text,
        'name': _nameController.text,
        'lastName': _lastnameController.text,
        'email': _emailController.text,
        'role': rolesToSend,
        'enabled': _isUserActive,
        'type': _selectedType,
      };

      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      setState(() {
        _isSaving = true;
      });
      try {
        if (_isEditing) {
          // --- Lógica para ACTUALIZAR (PUT) ---
          final updatedUser = await _userController.updateUser(userData);
          print("Usuario actualizado: ${updatedUser.name}");
        } else {
          // --- Lógica para CREAR (POST) ---
          final newUser = await _userController.createUser(userData);
          print("Usuario creado con éxito: ${newUser.name}");
        }

        if (mounted) {
          // Si todo sale bien, muestra un mensaje de éxito y cierra la pantalla
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Usuario guardado con éxito.'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context,
              true); // Devuelve 'true' para indicar que se debe refrescar la lista
        }
      } catch (e) {
        // Si hay un error, muéstralo al usuario en un SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al guardar: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      } finally {
        // Desactiva el indicador de carga
        setState(() {
          /* _isSaving = false; */
        });
      }
    }
  }

  Widget _buildButtonRow(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text('Cancelar',
                style: TextStyle(fontSize: isMobile ? 14 : 16)),
          ),
          const SizedBox(width: 15),
          Button(
            size: Size(isMobile ? 160 : 180, 45),
            onPressed: _saveForm,
            text: 'Guardar',
            icon: Icons.save_alt,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar:
          CustomAppBar(title: _isEditing ? 'Editar Usuario' : 'Añadir Usuario'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: isMobile
            ? null
            : BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/img/background0.png'),
                    fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 600 : 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: _isLoadingData
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: isMobile
                            ? _buildMobileLayout(isMobile)
                            : Column(
                                children: [
                                  SizedBox(height: isMobile ? 0 : 40),
                                  _buildWebLayout(isMobile),
                                ],
                              ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      CustomTextFormField(
        controller: _usernameController,
        labelText: 'Usuario',
        suffixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
        validator: Validators.username,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _nameController,
        labelText: 'Nombre',
        suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
        validator: Validators.personName,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _lastnameController,
        labelText: 'Apellidos',
        suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
        validator: Validators.personName,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _emailController,
        labelText: 'Email',
        suffixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
        keyboardType: TextInputType.emailAddress,
        validator: Validators.email,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _passwordController,
        labelText: _isEditing ? 'Nueva Contraseña (opcional)' : 'Contraseña',
        obscureText: true,
        validator: Validators.password,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _confirmPasswordController,
        labelText: 'Confirmar Contraseña',
        obscureText: true,
        validator: Validators.password,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _saveForm(),
      ),
      RoleDropDown(
        selectedValue: _selectedRole,
        onChanged: (newValue) {
          setState(() {
            _selectedRole = newValue;
          });
        },
      ),
      TypeDropDown(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StatusCheckboxRow(
            label: 'Activo',
            value: _isUserActive,
            onChanged: (newValue) {
              if (newValue == null) return;

              setState(() {
                _isUserActive = newValue;
              });
            },
          ),
        ],
      ),
    ];
  }

  DropdownButtonFormField<String> TypeDropDown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: _inputDecoration('Tipo'),
      items: _availableTypes
          .map((String type) =>
              DropdownMenuItem<String>(value: type, child: Text(type)))
          .toList(),
      onChanged: (v) => setState(() => _selectedType = v),
      validator: (v) => v == null ? 'Seleccione un tipo' : null,
    );
  }

  Widget _buildMobileLayout(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._buildFormFields()
            .expand((widget) => [widget, const SizedBox(height: 16)]),
        const SizedBox(height: 5),
        _buildButtonRow(isMobile),
      ],
    );
  }

  Widget _buildWebLayout(bool isMobile) {
    final formFields = _buildFormFields();
    // El layout web ahora siempre es el mismo (3 columnas)
    const int expectedFields = 9;
    if (formFields.length != expectedFields) {
      print(
          "Advertencia: Se esperaban $expectedFields campos, pero se recibieron ${formFields.length}");
      return _buildMobileLayout(isMobile); // Fallback a layout móvil
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna 1
            Expanded(
              child: Column(
                children: [
                  formFields[0],
                  const SizedBox(height: 16),
                  formFields[1],
                  const SizedBox(height: 16),
                  formFields[2],
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Columna 2
            Expanded(
              child: Column(
                children: [
                  formFields[3],
                  const SizedBox(height: 16),
                  formFields[4],
                  const SizedBox(height: 16),
                  formFields[5],
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Columna 3
            Expanded(
              child: Column(
                children: [
                  formFields[6],
                  const SizedBox(height: 16),
                  formFields[7],
                  const SizedBox(height: 30),
                  formFields[8],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        _buildButtonRow(isMobile),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      prefixIconColor: Colors.grey[600],
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.red[900]!, width: 2.0)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.red[700]!, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.red[700]!, width: 2.0)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
    );
  }
}
