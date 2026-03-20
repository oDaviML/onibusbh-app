import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        _getIcon(themeMode),
        color: isDark ? Colors.white : AppColors.slate900,
      ),
      onPressed: () => ref.read(themeControllerProvider.notifier).cycleTheme(),
      tooltip: _getTooltip(themeMode),
    );
  }

  IconData _getIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.dark_mode;
      case AppThemeMode.dark:
        return Icons.brightness_7;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getTooltip(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Modo claro (clique para alternar)';
      case AppThemeMode.dark:
        return 'Modo escuro (clique para alternar)';
      case AppThemeMode.system:
        return 'Modo do sistema (clique para alternar)';
    }
  }
}
