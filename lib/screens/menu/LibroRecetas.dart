import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/AddButton.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/Button.dart';
import 'RecetaModelo.dart';

class LibroRecetas extends StatefulWidget {
  const LibroRecetas({super.key});

  @override
  State<LibroRecetas> createState() => _LibroRecetasState();
}

// Lista simulada de recetas
final List<Map<String, dynamic>> recetas = [
  {'nombre': 'Ensalada de acelga'},
  {'nombre': 'Ensalada de aguacate'},
];

class _LibroRecetasState extends State<LibroRecetas> {
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
                      children: SearchRecipes(isMobile, context),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SearchRecipes(isMobile, context),
                    )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recetas.length,
              itemBuilder: (context, index) {
                final receta = recetas[index];
                return _buildRecetaCard(receta, context, () {
                  setState(() {
                    recetas.remove(receta);
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget SearchTextField(bool isMobile, BuildContext context) {
  return SizedBox(
    width: isMobile
        ? MediaQuery.of(context).size.width * 0.9
        : 220, // Mismo ancho que el botón
    height: 50, // Mismo alto que el botón
    child: TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.restaurant_menu),
          prefixIconColor: Colors.red.shade900,
          labelText: 'Plato',
          labelStyle: TextStyle(color: Colors.red.shade900),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10), // Mismos bordes redondeados
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.all(15)),
      onChanged: (value) {},
    ),
  );
}

List<Widget> SearchRecipes(bool isMobile, BuildContext context) {
  return [
    SearchTextField(isMobile, context),
    SizedBox(height: 15, width: 15),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Button(
          onPressed: () {},
          icon: Icons.search,
          text: 'Buscar',
          size: Size(
              isMobile ? MediaQuery.of(context).size.width * 0.40 : 220, 50),
        ),
        SizedBox(height: 15, width: isMobile ? 5 : 15),
        AddButton(
            onPressed: () {},
            text: 'Receta',
            size: Size(
                isMobile ? MediaQuery.of(context).size.width * 0.40 : 220, 50)),
      ],
    ),
  ];
}

Widget _buildRecetaCard(
  Map<String, dynamic> receta,
  BuildContext context,
  VoidCallback onDelete, // Añadir este parámetro
) {
  bool isMobile = MediaQuery.of(context).size.width < 600;

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: InkWell(
      onTap: () {
        // Navegar a la pantalla de consulta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecetaModelo(
              isEditMode: false, // Modo consulta
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nombre de la receta
            Expanded(
              child: Text(
                receta['nombre'],
                style: TextStyle(
                  fontSize: isMobile ? 18 : 16,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecetaModelo(
                          isEditMode: true, // Modo edición
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[900], size: 25),
                  onPressed: () {
                    // Mostrar mensaje de confirmación antes de eliminar
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmar eliminación'),
                        content: Text(
                            '¿Estás seguro de que deseas eliminar esta receta?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Cerrar el diálogo
                            },
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Llamar a la función onDelete para eliminar la receta
                              onDelete();
                              Navigator.pop(context); // Cerrar el diálogo
                            },
                            child: Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
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
