import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/RoleController.dart';
import 'package:gestion_menu_ult_frontend/models/RoleEntity.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/RolModelo.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/Pagination.dart';

import '../../widgets/Confirm.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  final RoleController _controller = RoleController();
  bool _isLoading = true;

  List<RoleEntity> _roles = [];
  List<RoleEntity> _filteredRoles = [];

  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = 'Todos';
  String selectedAccess = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _searchController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyAllFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final rolesFromApi = await _controller.fetchRoles();
      setState(() {
        _roles = rolesFromApi.cast<RoleEntity>();
        _applyAllFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar roles: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyAllFilters() {
    final nameQuery = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredRoles = _roles.where((role) {
        final nameMatch =
            nameQuery.isEmpty || role.name.toLowerCase().contains(nameQuery);
        final statusMatch = selectedStatus == 'Todos' ||
            (role.enabled ? 'Activo' : 'Inactivo') == selectedStatus;
        final accessMatch = selectedAccess == 'Todos' ||
            role.permissions.any(
                (p) => p.toLowerCase().contains(selectedAccess.toLowerCase()));
        return nameMatch && statusMatch && accessMatch;
      }).toList();
    });
  }

  void _editRole(RoleEntity roleData) async {
    final result = await Navigator.push(
      context,
      createFadeRoute(RolModelo(initialData: roleData.toJson())),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refrescando lista para ver cambios...')),
      );
      _loadRoles();
    }
  }

  void _deleteRole(String roleId, String roleName) async {
    await showConfirmDeleteDialog(
      context: context,
      itemName: roleName,
      itemType: 'el rol',
      onConfirm: () {
        setState(() {
          _roles.removeWhere((role) => role.id == roleId);
          _controller.deleteRole(roleId);
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

  String formatAccess(List<String> access) {
    return access.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Roles'),
      body: Column(
        children: [
          isMobile ? _buildHeaderMobile() : _buildHeaderRow(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red))
                : _filteredRoles.isEmpty
                    ? const Center(child: Text('No se encontraron roles.'))
                    : ListView.builder(
                        itemCount: _filteredRoles.length,
                        itemBuilder: (context, index) {
                          final role = _filteredRoles[index];
                          return Column(
                            children: [
                              isMobile
                                  ? _buildRoleRowMobile(role)
                                  : _buildRoleRow(role),
                              const Divider(height: 1),
                            ],
                          );
                        },
                      ),
          ),
          isMobile
              ? Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AddButton(
                        onPressed: () {
                          Navigator.push(context, createFadeRoute(RolModelo()));
                        },
                        text: 'Rol',
                        size: const Size(140, 50),
                      ),
                    ],
                  ),
                )
              : SizedBox()
        ],
      ),
      bottomNavigationBar: Pagination(
        currentPage: _controller.currentPage,
        totalPages: _controller.totalPages,
        itemsPerPage: _controller.pageSize,
        onPageChanged: (newPage) {
          if (_controller.currentPage != newPage) {
            _controller.currentPage = newPage;
            _loadRoles();
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            _controller.pageSize = newSize;
            _controller.currentPage = 0;
            _loadRoles();
          }
        },
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 25,
            child: Text('Nombre', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: 25,
            child: Text('Accesos', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            height: 25,
            child: Text('Estado', style: _headerStyle()),
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
            size: const Size(125, 40),
          )
        ],
      ),
    );
  }

  Widget _buildRoleRow(RoleEntity role) {
    // Recibe objeto RoleM
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10.0),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20,
            height: 20,
            child: Text(role.description),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: 20,
            child: Text(formatAccess(role.permissions)),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.10,
              height: 20,
              child: Text(role.enabled ? 'Activo' : 'Inactivo')),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _editRole(role);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (role.id != null) {
                      _deleteRole(role.id!, role.name);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02)
        ],
      ),
    );
  }

  Widget _buildHeaderMobile() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 20),
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

  Widget _buildRoleRowMobile(RoleEntity role) {
    // Recibe objeto RoleM
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              height: 20,
              child: Text(role.description),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 20,
              child: Text(role.enabled ? 'Activo' : 'Inactivo'),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      _editRole(role);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (role.id != null) {
                        _deleteRole(role.id!, role.name);
                      }
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
