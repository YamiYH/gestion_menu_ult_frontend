import 'package:flutter/material.dart';

class GestionarAlmacen extends StatefulWidget {
  @override
  _GestionarAlmacenState createState() => _GestionarAlmacenState();
}

class _GestionarAlmacenState extends State<GestionarAlmacen> {
  // Lista de productos en el almacén (inicialmente vacía)
  List<Map<String, dynamic>> _productos = [];

  // Lista de categorías (inicialmente vacía)
  List<String> _categorias = [];

  // Historial de movimientos (entradas y salidas)
  List<Map<String, dynamic>> _historial = [];

  // Controladores para el formulario de productos
  final _nombreProductoController = TextEditingController();
  final _cantidadProductoController = TextEditingController();
  final _categoriaProductoController = TextEditingController();

  // Controladores para el formulario de movimientos
  final _cantidadMovimientoController = TextEditingController();

  // Controladores para el formulario de categorías
  final _nombreCategoriaController = TextEditingController();

  // Variable para controlar la pestaña activa
  int _pestanaActiva = 0;

  // Método para agregar un nuevo producto al almacén
  void _agregarProducto() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nombreProductoController,
                  decoration: InputDecoration(labelText: 'Nombre del Producto'),
                ),
                TextField(
                  controller: _cantidadProductoController,
                  decoration: InputDecoration(labelText: 'Cantidad Inicial'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Categoría'),
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _categoriaProductoController.text = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nombreProductoController.text.isEmpty ||
                    _cantidadProductoController.text.isEmpty ||
                    _categoriaProductoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, completa todos los campos.'),
                    ),
                  );
                } else if (int.tryParse(_cantidadProductoController.text) ==
                    null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La cantidad debe ser un número válido.'),
                    ),
                  );
                } else {
                  setState(() {
                    _productos.add({
                      'id': _productos.length + 1,
                      'nombre': _nombreProductoController.text,
                      'cantidad': int.parse(_cantidadProductoController.text),
                      'categoria': _categoriaProductoController.text,
                    });
                    _historial.add({
                      'tipo': 'Entrada',
                      'producto': _nombreProductoController.text,
                      'cantidad': int.parse(_cantidadProductoController.text),
                      'fecha': DateTime.now(),
                    });
                  });
                  _nombreProductoController.clear();
                  _cantidadProductoController.clear();
                  _categoriaProductoController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para registrar una entrada de productos
  void _registrarEntrada(int index) {
    _cantidadMovimientoController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar Entrada'),
          content: TextField(
            controller: _cantidadMovimientoController,
            decoration: InputDecoration(labelText: 'Cantidad a agregar'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  int cantidad = int.parse(_cantidadMovimientoController.text);
                  _productos[index]['cantidad'] += cantidad;
                  _historial.add({
                    'tipo': 'Entrada',
                    'producto': _productos[index]['nombre'],
                    'cantidad': cantidad,
                    'fecha': DateTime.now(),
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Registrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para registrar una salida de productos
  void _registrarSalida(int index) {
    _cantidadMovimientoController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar Salida'),
          content: TextField(
            controller: _cantidadMovimientoController,
            decoration: InputDecoration(labelText: 'Cantidad a retirar'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  int cantidad = int.parse(_cantidadMovimientoController.text);
                  if (_productos[index]['cantidad'] >= cantidad) {
                    _productos[index]['cantidad'] -= cantidad;
                    _historial.add({
                      'tipo': 'Salida',
                      'producto': _productos[index]['nombre'],
                      'cantidad': cantidad,
                      'fecha': DateTime.now(),
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'No hay suficiente cantidad en el inventario.'),
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Registrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para agregar una nueva categoría
  void _agregarCategoria() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Categoría'),
          content: TextField(
            controller: _nombreCategoriaController,
            decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nombreCategoriaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, ingresa un nombre para la categoría.'),
                    ),
                  );
                } else {
                  setState(() {
                    _categorias.add(_nombreCategoriaController.text);
                  });
                  _nombreCategoriaController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para editar una categoría
  void _editarCategoria(int index) {
    _nombreCategoriaController.text = _categorias[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Categoría'),
          content: TextField(
            controller: _nombreCategoriaController,
            decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nombreCategoriaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, ingresa un nombre para la categoría.'),
                    ),
                  );
                } else {
                  setState(() {
                    _categorias[index] = _nombreCategoriaController.text;
                  });
                  _nombreCategoriaController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar una categoría
  void _eliminarCategoria(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Categoría'),
          content: Text('¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _categorias.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 3, // Tres pestañas: Productos, Categorías, Historial
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventario',
              style: TextStyle(
                  color: Colors.white, fontSize: screenWidth > 600 ? 25 : 20)),
          centerTitle: true,
          backgroundColor: Colors.red[900],
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 15,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            onTap: (index) {
              setState(() {
                _pestanaActiva = index; // Actualiza la pestaña activa
              });
            },
            tabs: [
              Tab(text: 'Productos'),
              Tab(text: 'Categorías'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Productos
            ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(producto['nombre']),
                    subtitle: Text(
                        'Cantidad: ${producto['cantidad']} - ${producto['categoria']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () => _registrarEntrada(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _registrarSalida(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _productos.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Pestaña de Categorías
            ListView.builder(
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(categoria),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarCategoria(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarCategoria(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Pestaña de Historial
            ListView.builder(
              itemCount: _historial.length,
              itemBuilder: (context, index) {
                final movimiento = _historial[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        '${movimiento['tipo']}: ${movimiento['producto']}'),
                    subtitle: Text(
                        'Cantidad: ${movimiento['cantidad']} - Fecha: ${movimiento['fecha']}'),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: _pestanaActiva == 0 || _pestanaActiva == 1
            ? FloatingActionButton(
                onPressed:
                    _pestanaActiva == 0 ? _agregarProducto : _agregarCategoria,
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: Colors.red[900],
              )
            : null, // Oculta el botón en la pestaña de Historial
      ),
    );
  }
}
