import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/Confirm.dart';
import 'RecetaModelo.dart';

class LibroRecetas extends StatefulWidget {
  const LibroRecetas({super.key});

  @override
  State<LibroRecetas> createState() => _LibroRecetasState();
}

class _LibroRecetasState extends State<LibroRecetas> {
  final List<Map<String, dynamic>> recetas = [
    {'nombre': 'Ensalada de acelga'},
    {'nombre': 'Ensalada de aguacate'},
    {'nombre': 'Arroz con Pollo'},
    {'nombre': 'Potaje de Frijoles Negros'},
    {'nombre': 'Picadillo de Res'},
    // Añade más recetas si quieres probar mejor el filtro
  ];

  List<Map<String, dynamic>> _filteredRecetas = [];
  final TextEditingController _searchController = TextEditingController();

  // --- PASO 2: Implementar initState y dispose ---
  @override
  void initState() {
    super.initState();
    // Inicializar la lista filtrada con todas las recetas
    _filteredRecetas = List.from(recetas);
    // Añadir listener para filtrar en tiempo real
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    // Quitar el listener y liberar el controlador
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // --- PASO 3: Crear la función _applyFilters ---
  void _applyFilters() {
    final searchTerm = _searchController.text.trim().toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        // Si no hay término de búsqueda, mostrar todas las recetas
        _filteredRecetas = List.from(recetas);
      } else {
        // Filtrar la lista principal 'recetas'
        _filteredRecetas = recetas.where((receta) {
          final nombre =
              receta['nombre'] as String? ?? ''; // Manejo seguro de null
          return nombre.toLowerCase().contains(searchTerm);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Libro de Recetas'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.all(16.0),
              child: isMobile
                  ? Column(
                      children: SearchRecipes(
                          isMobile, context, _searchController, _applyFilters),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SearchRecipes(
                          isMobile, context, _searchController, _applyFilters),
                    )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: ListView.builder(
                itemCount: _filteredRecetas.length,
                itemBuilder: (context, index) {
                  final receta = _filteredRecetas[index];
                  return _buildRecetaCard(receta, context, () {
                    setState(() {
                      recetas.remove(receta);
                      _applyFilters();
                    });
                    print("Borrado (temporal) de ${receta['nombre']}");
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget SearchTextField(
    bool isMobile, BuildContext context, TextEditingController controller) {
  return SizedBox(
    width: isMobile
        ? MediaQuery.of(context).size.width * 0.9
        : 220, // Mismo ancho que el botón
    height: 50, // Mismo alto que el botón
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
          suffixIcon: Icon(Icons.search),
          prefixIconColor: Colors.red.shade900,
          labelText: 'Buscar Plato',
          labelStyle: TextStyle(color: Colors.red.shade900),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10), // Mismos bordes redondeados
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.all(15)),
    ),
  );
}

List<Widget> SearchRecipes(bool isMobile, BuildContext context,
    TextEditingController searchController, VoidCallback onSearchPressed) {
  return [
    SearchTextField(isMobile, context, searchController),
    SizedBox(height: 15, width: 15),
    AddButton(
        onPressed: () {
          Navigator.push(
            context,
            createFadeRoute(RecetaModelo(isEditMode: true, receta: null)),
          );
        },
        text: 'Receta',
        size: Size(
            isMobile ? MediaQuery.of(context).size.width * 0.40 : 220, 50)),
  ];
}

Widget _buildRecetaCard(
  Map<String, dynamic> receta,
  BuildContext context,
  VoidCallback onDelete,
) {
  bool isMobile = MediaQuery.of(context).size.width < 600;
  final String recetaName = receta['nombre'] as String? ?? 'Receta sin nombre';

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: InkWell(
      onTap: () {
        Navigator.push(
            context, createFadeRoute(RecetaModelo(isEditMode: false)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                receta['nombre'],
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ),
            SizedBox(width: 10), // Espacio entre el texto y los botones
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.red[900], size: 25),
                  onPressed: () {
                    // Navegar a la pantalla de edición
                    Navigator.push(context,
                        createFadeRoute(RecetaModelo(isEditMode: true)));
                  },
                ),
                IconButton(
                  tooltip: 'Eliminar Receta',
                  icon: Icon(Icons.delete, color: Colors.red[900], size: 25),
                  onPressed: () {
                    showConfirmDeleteDialog(
                      context: context,
                      itemName: recetaName,
                      itemType: 'la receta',
                      onConfirm: onDelete,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
