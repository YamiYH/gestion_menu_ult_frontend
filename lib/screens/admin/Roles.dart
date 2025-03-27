import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/FilterButton.dart';
import '../../widgets/UserTextFormField.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  String selectedStatus = 'Todos'; // Estado seleccionado
  String selectedUserType = 'Todos'; // Tipo de usuario seleccionado

  // Lista de usuarios simulada
  final List<Map<String, dynamic>> _roles = [
    {
      'role': 'Administrador',
      'status': 'Activo',
      'description': 'Admin del sistema',
      'access': ['Todos']
    },
    {
      'role': 'Tecnico',
      'status': 'Inactivo',
      'description': 'Gestiona menus',
      'access': ['Inventario', 'Menu']
    },
    {
      'role': 'Contador',
      'status': 'Activo',
      'description': 'Aprueba menus',
      'access': ['Menu', 'Ventas']
    },
  ];

  String formatAccess(dynamic access) {
    if (access is List) {
      return access.join(', '); // Formato simple
    }
    return access.toString(); // Si no es una lista, convierte a cadena
  }

  // Lista filtrada y control de selección múltiple
  List<Map<String, dynamic>> _filteredRoles = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Roles'),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: isMobile
                  ? Column(children: [
                      SizedBox(height: 10, width: 10),
                      Usertextformfield(
                          text: 'Nombre', onChanged: _applySearch),
                      SizedBox(height: 15),
                      Status(),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilterButton(
                            onPressed: _applySearchWrapper,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.07),
                          AddButton(onPressed: () {}, text: 'Rol')
                        ],
                      ),
                      SizedBox(height: 10),
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildTextFormField(),
                    )),

          // Encabezados de la tabla
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),

          // Lista de usuarios
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRoles.length,
              itemBuilder: (context, index) {
                final role = _filteredRoles[index];
                return Column(
                  children: [
                    SingleChildScrollView(
                        child: isMobile
                            ? _buildUserRowMobile(role)
                            : _buildUserRow(role)),
                    Divider()
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredRoles = List.from(_roles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para aplicar el filtro de búsqueda
  void _applySearch(String query) {
    setState(() {
      _filteredRoles = _roles.where((user) {
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
      _filteredRoles = _roles.where((user) {
        bool matchesStatus = selectedStatus == 'Todos' ||
            user['active'] == (selectedStatus == 'Activo');
        bool matchesUserType =
            selectedUserType == 'Todos' || user['role'] == selectedUserType;

        return matchesStatus && matchesUserType;
      }).toList();
    });
  }

  List<Widget> _buildTextFormField() {
    return [
      Usertextformfield(text: 'Nombre', onChanged: _applySearch),
      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
      Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Access(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Status(),
        ],
      ),
      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
      FilterButton(
        onPressed: _applySearchWrapper,
      ),
      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
      AddButton(onPressed: () {}, text: 'Rol')
    ];
  }

  Widget Status() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.50
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget Access() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.50
          : MediaQuery.of(context).size.width * 0.15,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Permisos:',
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
            items: ['Todos', 'Menu', 'Tickets', 'Inventario']
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
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 25,
            child: Text('Nombre', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 25,
            child: Text('Permisos', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 25,
            child: Text('Estado', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            height: 25,
            child: Text('Descripción', style: _headerStyle()),
          ),
        ],
      ),
    );
  }

  // Fila de usuario
  Widget _buildUserRow(Map<String, dynamic> role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          height: 20,
          child: Text(role['role']),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.20,
          height: 20,
          child: Text(formatAccess(role['access'])),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 20,
            child: Text(role['status'])),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          height: 20,
          child: Text(role['description']),
        ),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey.shade500),
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-user/${role['id']}');
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _roles.removeWhere((u) => u['id'] == role['id']);
                    _filteredRoles = List.from(_roles);
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02)
      ],
    );
  }

  // Encabezados responsivos
  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            height: 25,
            child: Text('Nombre', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            height: 25,
            child: Text('Estado', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            height: 25,
            child: Text('Acciones', style: _headerStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRowMobile(Map<String, dynamic> role) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              height: 20,
              child: Text(role['role']),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              height: 20,
              child: Text(role['status']),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey.shade500),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-user/${role['id']}');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _roles.removeWhere((u) => u['id'] == role['id']);
                        _filteredRoles = List.from(_roles);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
