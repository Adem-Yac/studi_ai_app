import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../data/models/flashcard_deck.dart';

class FlashcardReviewPage extends StatefulWidget {
  const FlashcardReviewPage({super.key, required this.deck});

  final FlashcardDeck deck;

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  int _index = 0;
  bool _showBack = false;

  Flashcard get _card => widget.deck.cards[_index];

  void _flip() => setState(() => _showBack = !_showBack);

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.deck.cards.length) return;
    setState(() {
      _index = next;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.deck.cards.length;
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin, 8, AppLayout.screenMargin, 24),
            child: Column(
              children: [
                Text(widget.deck.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textOf(context),
                    )),
                const SizedBox(height: 6),
                Text('${_index + 1} / $total',
                    style: TextStyle(color: AppColors.softOf(context))),
                const SizedBox(height: 18),
                Expanded(
                  child: GestureDetector(
                    onTap: _flip,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Container(
                        key: ValueKey('${_index}_$_showBack'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: _showBack ? AppColors.brandGradient : null,
                          color: _showBack
                              ? null
                              : AppColors.cardOf(context),
                          borderRadius: BorderRadius.circular(24),
                          border: _showBack
                              ? null
                              : Border.all(color: AppColors.borderOf(context)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showBack ? S.answer : S.question,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: _showBack
                                    ? Colors.white70
                                    : AppColors.softOf(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showBack ? _card.back : _card.front,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                                color: _showBack
                                    ? Colors.white
                                    : AppColors.textOf(context),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              S.tapToFlip,
                              style: TextStyle(
                                fontSize: 12,
                                color: _showBack
                                    ? Colors.white70
                                    : AppColors.mutedOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _index == 0 ? null : () => _go(-1),
                        child: Text(S.previous),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            _index >= total - 1 ? null : () => _go(1),
                        child: Text(S.next),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
