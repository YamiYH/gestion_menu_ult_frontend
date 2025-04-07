import 'package:flutter/material.dart';

class Pagination<T extends int> extends StatefulWidget {
  final List<T> items; // Lista de elementos a paginar (solo enteros)
  int itemsPerPage = 10; // Número inicial de elementos por página
  final T? selectedValue; // Valor seleccionado (opcional)
  final Widget Function(BuildContext context, T item)
      itemBuilder; // Constructor de cada elemento

  Pagination({
    Key? key,
    required this.itemBuilder,
    this.selectedValue,
    List<T>? items, // Hacer items opcional,
  })  : items = items ?? <T>[10 as T, 25 as T, 50 as T, 100 as T],
        // Valor predeterminado
        super(key: key);

  @override
  State<Pagination<T>> createState() => _PaginationState<T>();
}

class _PaginationState<T extends int> extends State<Pagination<T>> {
  int currentPage = 1; // Página actual
  late int itemsPerPage; // Número de elementos por página (puede cambiar)
  final TextEditingController _pageController =
      TextEditingController(); // Controlador para el campo de texto

  @override
  void initState() {
    super.initState();
    itemsPerPage =
        widget.itemsPerPage; // Inicializar con el valor proporcionado
    _pageController.text = currentPage.toString(); // Inicializar el controlador
  }

  @override
  void dispose() {
    _pageController.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = widget.items.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // Obtener los elementos para la página actual
    List<T> getCurrentPageItems() {
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
      return widget.items.sublist(startIndex, endIndex);
    }

    return Container(
      color: Colors.grey.shade200, // Fondo blanco para los controles
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GoToPage(isMobile),
                    //SizedBox(width: 10),
                    Pages(isMobile, totalPages),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PerPage(),
                      SizedBox(width: 20),
                      GoButton(totalPages, context),
                    ])
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón "Anterior"
                Pages(isMobile, totalPages),
                SizedBox(width: 20),
                // Campo para navegar a una página específica
                GoToPage(isMobile),
                SizedBox(width: 25),
                // Campo para ajustar el número de elementos por página
                PerPage(),

                SizedBox(width: 30),
                GoButton(totalPages, context),
              ],
            ),
    );
  }

  SizedBox GoButton(int totalPages, BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          final newPage = int.tryParse(_pageController.text);
          if (newPage != null && newPage >= 1 && newPage <= totalPages) {
            setState(() {
              currentPage = newPage;
              _pageController.text = currentPage.toString();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Página inválida')),
            );
          }
        },
        child: Text('Ir'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red[700],
          padding: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Row Pages(bool isMobile, int totalPages) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red[700],
            size: isMobile ? 25 : 30,
          ),
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                    _pageController.text = currentPage.toString();
                  });
                }
              : null,
        ),

        // Texto "Página X de Y"
        Text(
          'Página $currentPage de $totalPages',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),

        // Botón "Siguiente"
        IconButton(
          icon: Icon(Icons.arrow_forward,
              color: Colors.red[700], size: isMobile ? 25 : 30),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                    _pageController.text = currentPage.toString();
                  });
                }
              : null,
        ),
      ],
    );
  }

  Row PerPage() {
    return Row(
      children: [
        Text(
          'Elementos por página:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(width: 10),
        DropdownButton<T>(
          padding: EdgeInsets.symmetric(horizontal: 0),
          value: itemsPerPage as T,
          onChanged: (value) {
            setState(() {
              itemsPerPage = value!;
            });
          },
          items: widget.items.map((T item) {
            // Acceder a widget.items
            return DropdownMenuItem<T>(
              value: item,
              child: SizedBox(child: Text(item.toString())),
            );
          }).toList(),
        ),
      ],
    );
  }

  Row GoToPage(isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ir a página:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: isMobile ? 40 : 35,
          width: 40,
          child: Align(
            alignment: Alignment.center,
            child: TextFormField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
      ],
    );
  }
}
