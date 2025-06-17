import 'package:flutter/material.dart';

class DynamicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color colorButton;
  final Size? size;
  final bool isLoading;

  const DynamicButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    required this.colorButton,
    required this.size,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final VoidCallback? currentOnPressed =
        widget.isLoading ? null : widget.onPressed;
    return ElevatedButton(
      onPressed: currentOnPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: widget.size,
        elevation: 3,
        backgroundColor: widget.colorButton,
        disabledBackgroundColor: widget.colorButton.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 20,
          vertical: isMobile ? 11 : 18,
        ),
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
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
