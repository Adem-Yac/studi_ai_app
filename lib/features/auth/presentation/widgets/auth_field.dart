import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';

/// Champ de saisie stylé (icône + label + toggle mot de passe).
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: widget.obscure && _hidden,
          enableSuggestions: !widget.obscure,
          autocorrect: !widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.obscure
              ? const [AutofillHints.password]
              : (widget.keyboardType == TextInputType.emailAddress
                  ? const [AutofillHints.email]
                  : const [AutofillHints.name]),
          style: TextStyle(color: AppColors.textOf(context)),
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon,
                color: AppColors.mutedOf(context), size: 20),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.mutedOf(context),
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardOf(context),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderOf(context), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton "Continuer avec Google".
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onPressed, this.loading = false});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderOf(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          foregroundColor: AppColors.textOf(context),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stack) => const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 26,
                    color: Color(0xFFEA4335)),
              ),
        label: Text(
          S.continueWithGoogle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textOf(context),
          ),
        ),
      ),
    );
  }
}
