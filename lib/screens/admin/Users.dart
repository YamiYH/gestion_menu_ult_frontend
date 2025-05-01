import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/UserModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart'; // Asegúrate que las rutas sean correctas
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
  // --- PASO 1: Añadir IDs y Controladores ---
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1, // Añadido ID
      'username': 'juanperez',
      'name': 'Juan',
      'lastname': 'Perez',
      'email': 'juanperez@gmail.com',
      'role': 'Estudiante', // Mantenemos role por si se usa en otro lado
      'status': 'Activo',
      'type': 'Employee' // Añadido Type (o asegúrate que exista)
    },
    {
      'id': 2, // Añadido ID
      'username': 'mariaglez',
      'name': 'Maria',
      'lastname': 'Gonzalez',
      'email': 'mariaglez@gmail.com',
      'role': 'Profesor',
      'status': 'Inactivo',
      'type': 'Employee'
    },
    {
      'id': 3, // Añadido ID
      'username': 'admin123',
      'name': 'Admin',
      'lastname': 'Admin',
      'email': 'admin123@gmail.com',
      'role': 'Administrador',
      'status': 'Activo',
      'type': 'System'
    },
    // ... (agrega más usuarios con IDs únicos)
  ];

  List<Map<String, dynamic>> _filteredUsers = [];

  // Controladores para cada campo de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String selectedStatus = 'Todos'; // Estado seleccionado
  String selectedUserType = 'Todos'; // Tipo de usuario seleccionado

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_users); // Inicializar con todos los usuarios
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
        // Comprobaciones de texto (solo si el campo no está vacío)
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

        // Comprobación de estado (corregida)
        final statusMatch = selectedStatus == 'Todos' ||
            (user['status'] as String? ?? '') == selectedStatus;

        // Comprobación de tipo (corregida - usando campo 'type')
        final typeMatch = selectedUserType == 'Todos' ||
            (user['type'] as String? ?? '') == selectedUserType;

        // El usuario pasa si cumple todas las condiciones
        return usernameMatch &&
            nameMatch &&
            lastnameMatch &&
            emailMatch &&
            statusMatch &&
            typeMatch;
      }).toList();
    });
    print(
        'Filtros aplicados. Resultados: ${_filteredUsers.length}'); // Opcional: Debug
  }

  // --- Método para Editar Usuario ---
  void _editUser(Map<String, dynamic> userData) async {
    final result = await Navigator.push(
      context,

      createFadeRoute(UserModelo()), // Navega a UserModelo y pasa initialData
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      final index = _users.indexWhere((user) => user['id'] == result['id']);

      if (index != -1) {
        setState(() {
          _users[index] = result;

          _applyAllFilters(); // Llama a la función de filtrado de USUARIOS
        });
        // Opcional: Mostrar un SnackBar de éxito
        // Usa un campo apropiado como 'username' o 'name' para el mensaje
        final displayName =
            result['username'] ?? result['name'] ?? 'ID: ${result['id']}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Usuario "$displayName" actualizado con éxito.')),
        );
      } else {
        // Opcional: Manejar caso si el usuario original no se encontró (poco probable)
        print(
            "Usuario original con ID ${result['id']} no encontrado para actualizar.");
        // Podrías añadir el usuario 'result' como nuevo si esa fuera la lógica deseada
        // setState(() {
        //   _users.add(result);
        //   _applyAllFilters();
        // });
      }
    }
  }

  void _deleteUser(int userId, String userName) async {
    // Marcar como async
    // Llama a la función reutilizable del diálogo
    final bool? confirmed = await showConfirmDeleteDialog(
      context: context,
      itemName: userName, // Pasa el nombre/username del usuario
      itemType: 'al usuario', // Pasa el tipo de ítem para el mensaje
      onConfirm: () {
        setState(() {
          final int initialLength = _users.length;
          _users.removeWhere((user) => user['id'] == userId);
          final bool wasRemoved = _users.length < initialLength;
          if (wasRemoved) {
            print('Usuario con ID $userId eliminado.');

            _applyAllFilters(); // Llama a la función de filtrado de USUARIOS
          }
        });
      },
    );

    if (!mounted) return; // Verifica si el widget sigue montado

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
                      // --- Layout Desktop ---
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // --- Layout Desktop ---
                      children: _buildTextFormField(isMobile),
                    )),

          // Encabezados de la tabla
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),

          // Lista de usuarios
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
      SizedBox(width: 5), // Espacio inicial
      Expanded(
        child: UserTextFormField(
          text: 'Usuario',
          // onChanged: _applySearch, // ELIMINADO
          controller: _usernameController, // Asignar controller correcto
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Nombre',
          // onChanged: _applySearch, // ELIMINADO
          controller: _nameController, // Asignar controller correcto
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Apellido',
          // onChanged: _applySearch, // ELIMINADO
          controller: _lastnameController, // Asignar controller correcto
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: UserTextFormField(
          text: 'Correo',
          // onChanged: _applySearch, // ELIMINADO
          controller: _emailController, // Asignar controller correcto
        ),
      ),
      SizedBox(width: 10),
      // Widgets de Status y Type (sin cambios internos)
      Status(),
      SizedBox(width: 10),
      Type(),
      SizedBox(width: 10),
    ];
  }

  // Widget para desplegable de Tipo (Corregido: Quitar llamada a _filterUsers)
  Widget Type() {
    // Simplificado un poco el SizedBox, ajusta si es necesario
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

  // Widget para desplegable de Estado (Corregido: Quitar llamada a _filterUsers)
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

  // --- Widgets de Cabecera y Fila (Ajustes menores) ---

  // Encabezados Desktop (Corregido: Quitar AddButton duplicado)
  Widget _buildHeaderRow() {
    // isMobile no se usa aquí realmente
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _headerCell('Usuario', 0.15),
          _headerCell('Nombre', 0.15),
          _headerCell('Apellidos', 0.15),
          _headerCell('Correo', 0.15),
          _headerCell('Estado', 0.1),
          _headerCell('Tipo', 0.1),
          Spacer(), // Ocupa espacio restante
          // AddButton ELIMINADO de aquí
          Padding(
            // Botón Añadir al final de la cabecera
            padding: const EdgeInsets.only(right: 20.0),
            // Añadir padding a la derecha
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
                size: Size(150, 40) // Tamaño ajustado
                ),
          ),
        ],
      ),
    );
  }

  // Helper para celdas de cabecera
  Widget _headerCell(String title, double widthFactor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 25, // Altura fija
      child: Text(title, style: _headerStyle()),
    );
  }

  // Encabezados Móvil (Sin cambios mayores necesarios)
  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      // Ajustar padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuir espacio
        children: [
          Expanded(flex: 3, child: Text('Usuario', style: _headerStyle())),
          // Usar Expanded con flex
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

  // Fila de Usuario Móvil (Ajustado para usar _deleteUser con ID)
  Widget _buildUserRowMobile(Map<String, dynamic> user) {
    final int userId =
        user['id'] ?? -1; // Obtener ID (o valor por defecto si falta)
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
                // Botones de acción
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

  // Fila de Usuario Desktop (Ajustado para usar _deleteUser con ID)
  Widget _buildUserRow(Map<String, dynamic> user) {
    final int userId = user['id'] ?? -1; // Obtener ID
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        // Usar Expanded para las celdas para mejor alineación con cabecera flexible
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.01), // Espacio inicial pequeño
          _userCell(user['username'], 0.15),
          _userCell(user['name'], 0.15),
          _userCell(user['lastname'], 0.15),
          _userCell(user['email'], 0.15),
          _userCell(user['status'], 0.1),
          _userCell(user['type'], 0.1),
          Spacer(), // Ocupa espacio hasta los botones
          // Botones de Acción
          SizedBox(
            width: MediaQuery.of(context).size.width *
                0.1, // Ancho fijo para botones
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey.shade500),
                  onPressed: () {
                    _editUser(user);
                  },
                ),
                // SizedBox(width: 5), // Espacio entre botones
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final int userId =
                        user['id'] ?? -1; // Esto debería ser un int (correcto)
                    final String nameForDialog = user['username'] ??
                        'ID: $userId'; // <-- ¿Es user['username'] SIEMPRE un String?
                    // ----------------------
                    if (userId != -1) {
                      _deleteUser(userId,
                          nameForDialog); // _deleteUser espera (int, String)
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.01), // Espacio final pequeño
        ],
      ),
    );
  }

  // Helper para celdas de datos de usuario
  Widget _userCell(String? text, double widthFactor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(text ?? 'N/A', overflow: TextOverflow.ellipsis),
    );
  }

  // Estilo para encabezados (Sin cambios)
  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
