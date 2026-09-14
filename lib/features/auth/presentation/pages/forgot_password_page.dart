import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/auth_cubit.dart';
import '../widgets/auth_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    final ok = await context.read<AuthCubit>().sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? S.get('auth_reset_sent') : S.get('auth_generic_error')),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Icon(Icons.lock_reset_rounded,
                      size: 64, color: AppColors.primaryOf(context)),
                  const SizedBox(height: 16),
                  Text(
                    S.forgotPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.forgotPasswordHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedOf(context)),
                  ),
                  const SizedBox(height: 28),
                  AuthField(
                    controller: _email,
                    label: S.email,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: S.send,
                    loading: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
