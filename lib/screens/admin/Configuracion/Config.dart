import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/ConfigTextFormField.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

// Clase para definir la configuración de cada campo
class FieldConfigData {
  final String key;
  final TextEditingController controller;
  final String labelText;
  final IconData iconData;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool isPasswordField;
  final bool isOptional;

  FieldConfigData({
    required this.key,
    required this.controller,
    required this.labelText,
    required this.iconData,
    this.validator,
    this.keyboardType,
    this.isPasswordField = false,
    this.isOptional = false,
  });
}

// (El widget ConfigSectionWidget no necesita cambios)
class ConfigSectionWidget extends StatelessWidget {
  final String title;
  final String saveButtonText;
  final GlobalKey<FormState> formKey;
  final List<FieldConfigData> fieldConfigs;
  final VoidCallback onSave;
  final bool isMobile;
  final Widget Function(FieldConfigData) fieldBuilder;
  final List<List<int>> nonMobileLayoutIndices;

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
              ? Button(
                  onPressed: onSave, text: saveButtonText, icon: Icons.save_alt)
              : Align(
                  alignment: Alignment.centerRight,
                  child: Button(
                    onPressed: onSave,
                    text: saveButtonText,
                    icon: Icons.save_alt,
                  ),
                ),
          const SizedBox(height: 24.0),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fieldConfigs
          .map((config) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: fieldBuilder(config),
              ))
          .toList(),
    );
  }

  Widget _buildNonMobileLayout() {
    List<Widget> rows = [];
    for (var rowIndices in nonMobileLayoutIndices) {
      List<Widget> fieldsInRow = [];
      for (int i = 0; i < rowIndices.length; i++) {
        int fieldIndex = rowIndices[i];
        if (fieldIndex < fieldConfigs.length) {
          fieldsInRow
              .add(Expanded(child: fieldBuilder(fieldConfigs[fieldIndex])));
          if (i < rowIndices.length - 1) {
            fieldsInRow.add(const SizedBox(width: 16.0));
          }
        }
      }
      rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: fieldsInRow));
      rows.add(const SizedBox(height: 16.0));
    }
    if (rows.isNotEmpty) rows.removeLast();
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
  final _formKeyLDAP = GlobalKey<FormState>();

  // Controladores
  final _dbServerController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _enzonaConsumerKeyController = TextEditingController();
  final _enzonaConsumerSecretController = TextEditingController();
  final _enzonaMerchantUuidController = TextEditingController();
  final _enzonaReturnUrlController = TextEditingController();
  final _enzonaCancelUrlController = TextEditingController();
  final _enzonaTerminalIdController = TextEditingController();
  final _ldapUrlController = TextEditingController();
  final _ldapBaseDnController = TextEditingController();
  final _ldapUserDnPatterns = TextEditingController();
  final _ldapGroupSearchBase = TextEditingController();
  final _ldapPasswordAttribute = TextEditingController();
  final _ldapUserDn = TextEditingController();
  final _ldapPassword = TextEditingController();

  final Map<String, bool> _obscureTextStates = {};

  late List<FieldConfigData> _dbFields;
  late List<FieldConfigData> _enzonaFields;
  late List<FieldConfigData> _ldapFields;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _dbFields = [
      FieldConfigData(
          key: 'db_server',
          controller: _dbServerController,
          labelText: 'Servidor de Base de Datos',
          iconData: Icons.dns),
      FieldConfigData(
          key: 'db_port',
          controller: _portController,
          labelText: 'Puerto',
          iconData: Icons.lan_outlined,
          keyboardType: TextInputType.number),
      FieldConfigData(
          key: 'db_user',
          controller: _userController,
          labelText: 'Usuario',
          iconData: Icons.person_outline),
      FieldConfigData(
          key: 'db_password',
          controller: _passwordController,
          labelText: 'Contraseña',
          iconData: Icons.vpn_key_outlined,
          isPasswordField: true),
    ];
    _enzonaFields = [
      FieldConfigData(
          key: 'enzona_key',
          controller: _enzonaConsumerKeyController,
          labelText: 'Clave de Consumidor (Consumer Key)',
          iconData: Icons.vpn_key_outlined,
          isPasswordField: true),
      FieldConfigData(
          key: 'enzona_secret',
          controller: _enzonaConsumerSecretController,
          labelText: 'Secreto de Consumidor (Consumer Secret)',
          iconData: Icons.vpn_key_outlined,
          isPasswordField: true),
      FieldConfigData(
          key: 'enzona_uuid',
          controller: _enzonaMerchantUuidController,
          labelText: 'UUID del Comercio (Merchant UUID)',
          iconData: Icons.store_mall_directory_outlined),
      FieldConfigData(
          key: 'enzona_return_url',
          controller: _enzonaReturnUrlController,
          labelText: 'URL de Retorno',
          iconData: Icons.link_outlined,
          keyboardType: TextInputType.url),
      FieldConfigData(
          key: 'enzona_cancel_url',
          controller: _enzonaCancelUrlController,
          labelText: 'URL de Cancelación',
          iconData: Icons.link_off_outlined,
          keyboardType: TextInputType.url),
      FieldConfigData(
          key: 'enzona_terminal_id',
          controller: _enzonaTerminalIdController,
          labelText: 'Terminal ID (Opcional)',
          iconData: Icons.devices_other_outlined,
          isOptional: true),
    ];
    _ldapFields = [
      FieldConfigData(
          key: 'ldap_url',
          controller: _ldapUrlController,
          labelText: 'URL',
          iconData: Icons.link),
      FieldConfigData(
          key: 'ldap_base_dn',
          controller: _ldapBaseDnController,
          labelText: 'Ruta de Búsqueda Base (DN Base)',
          iconData: Icons.account_tree),
      FieldConfigData(
          key: 'ldap_user_dn_patterns',
          controller: _ldapUserDnPatterns,
          labelText: 'Patrones de DN de Usuario (User DN Patterns)',
          iconData: Icons.pattern),
      FieldConfigData(
          key: 'ldap_group_search',
          controller: _ldapGroupSearchBase,
          labelText: 'Base de Búsqueda para Grupos (Group Search Base)',
          iconData: Icons.group),
      FieldConfigData(
          key: 'ldap_user_dn',
          controller: _ldapUserDn,
          labelText: 'DN del Usuario (User DN)',
          iconData: Icons.person_pin),
      FieldConfigData(
          key: 'ldap_password_attr',
          controller: _ldapPasswordAttribute,
          labelText: 'Atributos de Contraseña (Password Attribute)',
          iconData: Icons.vpn_key_outlined,
          isPasswordField: true),
      FieldConfigData(
          key: 'ldap_password',
          controller: _ldapPassword,
          labelText: 'Contraseña (Password)',
          iconData: Icons.vpn_key_outlined,
          isPasswordField: true),
    ];

    for (var field in [..._dbFields, ..._enzonaFields, ..._ldapFields]) {
      if (field.isPasswordField) {
        _obscureTextStates[field.key] = true;
      }
    }
  }

  @override
  void dispose() {
    final allFields = [..._dbFields, ..._enzonaFields, ..._ldapFields];
    for (var field in allFields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  void _saveDBConfiguration() {
    if (_formKeyDB.currentState!.validate()) {
      print('--- Configuración BD Guardada ---');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Configuración de Base de Datos guardada (simulado)')));
    }
  }

  void _saveEnzonaConfiguration() {
    if (_formKeyEnzona.currentState!.validate()) {
      print('--- Configuración Enzona Guardada ---');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Configuración de Enzona guardada (simulado)')));
    }
  }

  void _saveLDAPConfiguration() {
    if (_formKeyLDAP.currentState!.validate()) {
      print('--- Configuración LDAP Guardada ---');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Configuración de LDAP guardada (simulado)')));
    }
  }

  ConfigTextFormField _buildFieldFromConfig(FieldConfigData config) {
    final bool isPasswordField = config.isPasswordField;
    final bool isObscure = _obscureTextStates[config.key] ?? false;

    return ConfigTextFormField(
      controller: config.controller,
      text: config.labelText,
      icon: Icon(config.iconData),
      validator: config.isOptional
          ? null
          : (config.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese ${config.labelText}';
                }
                return null;
              }),
      obscureText: isObscure,
      suffix: isPasswordField
          ? IconButton(
              icon: Icon(
                color: Colors.grey,
                isObscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureTextStates[config.key] = !isObscure;
                });
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: CustomAppBar(
          title: isMobile ? 'Configuración' : 'Configuración General'),
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
              ],
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
                [3, 4, 5]
              ],
            ),
            const SizedBox(height: 30.0),
            ConfigSectionWidget(
              title: 'Conexión a LDAP',
              saveButtonText: 'Guardar',
              formKey: _formKeyLDAP,
              fieldConfigs: _ldapFields,
              onSave: _saveLDAPConfiguration,
              isMobile: isMobile,
              fieldBuilder: _buildFieldFromConfig,
              nonMobileLayoutIndices: const [
                [0],
                [1, 2, 3],
                [4, 5, 6]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
