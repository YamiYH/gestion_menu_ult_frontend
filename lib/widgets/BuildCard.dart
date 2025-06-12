import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const BuildCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // --- AÑADIDO: Definimos los colores basados en el estado ---
    final Color activeColor = Colors.red[900]!;
    final Color disabledColor = Colors.grey.shade600;
    final Color currentColor = isEnabled ? activeColor : disabledColor;

    return MouseRegion(
      cursor:
          isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 300,
            height: isMobile ? 150 : 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size:
                      isMobile ? 40 : MediaQuery.of(context).size.width * 0.03,
                  color: currentColor,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile
                        ? 16
                        : MediaQuery.of(context).size.width * 0.015,
                    fontWeight: FontWeight.bold,
                    color: currentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
