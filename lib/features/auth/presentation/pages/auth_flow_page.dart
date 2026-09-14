import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/auth_cubit.dart';
import '../widgets/auth_field.dart';

class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  bool _isLogin = true;
  bool _justRegistered = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    FocusScope.of(context).unfocus();
    if (_isLogin) {
      _justRegistered = false;
      cubit.signInWithEmail(email: _email.text, password: _password.text);
    } else {
      if (_password.text != _confirm.text) {
        cubit.emitMismatch();
        return;
      }
      _justRegistered = true;
      cubit.signUp(
        email: _email.text,
        password: _password.text,
        displayName: _name.text.trim().isEmpty ? S.studentName : _name.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated && state.messageKey != null) {
              _justRegistered = false;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(S.get(state.messageKey!)),
                  backgroundColor: AppColors.error,
                ));
            } else if (state is AuthAuthenticated && _justRegistered) {
              _justRegistered = false;
              final email = state.user.email;
              // Messenger global : le SnackBar survit à la redirection vers /home.
              rootMessengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  backgroundColor: AppColors.success,
                  content: Text(
                    S.signupEmailShown.replaceAll(
                      '{email}',
                      email.isEmpty ? state.user.email : email,
                    ),
                  ),
                ));
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            final emailLoading = state is AuthEmailLoading;
            final googleLoading = state is AuthGoogleLoading;

            return Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _Segmented(
                        isLogin: _isLogin,
                        onChanged: (v) => setState(() => _isLogin = v),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const StudyAILogo(size: 42),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLogin
                                      ? S.welcomeBack
                                      : S.createAccount,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textOf(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  S.tagline,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                      if (!_isLogin) ...[
                        AuthField(
                          controller: _name,
                          label: S.fullName,
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                      ],
                      AuthField(
                        controller: _email,
                        label: S.email,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      if (!_isLogin)
                        ListenableBuilder(
                          listenable: _email,
                          builder: (context, _) {
                            final shown = _email.text.trim();
                            if (shown.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  shown,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textOf(context),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      AuthField(
                        controller: _password,
                        label: S.password,
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction:
                            _isLogin ? TextInputAction.done : TextInputAction.next,
                        onSubmitted: (_) => _isLogin ? _submit(cubit) : null,
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        AuthField(
                          controller: _confirm,
                          label: S.confirmPassword,
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(cubit),
                        ),
                      ],
                          ],
                        ),
                      ),
                      if (_isLogin) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push('/auth/forgot-password'),
                            child: Text(
                              S.forgotPassword,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      GradientButton(
                        label: _isLogin ? S.login : S.register,
                        icon: Icons.arrow_forward_rounded,
                        loading: emailLoading,
                        onPressed: () => _submit(cubit),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.borderOf(context))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(S.orContinueWith,
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.softOf(context),
                                )),
                          ),
                          Expanded(child: Divider(color: AppColors.borderOf(context))),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GoogleButton(
                        loading: googleLoading,
                        onPressed: cubit.signInWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(color: AppColors.mutedOf(context)),
                            children: [
                              TextSpan(
                                  text: _isLogin ? S.noAccount : S.haveAccount),
                              const TextSpan(text: '  '),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? S.register : S.login,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.altSurfaceOf(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _tab(context, S.login, isLogin, () => onChanged(true)),
          _tab(context, S.register, !isLogin, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.cardOf(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active
                    ? AppColors.primaryOf(context)
                    : AppColors.mutedOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
