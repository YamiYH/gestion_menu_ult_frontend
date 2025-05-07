import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/UserModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart';
import 'package:gestion_menu_ult_frontend/widgets/StatusDropDown.dart';
import 'package:gestion_menu_ult_frontend/widgets/TypeDropDown.dart';

import '../../routes/PageRouteBuilder.dart';
import '../../widgets/Confirm.dart';
import '../../widgets/UserTextFormField.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final List<Map<String, dynamic>> _users = [
    {
      'username': 'juanperez',
      'name': 'Juan',
      'lastname': 'Perez',
      'email': 'juanperez@gmail.com',
      'role': 'Estudiante',
      'status': 'Activo',
      'type': 'Employee'
    },
    {
      'username': 'mariaglez',
      'name': 'Maria',
      'lastname': 'Gonzalez',
      'email': 'mariaglez@gmail.com',
      'role': 'Profesor',
      'status': 'Inactivo',
      'type': 'Employee'
    },
    {
      'username': 'admin123',
      'name': 'Admin',
      'lastname': 'Admin',
      'email': 'admin123@gmail.com',
      'role': 'Administrador',
      'status': 'Activo',
      'type': 'System'
    },
  ];

  List<Map<String, dynamic>> _filteredUsers = [];

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String selectedStatus = 'Todos';
  String selectedUserType = 'Todos';

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_users);
    _usernameController.addListener(_applyAllFilters);
    _nameController.addListener(_applyAllFilters);
    _lastnameController.addListener(_applyAllFilters);
    _emailController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_applyAllFilters);
    _nameController.removeListener(_applyAllFilters);
    _lastnameController.removeListener(_applyAllFilters);
    _emailController.removeListener(_applyAllFilters);

    _usernameController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _applyAllFilters() {
    final usernameQuery = _usernameController.text.trim().toLowerCase();
    final nameQuery = _nameController.text.trim().toLowerCase();
    final lastnameQuery = _lastnameController.text.trim().toLowerCase();
    final emailQuery = _emailController.text.trim().toLowerCase();

    setState(() {
      _filteredUsers = _users.where((user) {
        final usernameMatch = usernameQuery.isEmpty ||
            (user['username'] as String? ?? '')
                .toLowerCase()
                .contains(usernameQuery);
        final nameMatch = nameQuery.isEmpty ||
            (user['name'] as String? ?? '').toLowerCase().contains(nameQuery);
        final lastnameMatch = lastnameQuery.isEmpty ||
            (user['lastname'] as String? ?? '')
                .toLowerCase()
                .contains(lastnameQuery);
        final emailMatch = emailQuery.isEmpty ||
            (user['email'] as String? ?? '').toLowerCase().contains(emailQuery);

        final statusMatch = selectedStatus == 'Todos' ||
            (user['status'] as String? ?? '') == selectedStatus;

        final typeMatch = selectedUserType == 'Todos' ||
            (user['type'] as String? ?? '') == selectedUserType;

        return usernameMatch &&
            nameMatch &&
            lastnameMatch &&
            emailMatch &&
            statusMatch &&
            typeMatch;
      }).toList();
    });
  }

  void _editUser(Map<String, dynamic> userData) async {
    final result = await Navigator.push(
      context,
      createFadeRoute(UserModelo()),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      final index = _users.indexWhere((user) => user['id'] == result['id']);

      if (index != -1) {
        setState(() {
          _users[index] = result;

          _applyAllFilters();
        });
        final displayName =
            result['username'] ?? result['name'] ?? 'ID: ${result['id']}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Usuario "$displayName" actualizado con éxito.')),
        );
      } else {
        print(
            "Usuario original con ID ${result['id']} no encontrado para actualizar.");
      }
    }
  }

  void _deleteUser(int userId, String userName) async {
    final bool? confirmed = await showConfirmDeleteDialog(
      context: context,
      itemName: userName,
      itemType: 'al usuario',
      onConfirm: () {
        setState(() {
          final int initialLength = _users.length;
          _users.removeWhere((user) => user['id'] == userId);
          final bool wasRemoved = _users.length < initialLength;
          if (wasRemoved) {
            print('Usuario con ID $userId eliminado.');

            _applyAllFilters();
          }
        });
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      print('Confirmada la eliminación del usuario: $userName');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario "$userName" eliminado con éxito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Usuarios'),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: isMobile
                  ? Column(children: [
                      SizedBox(height: 10, width: 10),
                      UserTextFormField(
                        text: 'Buscar Usuario',
                        controller: _usernameController,
                        // Asignar controller
                      ),
                      SizedBox(height: 10),
                      Row(
                        // Desplegables Status/Type
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Status(),
                          SizedBox(height: 20, width: 20),
                          Type(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          AddButton(
                              onPressed: () {
                                Navigator.push(
                                    context, createFadeRoute(UserModelo()));
                              },
                              text: 'Usuario',
                              size: Size(
                                  isMobile
                                      ? MediaQuery.of(context).size.width * 0.35
                                      : 150,
                                  50))
                        ],
                      ),
                      SizedBox(height: 10),
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _buildTextFormField(isMobile),
                    )),
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length, // Usar lista filtrada
              itemBuilder: (context, index) {
                final user = _filteredUsers[index]; // Usar lista filtrada
                return Column(
                  children: [
                    SingleChildScrollView(
                        child: isMobile
                            ? _buildUserRowMobile(user)
                            : _buildUserRow(user)),
                    Divider()
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        // Paginación (sin cambios funcionales aquí)
        itemBuilder: (context, item) {
          return ListTile(
            title: Text(item as String),
          );
        },
      ),
    );
  }

  List<Widget> _buildTextFormField(isMobile) {
    return [
      SizedBox(width: 5),
      Expanded(
        child: UserTextFormField(
          text: 'Usuario',
          controller: _usernameController,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Nombre',
          controller: _nameController,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Apellido',
          controller: _lastnameController,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Correo',
          controller: _emailController,
        ),
      ),
      SizedBox(width: 10),
      Status(),
      SizedBox(width: 10),
      Type(),
      SizedBox(width: 10),
    ];
  }

  Widget Type() {
    return TypeDropDown(
      selectedValue: selectedUserType,
      onChanged: (String? newValue) {
        setState(() {
          selectedUserType = newValue!;
        });
        _applyAllFilters();
      },
    );
  }

  Widget Status() {
    return StatusDropDown(
      selectedValue: selectedStatus,
      onChanged: (String? newValue) {
        setState(() {
          selectedStatus = newValue!;
        });
        _applyAllFilters();
      },
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _header('Usuario', 0.15),
          _header('Nombre', 0.15),
          _header('Apellidos', 0.15),
          _header('Correo', 0.15),
          _header('Estado', 0.1),
          _header('Tipo', 0.1),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: AddButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    createFadeRoute(
                      UserModelo(),
                    ),
                  );
                },
                text: 'Usuario',
                size: Size(150, 40)),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, double widthFactor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 25, // Altura fija
      child: Text(title, style: _headerStyle()),
    );
  }

  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuir espacio
        children: [
          Expanded(flex: 3, child: Text('Usuario', style: _headerStyle())),
          Expanded(
              flex: 2,
              child: Text('Estado',
                  style: _headerStyle(), textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text('Tipo',
                  style: _headerStyle(), textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text('Acciones',
                  style: _headerStyle(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildUserRowMobile(Map<String, dynamic> user) {
    final int userId = user['id'] ?? -1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 3,
              child: Text(user['username'] ?? 'N/A',
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 2,
              child:
                  Text(user['status'] ?? 'N/A', textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text(user['type'] ?? 'N/A', textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.edit, color: Colors.grey.shade500, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      _editUser(user);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      _deleteUser(
                          userId, user as String); // Llamar a borrar con ID
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _user(user['username'], 0.15),
          _user(user['name'], 0.15),
          _user(user['lastname'], 0.15),
          _user(user['email'], 0.15),
          _user(user['status'], 0.1),
          _user(user['type'], 0.1),
          Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey.shade500),
                  onPressed: () {
                    _editUser(user);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final int userId = user['id'] ?? -1;
                    final String nameForDialog =
                        user['username'] ?? 'ID: $userId';

                    if (userId != -1) {
                      _deleteUser(userId, nameForDialog);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        ],
      ),
    );
  }

  Widget _user(String? text, double widthFactor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(text ?? 'N/A', overflow: TextOverflow.ellipsis),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
