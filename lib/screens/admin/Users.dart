import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';

import '../../widgets/Button.dart';
import '../../widgets/FilterButton.dart';
import '../../widgets/UserTextFormField.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String selectedStatus = 'Todos'; // Estado seleccionado
  String selectedUserType = 'Todos'; // Tipo de usuario seleccionado

  // Lista de usuarios simulada
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
    // ... (agrega más usuarios)
  ];

  // Lista filtrada y control de selección múltiple
  List<Map<String, dynamic>> _filteredUsers = [];
  List<int> _selectedUserIds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_users);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para aplicar el filtro de búsqueda
  void _applySearch(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['username'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _applySearchWrapper() {
    _applySearch('');
  }

  // Filtrar usuarios según el estado y tipo seleccionados
  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        bool matchesStatus = selectedStatus == 'Todos' ||
            user['active'] == (selectedStatus == 'Activo');
        bool matchesUserType =
            selectedUserType == 'Todos' || user['role'] == selectedUserType;

        return matchesStatus && matchesUserType;
      }).toList();
    });
  }

  // Función para eliminar usuarios seleccionados
  void _deleteSelectedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Eliminar ${_selectedUserIds.length} usuarios?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere(
                    (user) => _selectedUserIds.contains(user['id']));
                _filteredUsers = List.from(_users);
                _selectedUserIds.clear();
              });
              Navigator.of(context).pop();
            },
            child: Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 20 : 25,
            )),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: isMobile
                  ? Column(children: [
                      SizedBox(height: 10, width: 10),
                      Usertextformfield(
                          text: 'Usuario', onChanged: _applySearch),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Status(),
                          SizedBox(height: 20, width: 20),
                          Type(),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilterButton(
                            text: 'Filtrar',
                            onPressed: _applySearchWrapper,
                            icon: Icons.filter_alt,
                          ),
                          SizedBox(width: 10),
                          AddButton(onPressed: () {}, text: 'Agregar usuario')
                        ],
                      ),
                      SizedBox(height: 10),
                    ])
                  : Row(
                      children: _buildTextFormField(),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )),

          // Encabezados de la tabla
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),
          const Divider(),
          // Lista de usuarios

          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: isMobile
                        ? _buildUserRowMobile(user)
                        : _buildUserRow(user));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTextFormField() {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return [
      SizedBox(height: isMobile ? 10 : 15, width: isMobile ? 10 : 5),
      Usertextformfield(text: 'Usuario', onChanged: _applySearch),
      SizedBox(height: 10, width: 10),
      Usertextformfield(text: 'Nombre', onChanged: _applySearch),
      SizedBox(height: 10, width: 10),
      Usertextformfield(text: 'Apellido', onChanged: _applySearch),
      SizedBox(height: 10, width: 10),
      Usertextformfield(text: 'Correo', onChanged: _applySearch),
      SizedBox(height: 10, width: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Status(),
          SizedBox(height: 20, width: 20),
          Type(),
        ],
      ),
      SizedBox(height: 10, width: 10),
      Button(
          text: 'Filtrar',
          onPressed: _applySearchWrapper,
          icon: Icons.filter_alt),
      SizedBox(height: 20),
    ];
  }

  Widget Type() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.1,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tipo:',
            style: TextStyle(
                fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedUserType,
            onChanged: (String? newValue) {
              setState(() {
                selectedUserType = newValue!;
              });
              _filterUsers(); // Aplicar filtro al cambiar el valor
            },
            items: ['Todos', 'System', 'Employee']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget Status() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.1,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Estado:',
            style: TextStyle(
                fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedStatus,
            onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue!;
              });
              _filterUsers(); // Aplicar filtro al cambiar el valor
            },
            items: ['Todos', 'Activo', 'Inactivo']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Encabezados responsivos
  Widget _buildHeaderRow() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          SizedBox(
            child: Text('Usuario', style: _headerStyle()),
            width: isMobile ? 50 : 200,
            height: 25,
          ),
          SizedBox(
            child: Text('Nombre', style: _headerStyle()),
            width: isMobile ? 50 : 250,
            height: 25,
          ),
          SizedBox(
            child: Text('Apellidos', style: _headerStyle()),
            width: isMobile ? 50 : 250,
            height: 25,
          ),
          SizedBox(
            child: Text('Correo', style: _headerStyle()),
            width: isMobile ? 50 : 250,
            height: 25,
          ),
          SizedBox(
            child: Text('Estado', style: _headerStyle()),
            width: isMobile ? 50 : 200,
            height: 25,
          ),
          SizedBox(
            child: Text('Tipo', style: _headerStyle()),
            width: isMobile ? 50 : 120,
            height: 25,
          ),
          AddButton(onPressed: () {}, text: 'Agregar usuario')
        ],
      ),
    );
  }

  // Encabezados responsivos
  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          SizedBox(
            child: Text('Usuario', style: _headerStyle()),
            width: 120,
            height: 20,
          ),
          SizedBox(
            child: Text('Estado', style: _headerStyle()),
            width: 90,
            height: 20,
          ),
          SizedBox(
            child: Text('Tipo', style: _headerStyle()),
            width: 60,
            height: 20,
          ),
          SizedBox(
            child: Text('Acciones', style: _headerStyle()),
            width: 80,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUserRowMobile(Map<String, dynamic> user) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Text(user['username']),
                width: 120,
                height: 20,
              ),
              SizedBox(
                child: Text(user['status']),
                width: 90,
                height: 20,
              ),
              SizedBox(
                child: Text(user['type']),
                width: 60,
                height: 20,
              ),
              SizedBox(width: 3),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey.shade500),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/edit-user/${user['id']}');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _users.removeWhere((u) => u['id'] == user['id']);
                          _filteredUsers = List.from(_users);
                        });
                      },
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Fila de usuario
  Widget _buildUserRow(Map<String, dynamic> user) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Text(user['username']),
                width: isMobile ? 50 : 200,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Text(user['name']),
                width: isMobile ? 50 : 250,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Text(user['lastname']),
                width: isMobile ? 50 : 250,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Text(user['email']),
                width: isMobile ? 50 : 250,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Text(user['status']),
                width: isMobile ? 50 : 200,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Text(user['type']),
                width: isMobile ? 50 : 200,
                height: isMobile ? 10 : 30,
              ),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey.shade500),
                      onPressed: () {
                        // Lógica para editar usuario
                        Navigator.pushNamed(
                            context, '/edit-user/${user['id']}');
                      },
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _users.removeWhere((u) => u['id'] == user['id']);
                          _filteredUsers = List.from(_users);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Estilo para encabezados
  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
