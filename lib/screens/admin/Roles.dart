import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/RolModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AccessDropDown.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/StatusDropDown.dart';

import '../../widgets/Confirm.dart';
import '../../widgets/UserTextFormField.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  String selectedStatus = 'Todos';
  String selectedAccess = 'Todos';

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 1,
      'role': 'Administrador',
      'status': 'Activo',
      'description': 'Admin del sistema',
      'access': ['Todos']
    },
    {
      'id': 2,
      'role': 'Tecnico',
      'status': 'Inactivo',
      'description': 'Gestiona menus',
      'access': ['Inventario', 'Menu']
    },
    {
      'id': 3,
      'role': 'Contador',
      'status': 'Activo',
      'description': 'Aprueba menus',
      'access': ['Menu', 'Ventas']
    },
  ];

  void _editRole(Map<String, dynamic> roleData) async {
    final result = await Navigator.push(
      context,
      createFadeRoute(RolModelo(initialData: roleData)),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      final index = _roles.indexWhere((role) => role['id'] == result['id']);

      if (index != -1) {
        setState(() {
          _roles[index] = result;

          _applyAllFilters();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rol "${result['name']}" actualizado con éxito.')),
        );
      }
    }
  }

  void _deleteRole(int roleId, String roleName) async {
    await showConfirmDeleteDialog(
      context: context,
      itemName: roleName,
      itemType: 'el rol',
      onConfirm: () {
        setState(() {
          _roles.removeWhere((role) => role['id'] == roleId);

          _applyAllFilters();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rol "$roleName" eliminado.')),
          );
        }
      },
    );
  }

  String formatAccess(dynamic access) {
    if (access is List) {
      return access.join(', ');
    }
    return access.toString();
  }

  List<Map<String, dynamic>> _filteredRoles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredRoles = List.from(_roles);

    _searchController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyAllFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyAllFilters() {
    final nameQuery = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredRoles = _roles.where((role) {
        final nameMatch = nameQuery.isEmpty ||
            (role['role'] as String? ?? '').toLowerCase().contains(nameQuery);

        final statusMatch = selectedStatus == 'Todos' ||
            (role['status'] as String? ?? '') == selectedStatus;

        final accessMatch;
        if (selectedAccess == 'Todos') {
          accessMatch = true;
        } else {
          final roleAccess = role['access'];
          if (roleAccess is List) {
            accessMatch = roleAccess.contains('Todos') ||
                roleAccess.contains(selectedAccess);
          } else if (roleAccess is String && roleAccess == 'Todos') {
            accessMatch = true;
          } else {
            accessMatch = false;
          }
        }

        return nameMatch && statusMatch && accessMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Roles'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: isMobile
                    ? Column(children: [
                        SizedBox(height: 10, width: 10),
                        UserTextFormField(
                            text: 'Buscar rol', controller: _searchController),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Status(),
                            SizedBox(width: 10),
                            AddButton(
                                onPressed: () {
                                  Navigator.push(
                                      context, createFadeRoute(RolModelo()));
                                },
                                text: 'Rol',
                                size: Size(
                                    isMobile
                                        ? MediaQuery.of(context).size.width *
                                            0.35
                                        : 150,
                                    50))
                          ],
                        ),
                        SizedBox(height: 10),
                      ])
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildTextFormField(),
                      )),

            isMobile ? _buildHeaderMobile() : _buildHeaderRow(isMobile),

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
      ),
    );
  }

  List<Widget> _buildTextFormField() {
    return [
      UserTextFormField(text: 'Buscar rol', controller: _searchController),
      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Access(),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Status(),
        ],
      ),
    ];
  }

  Widget Status() {
    return StatusDropDown(
      selectedValue: selectedStatus,
      onChanged: (newValue) {
        setState(() {
          selectedStatus = selectedStatus;
        });
        _applyAllFilters();
      },
    );
  }

  Widget Access() {
    return AccessDropDown(
      selectedValue: selectedAccess,
      onChanged: (String? newValue) {
        setState(() {
          selectedAccess = newValue!;
        });
        _applyAllFilters();
      },
    );
  }

  Widget _buildHeaderRow(bool isMobile) {
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
            child: Text('Accesos', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 25,
            child: Text('Estado', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 25,
            child: Text('Descripción', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
            height: 25,
          ),
          AddButton(
              onPressed: () {
                Navigator.push(context, createFadeRoute(RolModelo()));
              },
              text: 'Rol',
              size: Size(
                  isMobile ? MediaQuery.of(context).size.width * 0.35 : 150,
                  50))
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                  _editRole(role);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteRole(role['id'], role['role']);
                },
              ),
            ],
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02)
      ],
    );
  }

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
                      _editRole(role);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteRole(role['id'], role['role']);
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

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
