import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Lista de usuarios simulada
  List<Map<String, dynamic>> _users = [
    {'id': 1, 'username': 'juan_perez', 'role': 'Estudiante'},
    {'id': 2, 'username': 'maria_gomez', 'role': 'Profesor'},
    {'id': 3, 'username': 'admin123', 'role': 'Administrador'},
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Lógica para agregar usuario
              Navigator.pushNamed(context, '/add-user');
            },
          ),
          if (_selectedUserIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.white),
              onPressed: _deleteSelectedUsers,
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: isMobile ? MediaQuery.of(context).size.width * 0.85 : 200,
              height: isMobile ? 65 : 50,
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar usuario',
                  prefixIcon: Icon(Icons.search, color: Colors.red[900]),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _applySearch(value),
              ),
            ),
          ),
          // Encabezados de la tabla
          _buildHeaderRow(),
          const Divider(),
          // Lista de usuarios
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildUserRow(user));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Encabezados responsivos
  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text('Usuario', style: _headerStyle()),
          Text('Rol', style: _headerStyle()),
          Checkbox(
            value: _selectedUserIds.length == _filteredUsers.length &&
                _filteredUsers.isNotEmpty,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedUserIds =
                      _filteredUsers.map((u) => u['id'] as int).toList();
                } else {
                  _selectedUserIds.clear();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Fila de usuario
  Widget _buildUserRow(Map<String, dynamic> user) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Text(user['username']),
              ),
              SizedBox(child: Text(user['role'])),
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
