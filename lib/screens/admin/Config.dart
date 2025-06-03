import 'package:flutter/material.dart'; // Asegúrate de que estas rutas sean correctas para tu proyecto
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/ConfigTextFormField.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

// Clase para definir la configuración de cada campo
class FieldConfigData {
  final TextEditingController controller;
  final String labelText;
  final IconData iconData;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool? isObscure;
  final VoidCallback? onObscureToggle;
  final bool isOptional;

  FieldConfigData({
    required this.controller,
    required this.labelText,
    required this.iconData,
    this.validator,
    this.keyboardType,
    this.isObscure,
    this.onObscureToggle,
    this.isOptional = false,
  });
}

// Widget reutilizable para una sección de configuración
class ConfigSectionWidget extends StatelessWidget {
  final String title;
  final String saveButtonText;
  final GlobalKey<FormState> formKey;
  final List<FieldConfigData> fieldConfigs;
  final VoidCallback onSave;
  final bool isMobile;
  final Widget Function(FieldConfigData) fieldBuilder;
  final List<List<int>>
      nonMobileLayoutIndices; // Define qué campos van en cada fila para no-móvil

  const ConfigSectionWidget({
    super.key,
    required this.title,
    required this.saveButtonText,
    required this.formKey,
    required this.fieldConfigs,
    required this.onSave,
    required this.isMobile,
    required this.fieldBuilder,
    required this.nonMobileLayoutIndices,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          isMobile ? _buildMobileLayout() : _buildNonMobileLayout(),
          const SizedBox(height: 24.0),
          isMobile
              ? Button(onPressed: onSave, text: saveButtonText)
              : Align(
                  alignment: Alignment.centerRight,
                  child: Button(onPressed: onSave, text: saveButtonText),
                ),
          const SizedBox(height: 24.0),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    List<Widget> children = [];
    for (var config in fieldConfigs) {
      children.add(fieldBuilder(config));
      children.add(const SizedBox(height: 16.0));
    }
    if (children.isNotEmpty) {
      children.removeLast(); // Quita el último SizedBox
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildNonMobileLayout() {
    List<Widget> rows = [];
    for (var rowIndices in nonMobileLayoutIndices) {
      List<Widget> fieldsInRow = [];
      for (int i = 0; i < rowIndices.length; i++) {
        int fieldIndex = rowIndices[i];
        if (fieldIndex < fieldConfigs.length) {
          // Asigna un flex de 2 al primer elemento de la fila si es la configuración de BD y la fila tiene más de 1 elemento.
          // Esto es para replicar tu `flex: 2` original en el campo "Servidor de Base de Datos".
          bool applyFlex2 = title.contains("Base de Datos") &&
              i == 0 &&
              rowIndices.length > 1;
          fieldsInRow.add(Expanded(
              flex: applyFlex2 ? 2 : 1,
              child: fieldBuilder(fieldConfigs[fieldIndex])));
          if (i < rowIndices.length - 1) {
            fieldsInRow.add(const SizedBox(width: 16.0));
          }
        }
      }
      rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: fieldsInRow));
      rows.add(const SizedBox(height: 16.0));
    }
    if (rows.isNotEmpty) {
      rows.removeLast(); // Quitar el último SizedBox vertical
    }
    return Column(children: rows);
  }
}

// --- Pantalla Principal de Configuración ---
class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final _formKeyDB = GlobalKey<FormState>();
  final _formKeyEnzona = GlobalKey<FormState>();

  // Controladores DB
  final _dbServerController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Controladores Enzona
  final _enzonaConsumerKeyController = TextEditingController();
  final _enzonaConsumerSecretController = TextEditingController();
  final _enzonaMerchantUuidController = TextEditingController();
  final _enzonaReturnUrlController = TextEditingController();
  final _enzonaCancelUrlController = TextEditingController();
  final _enzonaTerminalIdController = TextEditingController();
  bool _obscureEnzonaConsumerSecret = true;

