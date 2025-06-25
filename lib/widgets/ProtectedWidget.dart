// lib/widgets/ProtectedWidget.dart

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/providers/ProfileProvider.dart';
import 'package:provider/provider.dart';

/// Un widget que envuelve a su 'child' y controla su visibilidad y funcionalidad
/// basándose en si el usuario autenticado tiene un permiso específico.
class ProtectedWidget extends StatelessWidget {
  /// El widget que será protegido (ej. una Card, un botón).
  final Widget child;

  /// El string del permiso requerido para que el 'child' esté activo.
  /// Debe coincidir exactamente con los permisos que vienen del backend.
  final String requiredPermission;

  /// La acción a ejecutar cuando se toca el widget (si el usuario tiene permiso).
  final VoidCallback? onTap;

  /// Mensaje a mostrar en el Tooltip cuando el widget está deshabilitado.
  final String disabledMessage;

  const ProtectedWidget({
    super.key,
    required this.child,
    required this.requiredPermission,
    this.onTap,
    this.disabledMessage = 'No tiene permiso para acceder a este módulo',
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el perfil del usuario desde el Provider.
    final profile = Provider.of<ProfileProvider>(context).userProfile;
    final userPermissions = profile?.permissions ?? [];

    // 2. Verificamos si la lista de permisos del usuario contiene el permiso requerido.
    final bool hasPermission = userPermissions.contains(requiredPermission);

    // 3. Construimos la UI condicionalmente.
    if (hasPermission) {
      // Si tiene permiso, devolvemos el widget funcional, envuelto en un InkWell.
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // Para que el efecto ripple sea redondeado
        child: child,
      );
    } else {
      // Si NO tiene permiso, devolvemos el widget deshabilitado.
      return Tooltip(
        message: disabledMessage,
        child: IgnorePointer(
          // Ignora todos los gestos táctiles
          child: Opacity(
            opacity: 0.5, // Lo hace semitransparente para dar feedback visual
            child: child,
          ),
        ),
      );
    }
  }
}
