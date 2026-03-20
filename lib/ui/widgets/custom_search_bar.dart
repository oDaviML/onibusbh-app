import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'soft_shadow_container.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Digite o nome da linha',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SoftShadowContainer(
      padding: EdgeInsets.zero,
      child: TextField(
        onChanged: onChanged,
        style: AppTypography.titleLarge.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.titleLarge.copyWith(
            fontSize: 16,
            color: AppColors.slate400,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.slate400, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
