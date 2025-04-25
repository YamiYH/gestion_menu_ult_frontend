import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/RolModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AccessDropDown.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/StatusDropDown.dart';

import '../../widgets/UserTextFormField.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  String selectedStatus = 'Todos';
  String selectedAccess = 'Todos';

  // Lista de usuarios simulada
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

  // --- Método para Editar Rol ---
  void _editRole(Map<String, dynamic> roleData) async {
    // Marcar como async
    // Navega a RolModelo pasando los datos y ESPERA un resultado
    final result = await Navigator.push(
      context,
      // Usa tu transición preferida
      createFadeRoute(RolModelo(initialData: roleData)), // Pasa initialData
    );

    // --- Procesa el resultado si el usuario guardó cambios ---
    if (result != null && result is Map<String, dynamic> && mounted) {
      // Busca el índice del rol original en la lista _roles
      final index = _roles.indexWhere((role) => role['id'] == result['id']);

      if (index != -1) {
        // Si se encontró, actualiza el rol en la lista principal
        setState(() {
          _roles[index] = result; // Reemplaza con los datos devueltos
          // Aplica filtros para que la lista visible se actualice
          _applyAllFilters();
        });
        // Opcional: Mostrar un SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rol "${result['name']}" actualizado con éxito.')),
        );
      }
    }
  }

  // --- Método para Eliminar Rol (con confirmación) ---
  void _deleteRole(int roleId, String roleName) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    // Recibe ID y nombre para el mensaje
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Usar un contexto diferente para el diálogo
        return AlertDialog(
          title: Center(
            child: Text('Confirmar Eliminación',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 20)),
          ),
          content:
              Text('¿Estás seguro de que quieres eliminar el rol "$roleName"?'),
          // Mensaje más específico
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCELAR',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[800]),
              // Estilo para el botón de eliminar
              child: Text('ELIMINAR',
                  style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16)),
              onPressed: () {
                setState(() {
                  // Elimina de la lista principal usando el ID
                  _roles.removeWhere((role) => role['id'] == roleId);
                  // Vuelve a aplicar los filtros para actualizar la lista visible
                  // Es importante llamar a _applyAllFilters para que la UI refleje
                  // tanto la eliminación como los filtros activos.
                  _applyAllFilters();
                });
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

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
  void initState() {
    super.initState();
    _filteredRoles = List.from(_roles);
    // Listener para búsqueda en tiempo real
    _searchController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyAllFilters);
    _searchController.dispose();
    super.dispose();
  }

  // --- PASO 2: Implementar Filtro Combinado ---
  void _applyAllFilters() {
    final nameQuery = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredRoles = _roles.where((role) {
        // Filtro por Nombre (role['role'])
        final nameMatch = nameQuery.isEmpty ||
            (role['role'] as String? ?? '').toLowerCase().contains(nameQuery);

        // Filtro por Estado (role['status'])
        final statusMatch = selectedStatus == 'Todos' ||
            (role['status'] as String? ?? '') == selectedStatus;

        // Filtro por Permiso (role['access'])
        final accessMatch;
        if (selectedAccess == 'Todos') {
          accessMatch =
              true; // Si se selecciona 'Todos', coincide con cualquier permiso
        } else {
          final roleAccess = role['access'];
          if (roleAccess is List) {
            // Si el rol tiene 'Todos' o la lista contiene el permiso seleccionado
            accessMatch = roleAccess.contains('Todos') ||
                roleAccess.contains(selectedAccess);
          } else if (roleAccess is String && roleAccess == 'Todos') {
            // Si el rol solo tiene 'Todos' como string
            accessMatch = true;
          } else {
            // Si no es lista y no es 'Todos', no coincide a menos que se seleccione 'Todos'
            accessMatch = false;
          }
        }

        // El rol pasa si cumple todas las condiciones
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

            // Encabezados de la tabla
            isMobile ? _buildHeaderMobile() : _buildHeaderRow(isMobile),

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
      ),
    );
  }

  List<Widget> _buildTextFormField() {
    return [
      UserTextFormField(text: 'Buscar rol', controller: _searchController),
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
    ];
  }

  Widget Status() {
    return StatusDropDown(
      selectedValue: selectedStatus, // La variable de estado de Roles
      onChanged: (newValue) {
        setState(() {
          selectedStatus = selectedStatus;
        });
        _applyAllFilters(); // Llama a tu función de filtrar roles
      },
      // No necesitas pasar 'options', usará ['Todos', 'Activo', 'Inactivo'] por defecto
      // validator: ... (añade si necesitas validar en la búsqueda)
    );
  }

  Widget Access() {
    return AccessDropDown(
      selectedValue: selectedAccess,
      onChanged: (String? newValue) {
        setState(() {
          selectedAccess = newValue!;
        });
        _applyAllFilters(); // Aplicar filtro al cambiar el valor
      },
    );
  }

  // Encabezados responsivos
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

  // Estilo para encabezados
  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
