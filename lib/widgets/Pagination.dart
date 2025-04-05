import 'package:flutter/material.dart';

class Pagination<T extends int> extends StatefulWidget {
  final List<T> items; // Lista de elementos a paginar (solo enteros)
  final int itemsPerPage; // Número inicial de elementos por página
  final T? selectedValue; // Valor seleccionado (opcional)
  final Widget Function(BuildContext context, T item)
      itemBuilder; // Constructor de cada elemento

  const Pagination({
    Key? key,
    required this.itemsPerPage,
    required this.itemBuilder,
    this.selectedValue,
    required this.items,
  }) : super(key: key);

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

    // Obtener los elementos para la página actual
    List<T> getCurrentPageItems() {
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
      return widget.items.sublist(startIndex, endIndex);
    }

    return Container(
      color: Colors.grey.shade200, // Fondo blanco para los controles
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón "Anterior"
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.red[700]),
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
            icon: Icon(Icons.arrow_forward, color: Colors.red[700]),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      _pageController.text = currentPage.toString();
                    });
                  }
                : null,
          ),

          SizedBox(width: 20),

          // Campo para navegar a una página específica
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ir a página:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(width: 10),
              SizedBox(
                height: 35,
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
          ),

          SizedBox(width: 25),

          // Campo para ajustar el número de elementos por página
          Row(
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
          ),

          SizedBox(width: 30),
          SizedBox(
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
          ),
        ],
      ),
    );
  }
}
