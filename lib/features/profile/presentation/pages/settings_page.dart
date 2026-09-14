import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../widgets/settings_tiles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenMargin, 12, AppLayout.screenMargin, 32),
              children: [
                _group(context, S.appearance, const [
                  DarkModeTile(),
                ]),
                const SizedBox(height: 16),
                _group(context, S.languageAndAi, [
                  const LanguageTile(),
                  const Divider(height: 1),
                  const AnswerLevelTile(),
                ]),
                const SizedBox(height: 16),
                _group(context, S.notifications.toUpperCase(), const [
                  NotificationsTile(),
                ]),
                const SizedBox(height: 16),
                _group(context, S.account.toUpperCase(), [
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: S.privacy,
                    onTap: () => context.push('/privacy'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: S.signOut,
                    danger: true,
                    onTap: () => context.read<AuthCubit>().signOut(),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
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
        AppCard(padding: EdgeInsets.zero, child: Column(children: children)),
      ],
    );
  }
}
