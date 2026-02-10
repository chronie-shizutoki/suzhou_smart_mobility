import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = isDark
        ? GlassTheme.glassDecorationDark
        : GlassTheme.glassDecoration;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: decoration.copyWith(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(
            context: context,
            icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
            index: 0,
            isActive: currentIndex == 0,
          ),
          const SizedBox(width: 16),
          _buildNavItem(
            context: context,
            icon: currentIndex == 1 ? Icons.search : Icons.search_outlined,
            index: 1,
            isActive: currentIndex == 1,
          ),
          const SizedBox(width: 16),
          _buildNavItem(
            context: context,
            icon: currentIndex == 2 ? Icons.settings : Icons.settings_outlined,
            index: 2,
            isActive: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }
}
