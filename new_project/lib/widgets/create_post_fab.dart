import 'package:flutter/material.dart';

/// Twitter tarzı gönderi oluşturma butonu
class CreatePostFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const CreatePostFAB({
    Key? key,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor: iconColor,
      tooltip: tooltip ?? 'Gönderi Oluştur',
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(Icons.add),
    );
  }
}