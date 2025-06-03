import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const BuildCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
                  color: Colors.red[900],
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
                    color: Colors.red[900],
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
