import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/data/models/app_user.dart';
import '../widgets/settings_tiles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, AppUser?>((c) => c.currentUser);
    final name = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : (user?.email ?? '');
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                16,
                AppLayout.screenMargin,
                AppLayout.bottomNavClearance,
              ),
              children: [
                StudyAIBrandBar(
                  trailing: IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: Icon(Icons.settings_outlined,
                        color: AppColors.mutedOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                _ProfileHeader(
                  name: name,
                  email: email,
                  studyField: user?.studyField,
                ),
                const SizedBox(height: 20),
                AppCard(
                  onTap: () => context.push('/progress'),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.success),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.weeklyGoal,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textOf(context),
                                )),
                            Text(S.weeklyGoalHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedOf(context),
                                )),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.softOf(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SettingsGroup(
                  title: S.aiPreferences,
                  children: [
                    LanguageTile(),
                    const Divider(height: 1),
                    AnswerLevelTile(),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: S.appDisplay,
                  children: [
                    const DarkModeTile(),
                    const Divider(height: 1),
                    const NotificationsTile(),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsGroup(
                  title: S.accountData,
                  children: [
                    SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: S.securityPassword,
                      onTap: () => context.push('/security'),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.category_outlined,
                      title: S.subjects,
                      onTap: () => context.push('/subjects'),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.style_outlined,
                      title: S.flashcards,
                      onTap: () => context.push('/flashcards'),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: S.signOut,
                      danger: true,
                      onTap: () => context.read<AuthCubit>().signOut(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(S.appVersion,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.softOf(context),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    this.studyField,
  });
  final String name;
  final String email;
  final String? studyField;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty
        ? name.characters.first.toUpperCase()
        : (email.isNotEmpty ? email.characters.first.toUpperCase() : 'S');
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(name.isEmpty ? S.student : name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              )),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: AppColors.mutedOf(context)),
          ),
          if (studyField != null && studyField!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _Pill(icon: Icons.school_rounded, label: studyField!.trim()),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _editProfile(context, name, studyField ?? ''),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: AppColors.borderOf(context)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              foregroundColor: AppColors.primaryOf(context),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(S.editProfile),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    String currentName,
    String currentField,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final fieldCtrl = TextEditingController(text: currentField);
    final email = context.read<AuthCubit>().currentUser?.email ?? '';
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(S.editProfile,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOf(ctx),
                      )),
                  const SizedBox(height: 16),
                  Text(S.email,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedOf(ctx),
                      )),
                  const SizedBox(height: 6),
                  Text(email,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOf(ctx),
                      )),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: S.fullName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fieldCtrl,
                    decoration: InputDecoration(labelText: S.studyField),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(S.save),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (saved == true && context.mounted) {
      await context.read<AuthCubit>().updateProfile(
            displayName: nameCtrl.text.trim(),
            studyField: fieldCtrl.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.accountSaved)),
        );
      }
    }
    nameCtrl.dispose();
    fieldCtrl.dispose();
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.primaryOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c,
              )),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.softOf(context),
              )),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
