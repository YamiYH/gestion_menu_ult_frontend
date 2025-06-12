// lib/screens/common/Perfil.dart

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/providers/ProfileProvider.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:provider/provider.dart';

import '../../models/UserProfile.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  // ELIMINADO: Ya no necesitamos el mapa de datos estático.
  // final Map<String, dynamic> _userData = const { ... };

  Widget _buildProfileDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 22),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: isMobile ? 13 : 16, color: Colors.grey[600])),
                const SizedBox(height: 3),
                Text(value,
                    style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Nos conectamos al ProfileProvider para obtener el estado.
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user =
        profileProvider.userProfile; // El objeto UserProfile (puede ser nulo)

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mi Perfil',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // 2. Manejamos los diferentes estados: carga, error y éxito.
              child: _buildBody(context, profileProvider, user),
            ),
          ),
        ),
      ),
    );
  }

  // --- NUEVO MÉTODO: Construye el cuerpo según el estado ---
  Widget _buildBody(
      BuildContext context, ProfileProvider provider, UserProfile? user) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null || user == null) {
      return Center(
        child: Text(
          provider.error ?? 'No se pudieron cargar los datos del perfil.',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const CircleAvatar(
          radius: 55,
          backgroundImage: AssetImage('assets/icons/user.png'),
          backgroundColor: Colors.black12,
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (user.username != user.fullName)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '@${user.username}', // <-- Dato dinámico
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildProfileDetailRow(
            context, 'Correo Electrónico', user.email, Icons.email_outlined),
        _buildProfileDetailRow(
            context, 'Nombre de Usuario', user.username, Icons.alternate_email),
        _buildProfileDetailRow(context, 'Rol Asignado', user.role ?? 'N/D',
            Icons.person_pin_outlined),
        _buildProfileDetailRow(
            context, 'Tipo de Usuario', user.type, Icons.category_outlined),
        const SizedBox(height: 30),
      ],
    );
  }
}
