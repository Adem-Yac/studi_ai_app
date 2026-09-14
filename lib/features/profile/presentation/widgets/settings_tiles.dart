import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_settings.dart';
import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/cubit/auth_cubit.dart';

/// Ligne de réglage générique (icône + titre + trailing).
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: danger ? AppColors.error : AppColors.primaryOf(context), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                      )),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.softOf(context),
                        )),
                ],
              ),
            ),
            trailing ??
                (onTap != null && !danger
                    ? Icon(Icons.chevron_right_rounded,
                        color: AppColors.softOf(context))
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class DarkModeTile extends StatelessWidget {
  const DarkModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: S.darkMode,
          subtitle: isDark ? S.enabled : S.disabled,
          trailing: Switch(
            value: isDark,
            onChanged: (v) {
              AppSettings.setThemeMode(
                v ? ThemeMode.dark : ThemeMode.light,
              );
              context.read<AuthCubit>().persistPreferences();
            },
          ),
        );
      },
    );
  }
}

class NotificationsTile extends StatelessWidget {
  const NotificationsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.notificationsEnabled,
      builder: (context, enabled, _) {
        return SettingsTile(
          icon: Icons.notifications_none_rounded,
          title: S.notifications,
          subtitle: S.notifsSubtitle,
          trailing: Switch(
            value: enabled,
            onChanged: (v) {
              AppSettings.setNotificationsEnabled(v);
              context.read<AuthCubit>().persistPreferences();
            },
          ),
        );
      },
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  static const _labels = {'fr': 'Français', 'en': 'English', 'ar': 'العربية'};

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.lang,
      builder: (context, lang, _) {
        return SettingsTile(
          icon: Icons.translate_rounded,
          title: S.language,
          subtitle: _labels[lang],
          onTap: () => _pick(context),
        );
      },
    );
  }

  void _pick(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in _labels.entries)
              ListTile(
                title: Text(e.value),
                trailing: AppSettings.lang.value == e.key
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  AppSettings.setLang(e.key);
                  context.read<AuthCubit>().persistPreferences();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class AnswerLevelTile extends StatelessWidget {
  const AnswerLevelTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AnswerLevel>(
      valueListenable: AppSettings.answerLevel,
      builder: (context, level, _) {
        return SettingsTile(
          icon: Icons.school_outlined,
          title: S.answerLevel,
          subtitle: switch (level) {
            AnswerLevel.simple => S.levelSimple,
            AnswerLevel.university => S.levelUniversity,
            AnswerLevel.expert => S.levelExpert,
          },
          onTap: () => _pick(context),
        );
      },
    );
  }

  void _pick(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final level in AnswerLevel.values)
              ListTile(
                title: Text(switch (level) {
                  AnswerLevel.simple => S.levelSimple,
                  AnswerLevel.university => S.levelUniversity,
                  AnswerLevel.expert => S.levelExpert,
                }),
                trailing: AppSettings.answerLevel.value == level
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  AppSettings.setAnswerLevel(level);
                  context.read<AuthCubit>().persistPreferences();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
