import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/Button.dart'; // Ajusta la ruta (Usando tu Button)
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart'; // Ajusta la ruta
import 'package:gestion_menu_ult_frontend/widgets/StatusCheckboxRow.dart';

import '../../widgets/CustomTextFormField.dart'; // Ajusta la ruta

class UserModelo extends StatefulWidget {
  const UserModelo({super.key});

  @override
  State<UserModelo> createState() => _UserModeloState();
}

class _UserModeloState extends State<UserModelo> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic>? initialData = Map();

  // Controladores
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variables desplegables
  String? _selectedRole;
  String? _selectedStatus;
  String? _selectedType;

  // Opciones desplegables
  final List<String> _roles = ['Estudiante', 'Profesor', 'Administrador'];
  final List<String> _statuses = ['Activo', 'Inactivo'];

  // Corregido: Asegúrate que estos valores ('Admin'?) coincidan con los usados en Users.dart si es necesario
  final List<String> _types = ['Admin', 'System', 'Employee'];

  @override
  void initState() {
    super.initState();
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'username': _usernameController.text,
        'name': _nameController.text,
        'lastname': _lastnameController.text,
        'email': _emailController.text,
        'role': _selectedRole,
        'status': _selectedStatus,
        'type': _selectedType,
      };
      print('Usuario a guardar: $newUser');
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      print('Formulario inválido');
    }
  }

  // --- PASO 1: Mover helpers fuera de build y corregirlos ---

  // Helper para InputDecoration (CORREGIDO: acepta prefixIcon opcional)
  InputDecoration _inputDecoration(String label, {Widget? prefixIcon}) {
    final theme = Theme.of(context);
    final primaryColor = Colors.red[900] ?? theme.colorScheme.primary;
    final defaultBorderColor = Colors.grey[400] ?? Colors.grey;
    final errorColor = Colors.red[700] ?? theme.colorScheme.error;
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      // Usar prefixIcon
      prefixIconColor: Colors.grey[600],
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: defaultBorderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: defaultBorderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: primaryColor, width: 2.0)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: errorColor, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: errorColor, width: 2.0)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
    );
  }

  // Helper para la fila de botones (CORREGIDO: usa tu Button)
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
                style: TextStyle(
                    fontSize: isMobile ? 14 : 16)), // Ajuste de tamaño
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

    final List<Widget> formFields = [
      CustomTextFormField(
        controller: _usernameController,
        labelText: 'Usuario',
        suffixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
        // CORREGIDO a prefixIcon
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _nameController,
        labelText: 'Nombre',
        suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _lastnameController,
        labelText: 'Apellidos',
        suffixIcon: Icon(Icons.badge_outlined, color: Colors.grey[600]),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _emailController,
        labelText: 'Email',
        suffixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Campo requerido';
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
            return 'Email inválido';
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _passwordController,
        labelText: 'Contraseña',
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
        obscureText: true,
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
        textInputAction: TextInputAction.next,
      ),
      CustomTextFormField(
        controller: _confirmPasswordController,
        labelText: 'Confirmar Contraseña',
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
        obscureText: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Campo requerido';
          if (v != _passwordController.text)
            return 'Las contraseñas no coinciden';
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _saveForm(),
      ),
      DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: _inputDecoration(
          'Rol',
        ),
        // Añadido icono
        items: _roles
            .map((String role) =>
                DropdownMenuItem<String>(value: role, child: Text(role)))
            .toList(),
        onChanged: (v) => setState(() => _selectedRole = v),
        validator: (v) => v == null ? 'Seleccione un rol' : null,
      ),
      DropdownButtonFormField<String>(
        value: _selectedType,
        decoration: _inputDecoration(
          'Tipo',
        ),
        // Añadido icono
        items: _types
            .map((String type) =>
                DropdownMenuItem<String>(value: type, child: Text(type)))
            .toList(),
        onChanged: (v) => setState(() => _selectedType = v),
        validator: (v) => v == null ? 'Seleccione un tipo' : null,
      ),
      StatusCheckboxRow(
          currentStatus: _selectedStatus,
          onStatusChanged: (v) => setState(() => _selectedStatus = v)),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'Añadir Usuario'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('')
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
                child: Form(
                  key: _formKey,
                  child: isMobile
                      ? _buildMobileLayout(formFields, isMobile)
                      : Column(
                          children: [
                            SizedBox(height: isMobile ? 0 : 40),
                            _buildWebLayout(formFields, isMobile),
                          ],
                        ), // Llama a helper desktop
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper para construir layout móvil ---
  Widget _buildMobileLayout(List<Widget> fields, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Añade espacio vertical entre cada campo
        ...fields.expand((widget) => [widget, SizedBox(height: 16)]),
        SizedBox(height: 5),
        _buildButtonRow(isMobile), // Llama al helper de botones
      ],
    );
  }

  // --- Helper para construir layout desktop ---
  Widget _buildWebLayout(List<Widget> fields, bool isMobile) {
    if (fields.length != 9) {
      print(
          "Error: Se esperaban 9 campos para el layout de 3 columnas, pero se recibieron ${fields.length}");
      return _buildMobileLayout(fields, isMobile); // Fallback a layout móvil
    }
    return Column(
      // Columna principal: Fila de campos + Fila de botones
      children: [
        Row(
          // Fila que contiene las 3 columnas de campos
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna 1 (Campos 0, 1, 2)
            Expanded(
              child: Column(
                children: [
                  fields[0],
                  SizedBox(height: 16),
                  fields[1],
                  SizedBox(height: 16),
                  fields[2],
                ],
              ),
            ),
            SizedBox(width: 20), // Espacio entre columnas
            // Columna 2 (Campos 3, 4, 5)
            Expanded(
              child: Column(
                children: [
                  fields[3],
                  SizedBox(height: 16),
                  fields[4],
                  SizedBox(height: 16),
                  fields[5],
                ],
              ),
            ),
            SizedBox(width: 20), // Espacio entre columnas
            // Columna 3 (Campos 6, 7, 8)
            Expanded(
              child: Column(
                children: [
                  fields[6],
                  SizedBox(height: 16),
                  fields[7],
                  SizedBox(height: 30),
                  fields[8],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 40),
        // Fila de botones separada debajo
        _buildButtonRow(isMobile), // Llama al helper de botones
      ],
    );
  }
} // Fin de _UserModeloState
