import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../widgets/settings_tiles.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _busy = false;

  Future<void> _snack(String text) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _verifyEmail() async {
    setState(() => _busy = true);
    final err = await context.read<AuthCubit>().sendEmailVerification();
    if (!mounted) return;
    setState(() => _busy = false);
    await _snack(err == null ? S.verificationSent : S.get(err));
  }

  Future<void> _reset() async {
    final email = context.read<AuthCubit>().currentUser?.email ?? '';
    if (email.isEmpty) {
      await _snack(S.get('auth_invalid_email'));
      return;
    }
    setState(() => _busy = true);
    final ok = await context.read<AuthCubit>().sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _busy = false);
    await _snack(ok ? S.get('auth_reset_sent') : S.get('auth_generic_error'));
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(S.changePassword,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(ctx),
                  )),
              const SizedBox(height: 14),
              TextField(
                controller: current,
                obscureText: true,
                decoration: InputDecoration(labelText: S.currentPassword),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: next,
                obscureText: true,
                decoration: InputDecoration(labelText: S.newPassword),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirm,
                obscureText: true,
                decoration: InputDecoration(labelText: S.confirmPassword),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(S.save),
              ),
            ],
          ),
        );
      },
    );
    final cur = current.text;
    final n1 = next.text;
    final n2 = confirm.text;
    current.dispose();
    next.dispose();
    confirm.dispose();
    if (saved != true || !mounted) return;
    if (n1.length < 6) {
      await _snack(S.get('auth_weak_password'));
      return;
    }
    if (n1 != n2) {
      await _snack(S.get('auth_passwords_mismatch'));
      return;
    }
    setState(() => _busy = true);
    final err = await context.read<AuthCubit>().changePassword(
          currentPassword: cur,
          newPassword: n1,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    await _snack(err == null ? S.passwordUpdated : S.get(err));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AuthCubit>();
    final email = cubit.currentUser?.email ?? '';
    final verified = cubit.emailVerified;
    final hasPassword = cubit.hasPasswordProvider;

    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin, 12, AppLayout.screenMargin, 32),
            children: [
              if (_busy) const LinearProgressIndicator(),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.mark_email_read_outlined,
                      title: S.emailVerification,
                      subtitle: verified
                          ? S.emailVerified
                          : S.emailNotVerified,
                      onTap: verified ? null : _verifyEmail,
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.lock_reset_rounded,
                      title: S.resetPasswordEmail,
                      subtitle: email,
                      onTap: _reset,
                    ),
                    if (hasPassword) ...[
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.password_rounded,
                        title: S.changePassword,
                        onTap: _changePassword,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin, 12, AppLayout.screenMargin, 32),
            children: [
              Text(S.privacyBody,
                  style: TextStyle(
                    height: 1.5,
                    color: AppColors.textOf(context),
                  )),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.copy_rounded,
                      title: S.copyAccountInfo,
                      subtitle: user?.email ?? user?.uid,
                      onTap: () {
                        final text = [
                          user?.email ?? '',
                          user?.uid ?? '',
                          user?.displayName ?? '',
                        ].where((e) => e.isNotEmpty).join('\n');
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.copied)),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      title: S.deleteAccount,
                      danger: true,
                      onTap: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final passwordCtrl = TextEditingController();
    final needPassword = context.read<AuthCubit>().hasPasswordProvider;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.deleteAccountConfirm),
            if (needPassword) ...[
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: S.password),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.delete),
          ),
        ],
      ),
    );
    final password = passwordCtrl.text;
    passwordCtrl.dispose();
    if (ok != true || !context.mounted) return;
    final err = await context.read<AuthCubit>().deleteAccount(
          password: needPassword ? password : null,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.get(err))),
      );
    } else {
      context.go('/auth');
    }
  }
}
