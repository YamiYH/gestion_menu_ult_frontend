import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/UserModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart';
import 'package:gestion_menu_ult_frontend/widgets/StatusDropDown.dart';
import 'package:gestion_menu_ult_frontend/widgets/TypeDropDown.dart';

import '../../controllers/security/RoleController.dart';
import '../../controllers/security/user/UserController.dart';
import '../../models/UserEntity.dart';
import '../../routes/PageRouteBuilder.dart';
import '../../widgets/Button.dart';
import '../../widgets/Confirm.dart';
import '../../widgets/RoleDropDown.dart';
import '../../widgets/UserTextFormField.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final UserController _userController = UserController();
  final RoleController _roleController = RoleController();
  List<User> _users = [];

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedStatus = 'Todos';
  String _selectedUserType = 'Todos';
  String _selectedRole = 'Todos';

  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _debounce;

  List<String> _availableRoles = ['Todos'];
  List<String> _availableTypes = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadDropdownData();
    _usernameController.addListener(_onSearchChanged);
    _nameController.addListener(_onSearchChanged);
    _lastnameController.addListener(_onSearchChanged);
    _emailController.addListener(_onSearchChanged);
  }

  // NUEVO MÉTODO: Carga los datos de los filtros solo una vez.
  Future<void> _loadDropdownData() async {
    try {
      // Ejecuta ambas llamadas en paralelo para mayor eficiencia
      final results = await Future.wait([
        _roleController.fetchRoleNames(),
        _userController.fetchUserTypes(),
      ]);

      // Asigna los resultados de forma limpia, evitando duplicados.
      setState(() {
        _availableRoles = ['Todos', ...results[0]];
        _availableTypes = ['Todos', ...results[1]];
      });
    } catch (e) {
      if (mounted) {
        // Maneja el error si los filtros no se pueden cargar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al cargar opciones de filtro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(_onSearchChanged);
    _nameController.removeListener(_onSearchChanged);
    _lastnameController.removeListener(_onSearchChanged);
    _emailController.removeListener(_onSearchChanged);
    _usernameController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    _userController.currentPage = 0;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Llama a la búsqueda con los filtros actuales y espera el resultado.
      final filteredUsers = await _fetchUsersWithCurrentFilters();

      // Actualiza el estado de la UI con la nueva lista de usuarios.
      if (mounted) {
        setState(() {
          _users = filteredUsers;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos: ${e.toString()}';
          _users = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Nuevo método helper para mantener _loadInitialData más limpio
  Future<List<User>> _fetchUsersWithCurrentFilters() {
    final Map<String, String> filters = {};
    if (_usernameController.text.isNotEmpty) {
      filters['username'] = _usernameController.text;
    }
    if (_nameController.text.isNotEmpty) filters['name'] = _nameController.text;
    if (_lastnameController.text.isNotEmpty) {
      filters['lastName'] = _lastnameController.text;
    }
    if (_emailController.text.isNotEmpty) {
      filters['email'] = _emailController.text;
    }
    if (_selectedStatus != 'Todos') {
      filters['enabled'] = (_selectedStatus).toString();
    }
    if (_selectedUserType != 'Todos') filters['type'] = _selectedUserType;
    if (_selectedRole != 'Todos') filters['role'] = _selectedRole;

    //debugPrint("Filtros que se enviarán al backend: $filters");
    return _userController.fetchUsers(filters: filters);
  }

  void _editUser(User userData) async {
    // Convierte el objeto User a un Map compatible con la pantalla UserModelo
    final initialDataMap = {
      'username': userData.username,
      'name': userData.name,
      'lastname': userData.lastName,
      'email': userData.email,
      'role': userData.mainRoleDescription,
      'enabled': userData.enabled ? 'Activo' : 'Inactivo',
      'type': userData.type,
    };

    final result = await Navigator.push(
      context,
      createFadeRoute(UserModelo(initialData: initialDataMap)),
    );

    if (result != null && mounted) {
      // Cuando volvemos, recargamos la lista para ver los cambios del backend
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    _triggerSearch(); // Reutilizamos el método de búsqueda para recargar
  }

  void _deleteUser(String username) async {
    await showConfirmDeleteDialog(
      context: context,
      itemName: username,
      itemType: 'al usuario',
      onConfirm: () async {
        if (!mounted) return;

        try {
          await _userController.deleteUser(username);

          // 3. Si sigue montado, mostramos el feedback de éxito
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Usuario "$username" eliminado correctamente.'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // 4. Recargamos la lista de usuarios para reflejar el cambio
          _loadUsers();
        } catch (e) {
          // 5. Si algo falla, lo capturamos y mostramos un error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar el usuario: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
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
            child: _buildFilterSection(isMobile),
          ),
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.red,
                  ))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center))
                    : _users.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(70),
                            child: Text(
                                'No se encontraron usuarios con los filtros aplicados.',
                                style: TextStyle(fontSize: 16)))
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Column(
                                children: [
                                  isMobile
                                      ? _buildUserRowMobile(user)
                                      : _buildUserRow(user),
                                  const Divider(height: 1),
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        currentPage: _userController.currentPage,
        totalPages: _userController.totalPages,
        itemsPerPage: _userController.pageSize,
        onPageChanged: (newPage) {
          if (_userController.currentPage != newPage) {
            _userController.currentPage = newPage;
            _loadInitialData();
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_userController.pageSize != newSize) {
            _userController.pageSize = newSize;
            _userController.currentPage = 0;
            _loadInitialData();
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              UserTextFormField(
                  text: 'Buscar por Usuario', controller: _usernameController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Status()),
                  const SizedBox(width: 10),
                  Expanded(child: Type()),
                ],
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Button(
                      onPressed: _triggerSearch,
                      text: 'Buscar',
                      icon: Icons.search),
                ),
                AddButton(
                    onPressed: () {
                      Navigator.push(context, createFadeRoute(UserModelo()))
                          .then((_) => _loadUsers());
                    },
                    text: 'Usuario',
                    size: Size(MediaQuery.of(context).size.width * 0.45, 50))
              ]),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: UserTextFormField(
                      text: 'Usuario', controller: _usernameController)),
              const SizedBox(width: 15),
              Expanded(
                  child: UserTextFormField(
                      text: 'Nombre', controller: _nameController)),
              const SizedBox(width: 15),
              Expanded(
                  child: UserTextFormField(
                      text: 'Apellido', controller: _lastnameController)),
              const SizedBox(width: 15),
              Expanded(
                  child: UserTextFormField(
                      text: 'Correo', controller: _emailController)),
              const SizedBox(width: 15),
              Expanded(child: Role()),
              const SizedBox(width: 15),
              Expanded(child: Status()),
              const SizedBox(width: 15),
              Expanded(child: Type()),
              const SizedBox(width: 15),
            ],
          );
  }

  Widget Status() {
    return StatusDropDown(
      selectedValue: _selectedStatus,
      onChanged: (value) {
        if (value == null || value == _selectedStatus) return;

        setState(() {
          _selectedStatus = value;
        });

        _triggerSearch();
      },
    );
  }

  Widget Type() {
    return TypeDropDown(
      selectedValue: _selectedUserType,
      onChanged: (newValue) {
        if (newValue == null || newValue == _selectedUserType) return;

        setState(() {
          _selectedUserType = newValue;
        });

        _triggerSearch();
      },
    );
  }

  Widget Role() {
    return RoleDropDown(
      selectedValue: _selectedRole,
      onChanged: (newValue) {
        setState(() {
          _selectedRole = newValue ?? 'Todos';
          _triggerSearch();
        });
      },
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _header('Usuario', 0.1),
          _header('Nombre', 0.15),
          _header('Apellidos', 0.15),
          _header('Correo', 0.15),
          _header('Rol', 0.1),
          _header('Estado', 0.1),
          _header('Tipo', 0.1),
          //const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: AddButton(
                onPressed: () {
                  Navigator.push(context, createFadeRoute(UserModelo()))
                      .then((_) => _loadUsers());
                },
                text: 'Usuario',
                size: const Size(150, 40)),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, double widthFactor) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 25,
      child: Text(title, style: _headerStyle()),
    );
  }

  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _header('Usuario', 0.35),
          _header('Estado', 0.3),
          _header('Acciones', 0.25),
        ],
      ),
    );
  }

  Widget _buildUserRowMobile(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: Text(user.username, overflow: TextOverflow.ellipsis)),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                user.enabled ? 'Activo' : 'Inactivo',
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _editUser(user);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _deleteUser(user.username);
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildUserRow(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10.0),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _user(user.username, 0.1),
          _user(user.name, 0.15),
          _user(user.lastName, 0.15),
          _user(user.email, 0.15),
          _user(user.mainRoleDescription, 0.1),
          _user(user.enabled ? 'Activo' : 'Inactivo', 0.1),
          _user(user.type, 0.1),
          //const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    _editUser(user);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteUser(user.username);
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
