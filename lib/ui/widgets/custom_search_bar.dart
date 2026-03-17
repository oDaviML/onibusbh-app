import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'soft_shadow_container.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Buscar linhas, paradas ou destinos',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SoftShadowContainer(
      padding: EdgeInsets.zero,
      child: TextField(
        onChanged: onChanged,
        style: AppTypography.display.copyWith(fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.display.copyWith(
            fontSize: 18,
            color: AppColors.slate400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.slate400,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
