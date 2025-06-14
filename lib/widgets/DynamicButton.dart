import 'package:flutter/material.dart';

class DynamicButton extends StatefulWidget {
  final VoidCallback? onPressed; // Cambiado a nullable para poder deshabilitarlo
  final String text;
  final IconData? icon;
  final Color colorButton;
  final Size? size;
  final bool isLoading; // <--- 1. AÑADIMOS EL PARÁMETRO 'isLoading'

  const DynamicButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    required this.colorButton,
    required this.size,
    this.isLoading = false, // <--- 2. LE DAMOS UN VALOR POR DEFECTO
  }) : super(key: key);

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // Si está cargando, el callback es null para deshabilitar el botón
    final VoidCallback? currentOnPressed = widget.isLoading ? null : widget.onPressed;

    return ElevatedButton(
      onPressed: currentOnPressed, // <--- 3. USAMOS EL CALLBACK CONDICIONAL
      style: ElevatedButton.styleFrom(
        fixedSize: widget.size,
        elevation: 3,
        backgroundColor: widget.colorButton,
        // Un detalle visual: si está deshabilitado (cargando), hacemos el color un poco más opaco
        disabledBackgroundColor: widget.colorButton.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 20,
          vertical: isMobile ? 11 : 18,
        ),
      ),
      // <--- 4. LA LÓGICA PRINCIPAL ESTÁ AQUÍ
      child: widget.isLoading
      // SI ESTÁ CARGANDO, MUESTRA EL SPINNER
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
      // SI NO, MUESTRA EL CONTENIDO ORIGINAL
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: Colors.white,
              size: isMobile ? 18 : 20,
            ),
          ],
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}