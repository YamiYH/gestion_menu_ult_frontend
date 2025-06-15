import 'package:flutter/material.dart';

import '../models/MenuEntity.dart';
import 'SmallButton.dart';

class MenuCardWithAction extends StatelessWidget {
  const MenuCardWithAction({
    super.key,
    required this.context,
    required this.actionText,
    required this.onPressed,
    required this.menu,
  });

  final BuildContext context;
  final String actionText;
  final VoidCallback onPressed;
  final MenuEntity menu;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    'Menú de ${menu.category}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${menu.type} (${menu.date})',
                    style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              SizedBox(width: 20),
              SmallButton(
                  onPressed: onPressed,
                  text: actionText,
                  size: Size(
                    isMobile ? 95 : 120,
                    40,
                  )),
              SizedBox(width: 20)
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Platos:',
                  style: TextStyle(
                      fontSize: isMobile ? 16 : 17,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...menu.recipes.map((recipe) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: isMobile ? 18 : 20, color: Colors.red[700]),
                      SizedBox(width: 6),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '- ${recipe.name}',
                            style: TextStyle(fontSize: isMobile ? 15 : 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '\$ ${recipe.price}',
                        style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Precio Total: \$ ${menu.totalPrice}',
                  style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
