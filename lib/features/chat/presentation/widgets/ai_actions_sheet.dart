import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';

class _AiAction {
  const _AiAction(this.icon, this.label, this.color, this.prompt);
  final IconData icon;
  final String label;
  final Color color;
  final String prompt;
}

/// Feuille "Que veux-tu faire ?" (Résumer / Expliquer / Quiz / Flashcards / Traduire).
Future<void> showAiActionsSheet(
  BuildContext context, {
  required void Function(String label, String prompt) onAction,
}) {
  final actions = <_AiAction>[
    _AiAction(Icons.summarize_rounded, S.summarize, AppColors.primary,
        S.promptSummarize),
    _AiAction(Icons.lightbulb_outline_rounded, S.explain, AppColors.secondary,
        S.promptExplain),
    _AiAction(Icons.quiz_rounded, S.generateQuiz, AppColors.success,
        S.promptQuiz),
    _AiAction(Icons.style_rounded, S.flashcards, AppColors.warning,
        S.promptFlashcards),
    _AiAction(Icons.translate_rounded, S.translate, const Color(0xFFEC4899),
        S.promptTranslate),
  ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardOf(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(S.whatToDo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(context),
                  )),
              const SizedBox(height: 16),
              for (final a in actions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: AppColors.altSurfaceOf(context),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onAction(a.label, a.prompt);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: a.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(a.icon, color: a.color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(a.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textOf(context),
                                  )),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 15, color: AppColors.softOf(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
