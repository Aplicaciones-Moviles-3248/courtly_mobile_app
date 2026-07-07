import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';

class CourtlyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CourtlyBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  void _goTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.courts);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.courts);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.courts);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.matches);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.home_outlined,
            label: 'Inicio',
            isSelected: currentIndex == 0,
            onTap: () => _goTo(context, 0),
          ),
          _BottomItem(
            icon: Icons.grid_view_rounded,
            label: 'Canchas',
            isSelected: currentIndex == 1,
            onTap: () => _goTo(context, 1),
          ),
          GestureDetector(
            onTap: () => _goTo(context, 2),
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x552EC4A6),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.groups_2_outlined,
                color: AppColors.darkNavy,
                size: 26,
              ),
            ),
          ),
          _BottomItem(
            icon: Icons.sports_soccer_outlined,
            label: 'Partidos',
            isSelected: currentIndex == 3,
            onTap: () => _goTo(context, 3),
          ),
          _BottomItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            isSelected: currentIndex == 4,
            onTap: () => _goTo(context, 4),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Colors.white54;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}