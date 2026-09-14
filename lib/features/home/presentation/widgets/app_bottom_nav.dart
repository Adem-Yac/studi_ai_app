import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barre de navigation flottante StudyAI (5 onglets).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <NavItem>[
      NavItem(Icons.home_outlined, Icons.home_rounded, S.navHome),
      NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded,
          S.navChat),
      NavItem(Icons.folder_outlined, Icons.folder_rounded, S.navDocs),
      NavItem(Icons.quiz_outlined, Icons.quiz_rounded, S.navQuiz),
      NavItem(Icons.person_outline_rounded, Icons.person_rounded, S.navProfile),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavButton(
                item: items[i],
                active: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                color: active
                    ? AppColors.primaryOf(context)
                    : AppColors.softOf(context),
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? AppColors.primaryOf(context)
                      : AppColors.softOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
