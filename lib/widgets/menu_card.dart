import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> menu;
  final Function(Map<String, dynamic>) onIngredientChanged;

  const MenuCard({
    Key? key,
    required this.menu,
    required this.onIngredientChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(menu['menu']),
            subtitle: Text(
              '${menu['cafeteria']} - ${menu['mealType']} (${menu['date']})',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredientes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...menu['ingredients'].map<Widget>((ingredient) {
                  return CheckboxListTile(
                    title: Text(ingredient['name']),
                    value: ingredient['selected'],
                    onChanged: (bool? value) {
                      // Notificar al padre que un ingrediente ha cambiado
                      onIngredientChanged({
                        'menu': menu,
                        'ingredient': ingredient,
                        'value': value,
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                final selectedIngredients = menu['ingredients']
                    .where((ingredient) => ingredient['selected'])
                    .map((ingredient) => ingredient['name'])
                    .toList();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      style: TextStyle(color: Colors.white, fontSize: 17),
                      'Menú reservado: ${menu['menu']} con ${selectedIngredients.join(", ")}',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.red[900],
              ),
              child: Text('RESERVAR',
                  style: TextStyle(color: Colors.white, fontSize: 17)),
            ),
          ),
          SizedBox(height: 15)
        ],
      ),
    );
  }
}
