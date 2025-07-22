import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? iconSize;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: iconColor ?? Colors.white,
          size: iconSize ?? 18,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
