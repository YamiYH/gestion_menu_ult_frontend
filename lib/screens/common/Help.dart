import 'package:flutter/material.dart'; // Importa tu CustomAppBar si la vas a usar
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  // Helper para crear cada sección del acordeón
  Widget _buildHelpSection(BuildContext context,
      {required String title, required String content, IconData? icon}) {
    return ExpansionTile(
      leading: icon != null
          ? Icon(icon, color: Theme.of(context).primaryColorDark)
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              height: 1.5, // Espacio entre líneas
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(
          title: isMobile ? 'Manual de Usuario' : 'Ayuda / Manual de Usuario'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildHelpSection(
            context,
            icon: Icons.info_outline,
            title: 'Introducción General',
            content:
                'Bienvenido al Menú Digital de la Universidad de Las Tunas. '
                'Este sistema está diseñado para optimizar y digitalizar los procesos relacionados con la '
                'gestión de menú de alimentación, así como la administración de usuarios, roles, inventario, '
                'propuestas de menú, ventas y notificaciones. Este manual le guiará a través de las principales funcionalidades.',
          ),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.login,
            title: 'Inicio de Sesión y Pantalla Principal',
            content:
                'Para acceder al sistema, ingrese su nombre de usuario y contraseña en la pantalla de Login. '
                'Una vez autenticado, será dirigido a la pantalla principal donde encontrará accesos directos '
                'a los diferentes módulos del sistema como Menú, Tickets y Administración, según su rol.',
          ),

          const Divider(),

          _buildHelpSection(
            context,
            icon: Icons.group,
            title: 'Roles del sistema',
            content:
                'Administrador del sistema: Tiene acceso a todos los módulos del sistema.\n'
                'Especialista: Tiene acceso a Menú, Inventario, Propuestas de Menú, Libro de Recetas, Ventas, Informe de Ventas, Tickets. \n'
                'Contador: Tiene acceso a Menú, Inventario, Contabilidad, Ventas, Informe de Ventas, Tickets. \n'
                'Técnico: Tiene acceso a Ventas. \n'
                'Usuario: Solo tiene acceso a Tickets. \n',
          ),
          const Divider(),

          _buildHelpSection(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Inventario',
            content:
                'La pantalla de "Inventario" presenta una tabla con los productos disponibles, mostrando código, '
                'nombre, categoría, cantidad y unidad de medida. Incluye filtros para buscar por producto, categoría '
                'y rangos de cantidad. '
                'Actualmente es una pantalla de solo consulta.',
          ),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.assignment_turned_in_outlined,
            title: 'Propuestas de Menú',
            content:
                'En "Propuestas de Menú" se pueden visualizar y gestionar los menús planificados para estudiantes y trabajadores. '
                'Permite filtrar por tipo de comida (ej. Almuerzo) y fecha. '
                'Los menús se muestran en categorías expandibles. '
                'Existe un botón para "Proponer" los menús enviándolos a Contabilidad para ser aprobados o no.',
          ),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.point_of_sale_outlined,
            title: 'Ventas',
            content:
                'La pantalla de "Ventas" (accesible desde Iniciar Ventas) permite seleccionar platos del menú disponible, '
                'calcular el total, buscar un usuario (cliente), y tiene opciones para "Reservar" o "Pagar" el pedido. '
                'También incluye una función para "Cerrar Ventas". La generación y uso del código QR está planificada para '
                'garantizar posteriormente la entrada al comedor con los datos de la reserva/compra.',
          ),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.menu_book_outlined,
            title: 'Libro de Recetas',
            content:
                'El "Libro de Recetas" muestra un listado de todas las recetas agrupadas por categorías. '
                'Puede buscar recetas por nombre. Cada categoría se puede expandir para ver las recetas que contiene. '
                'Tiene opciones para añadir nuevas categorías, editar y eliminar categorías existentes (solo si no tienen recetas). '
                'Desde aquí también puede añadir nuevas recetas o editar/eliminar las existentes. '
                'Al crear o editar una receta, podrá detallar su nombre, número, categoría, valores nutricionales, '
                'ingredientes (con peso bruto y neto), parámetros de cocción, preparación y observaciones.',
          ),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Informes de Ventas',
            content:
                'Desde "Informes de Ventas" se pueden generar y descargar reportes. Se pueden filtrar por un rango '
                'de fechas ("Desde" - "Hasta") y buscar. Los informes se agrupan por fecha y se pueden descargar individualmente '
                '(ej. Informe Contabilidad, Informe Alimentos).',
          ),
          const Divider(),
          _buildHelpSection(context,
              icon: Icons.receipt_long_outlined,
              title: 'Contabilidad',
              content:
                  'Desde "Contabilidad" se administra la aprobación o el rechazo de las propuestas de menú, disponiéndose '
                  'además de la funcionalidad para efectuar los ajustes necesarios en las tarifas de los platos. '),
          const Divider(),
          _buildHelpSection(context,
              icon: Icons.receipt_long_outlined,
              title: 'Configuración de Menú',
              content:
                  'El apartado de "Configuración de Menú" le permite establecer y ajustar los horarios críticos que rigen la gestión de tickets y la disponibilidad de los servicios de almuerzo. Esta configuración es fundamental para asegurar el correcto funcionamiento del sistema y la adecuada planificación por parte de los usuarios y administradores.'),
          const Divider(),
          _buildHelpSection(context,
              icon: Icons.receipt_long_outlined,
              title: 'Gestión de Tickets',
              content:
                  'La pantalla "Gestión de Tickets" es el centro para la reserva y visualización de los tickets de comedor. Se organiza en dos pestañas principales para facilitar su uso: "Reservar Ticket" y "Mis Tickets".\n\n'
                  'Pestaña: Reservar Ticket \n'
                  'Esta pestaña le permite buscar y reservar menús disponibles según sus preferencias.\n'
                  'Filtros de Búsqueda: '
                  'Comedor: Seleccione el comedor para el cual desea ver los menús disponibles (ej. "Lenin", "Pepito Tey").\n'
                  'Menú: Elija el tipo de comida que desea reservar (ej. "Desayuno", "Almuerzo", "Comida").\n'
                  'Rango de Fechas ("Desde" - "Hasta"): Especifique el período para el cual desea buscar menús. Haga clic en cada campo para seleccionar las fechas de inicio y fin en un calendario.'
                  'Botón "BUSCAR": Una vez definidos los filtros, presione este botón para que el sistema muestre los menús que coinciden con sus criterios.\n\n'
                  'Menús Disponibles: Debajo de los filtros, aparecerá una lista con los menús disponibles que coinciden con su búsqueda.'
                  'Cada menú se presenta en una tarjeta que incluye:\n'
                  'Nombre del Menú: Identificador del menú (ej. "Menú 1").\n'
                  'Detalles: Comedor, tipo de comida y fecha del menú.\n'
                  'Platos: Una lista de los platos que componen el menú. Cada plato tiene una casilla de verificación a su derecha.\n'
                  'Selección de Platos: Marque las casillas de los platos que desea incluir en su reserva para ese menú específico.'
                  'Puede seleccionar uno o varios platos según la configuración del menú.\n'
                  'Botón "Reservar": Una vez seleccionados los platos deseados para un menú, presione el botón "Reservar" ubicado al final de la tarjeta de ese menú.\n\n'
                  'Nota sobre horario de reserva: El sistema solo permite realizar reservas hasta la hora límite establecida (por ejemplo, la 1:00 PM del día de la consumición).'
                  'Si intenta reservar fuera de este horario, recibirá una notificación.\n'
                  'Confirmación de Reserva: Tras presionar "Reservar" y si la reserva es exitosa, el sistema le mostrará una notificación confirmando la reserva (generalmente un mensaje breve en la parte inferior de la pantalla). El ticket reservado aparecerá entonces en la pestaña "Mis Tickets".\n\n'
                  'Pestaña: Mis Tickets\n'
                  'En esta pestaña, podrá visualizar todos los tickets que ha reservado previamente.\n'
                  'Listado de Tickets:'
                  'Se muestra una lista de sus tickets reservados. Cada ticket en la lista muestra:\n'
                  'Nombre del Menú.\n'
                  'Comedor, tipo de comida y fecha.\n'
                  'Botón "Detalles": Cada ticket tiene un botón "Detalles" a la derecha.\n'
                  'Detalles del Ticket: Al presionar "Detalles", se abrirá una ventana emergente mostrando la información completa de su reserva, incluyendo:\n'
                  'Comedor, Tipo de Comida, Fecha, Menú.\n'
                  'Ingredientes/Platos seleccionados: Un listado de los platos específicos que reservó.\n'
                  'Opción "CANCELAR RESERVA": Si aún está dentro del período permitido para cancelaciones (según la "Hora máxima para cancelación de tickets" configurada en el sistema, por ejemplo, antes de la 1:00 PM del día de la reserva), aparecerá un botón para cancelar la reserva. Al presionarlo, el ticket se eliminará de su lista.\n'
                  'Botón "CERRAR": Para cerrar la ventana de detalles.'),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Mi Perfil',
            content:
                'La opción "Mi Perfil" (accesible desde el menú de usuario en la barra de navegación) muestra su información '
                'personal y de la cuenta, como nombre de usuario, nombre completo, correo, rol y tipo de usuario. '
                'Actualmente es una pantalla de solo consulta.',
          ),
          const Divider(),
          _buildHelpSection(context,
              icon: Icons.question_mark,
              title: 'Preguntas Frecuentes (FAQ)',
              content:
                  'P: ¿Cómo cambio mi contraseña?\nR: Actualmente, esta función debe solicitarse al administrador del sistema.\n\n'),
          const Divider(),
          _buildHelpSection(
            context,
            icon: Icons.contact_support_outlined,
            title: 'Contacto de Soporte',
            content:
                'Si encuentra problemas o tiene dudas que no se resuelven en este manual, por favor contacte al departamento de TI de la universidad:\n\n'
                'Email: soporte.ti@ult.edu.cu\n'
                'Teléfono: +53 XXXX XXXX (Ext. XXX)\n'
                'Horario de atención: Lunes a Viernes, 8:00 AM - 5:00 PM.',
          ),
          const SizedBox(height: 20), // Espacio al final
        ],
      ),
    );
  }
}
