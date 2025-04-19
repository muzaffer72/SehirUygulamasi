import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Yükleme durumlarında kullanılan shimmer efekti widget'ı
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Temaya göre renkleri belirle
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final effectBaseColor = baseColor ?? 
        (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!);
    
    final effectHighlightColor = highlightColor ?? 
        (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!);

    return Shimmer.fromColors(
      baseColor: effectBaseColor,
      highlightColor: effectHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}