  late List<FieldConfigData> _dbFields;
  late List<FieldConfigData> _enzonaFields;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    // Aquí podrías cargar configuraciones guardadas si las tienes
    // _loadSavedConfigurations();
  }

  void _initializeFields() {
    _dbFields = [
      FieldConfigData(
        controller: _dbServerController,
        labelText: 'Servidor de Base de Datos',
        iconData: Icons.dns,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Ingrese el servidor de BD'
            : null,
      ),
      FieldConfigData(
        controller: _portController,
        labelText: 'Puerto',
        iconData: Icons.lan_outlined,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Ingrese el puerto de BD';
          if (int.tryParse(value) == null) return 'Ingrese un número válido';
          return null;
        },
      ),
      FieldConfigData(
        controller: _userController,
        labelText: 'Usuario',
        iconData: Icons.person_outline,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Ingrese el usuario de BD'
            : null,
      ),
      FieldConfigData(
        controller: _passwordController,
        labelText: 'Contraseña',
        iconData: Icons.lock_outline,
        isObscure: _obscurePassword,
        onObscureToggle: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        validator: (value) => (value == null || value.isEmpty)
            ? 'Ingrese la contraseña de BD'
            : null,
      ),
    ];

    _enzonaFields = [
      FieldConfigData(
        controller: _enzonaConsumerKeyController,
        labelText: 'Consumer Key',
        iconData: Icons.vpn_key_outlined,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Ingrese el Consumer Key' : null,
      ),
      FieldConfigData(
        controller: _enzonaConsumerSecretController,
        labelText: 'Consumer Secret',
        iconData: Icons.security_outlined,
        isObscure: _obscureEnzonaConsumerSecret,
        onObscureToggle: () => setState(
            () => _obscureEnzonaConsumerSecret = !_obscureEnzonaConsumerSecret),
        validator: (value) => (value == null || value.isEmpty)
            ? 'Ingrese el Consumer Secret'
            : null,
      ),
      FieldConfigData(
        controller: _enzonaMerchantUuidController,
        labelText: 'Merchant UUID',
        iconData: Icons.store_mall_directory_outlined,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Ingrese el Merchant UUID'
            : null,
      ),
      FieldConfigData(
        controller: _enzonaReturnUrlController,
        labelText: 'URL de Retorno',
        iconData: Icons.link_outlined,
        keyboardType: TextInputType.url,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Ingrese la URL de Retorno';
          if (!Uri.tryParse(value)!.isAbsolute ?? true)
            return 'Ingrese una URL válida';
          return null;
        },
      ),
      FieldConfigData(
        controller: _enzonaCancelUrlController,
        labelText: 'URL de Cancelación',
        iconData: Icons.link_off_outlined,
        keyboardType: TextInputType.url,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Ingrese la URL de Cancelación';
          if (!Uri.tryParse(value)!.isAbsolute ?? true)
            return 'Ingrese una URL válida';
          return null;
        },
      ),
      FieldConfigData(
        controller: _enzonaTerminalIdController,
        labelText: 'Terminal ID (Opcional)',
        iconData: Icons.devices_other_outlined,
        isOptional: true,
      ),
    ];
  }

  @override
  void dispose() {
    _dbServerController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _enzonaConsumerKeyController.dispose();
    _enzonaConsumerSecretController.dispose();
    _enzonaMerchantUuidController.dispose();
    _enzonaReturnUrlController.dispose();
    _enzonaCancelUrlController.dispose();
    _enzonaTerminalIdController.dispose();
    super.dispose();
  }

  void _saveDBConfiguration() {
    if (_formKeyDB.currentState!.validate()) {
      // Lógica para guardar configuración de BD (ej. SharedPreferences)
      print('--- Configuración BD Guardada ---');
      for (var field in _dbFields) {
        print('${field.labelText}: ${field.controller.text}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Configuración de Base de Datos guardada (simulado)')),
      );
    }
  }

  void _saveEnzonaConfiguration() {
    if (_formKeyEnzona.currentState!.validate()) {
      // Lógica para guardar configuración de Enzona (ej. SharedPreferences)
      print('--- Configuración Enzona Guardada ---');
      for (var field in _enzonaFields) {
        print('${field.labelText}: ${field.controller.text}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Configuración de Enzona guardada (simulado)')),
      );
    }
  }

  ConfigTextFormField _buildFieldFromConfig(FieldConfigData config) {
    return ConfigTextFormField(
      controller: config.controller,
      text: config.labelText,
      icon: Icon(config.iconData),
      validator: config.isOptional
          ? null // No hay validador si es opcional
          : (config.validator ?? // Usa el validador provisto
              (value) {
                // O un validador por defecto si no se proveyó uno y no es opcional
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese ${config.labelText}';
                }
                return null;
              }),
      //keyboardType: config.keyboardType,
      obscureText: config.isObscure ?? false,
      suffix: config.onObscureToggle != null
          ? IconButton(
              icon: Icon(
                color: Colors.grey,
                (config.isObscure ?? false)
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: config.onObscureToggle,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: CustomAppBar(title: 'Configuración General'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            ConfigSectionWidget(
              title:
                  'Conexión a Servidor de Base de Datos externo (Contabilidad)',
              saveButtonText: 'Guardar',
              formKey: _formKeyDB,
              fieldConfigs: _dbFields,
              onSave: _saveDBConfiguration,
              isMobile: isMobile,
              fieldBuilder: _buildFieldFromConfig,
              nonMobileLayoutIndices: const [
                [0, 1, 2, 3]
              ], // 4 campos en una fila
            ),
            const SizedBox(height: 30.0),
            ConfigSectionWidget(
              title: 'Conexión a API Enzona',
              saveButtonText: 'Guardar',
              formKey: _formKeyEnzona,
              fieldConfigs: _enzonaFields,
              onSave: _saveEnzonaConfiguration,
              isMobile: isMobile,
              fieldBuilder: _buildFieldFromConfig,
              nonMobileLayoutIndices: const [
                [0, 1, 2],
                [3, 4, 5],
              ], // 2 campos por fila, 3 filas
            ),
          ],
        ),
      ),
    );
  }
}
