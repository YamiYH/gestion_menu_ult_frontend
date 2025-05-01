import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  final Map<String, dynamic> _userData = const {
    'username': 'yamiyh',
    'name': 'Yamilet',
    'lastname': 'Yero',
    'email': 'yamiyh@gmail.com',
    'role': 'Profesor',
    'type': 'Employee',
  };

  Widget _buildProfileDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final textTheme = Theme.of(context).textTheme;
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
                Text(label, // Etiqueta (ej. "Correo Electrónico")
                    style: TextStyle(
                        fontSize: isMobile ? 13 : 16, color: Colors.grey[600])),
                const SizedBox(height: 3),
                Text(value, // Valor (ej. "maria@...")
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

  // --- Fin Helper Widget ---

  @override
  Widget build(BuildContext context) {
    // Extrae los datos del mapa de forma segura
    final String username =
        _userData['username'] ?? 'N/D'; // Valor por defecto 'No Disponible'
    final String name = _userData['name'] ?? '';
    final String lastname = _userData['lastname'] ?? '';
    final String email = _userData['email'] ?? 'N/D';
    final String role = _userData['role'] ?? 'N/D';
    final String type = _userData['type'] ?? 'N/D';
    // Construye el nombre completo solo si ambos existen
    final String fullName = (name.isNotEmpty || lastname.isNotEmpty)
        ? '$name $lastname'.trim()
        : username; // Usa username si no hay nombre/apellido

    return Scaffold(
      // Usar una AppBar estándar suele ser mejor para pantallas internas
      appBar: CustomAppBar(
        title: 'Mi Perfil',
      ),
      body: SingleChildScrollView(
        // Permite scroll si el contenido es largo
        child: Center(
          // Centra el contenido en pantallas anchas
          child: ConstrainedBox(
            // Limita el ancho máximo
            constraints: const BoxConstraints(maxWidth: 700),
            // Ancho máximo del contenido
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Padding general
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Centra el avatar y nombre
                children: <Widget>[
                  // --- Sección de Avatar y Nombre ---
                  const CircleAvatar(
                    radius: 55,
                    // Tamaño del avatar
                    // TODO: Reemplaza con la imagen real del usuario si existe
                    backgroundImage: AssetImage('assets/icons/user.png'),
                    // Placeholder
                    backgroundColor: Colors.black12, // Fondo si no hay imagen
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName, // Muestra nombre completo o username
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  // Muestra username debajo solo si es diferente al nombre completo
                  if (username != fullName)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '@$username',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  // Separador visual
                  const SizedBox(height: 16),

                  // --- Sección de Detalles (Alineados a la izquierda por defecto) ---
                  _buildProfileDetailRow(context, 'Correo Electrónico', email,
                      Icons.email_outlined),
                  _buildProfileDetailRow(context, 'Nombre de Usuario', username,
                      Icons.alternate_email),
                  // Añadido username explícito
                  _buildProfileDetailRow(
                      context, 'Rol Asignado', role, Icons.person_pin_outlined),
                  _buildProfileDetailRow(context, 'Tipo de Usuario', type,
                      Icons.category_outlined),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
