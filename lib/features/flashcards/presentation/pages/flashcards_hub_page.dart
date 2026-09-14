import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../documents/data/repositories/documents_repository.dart';
import '../../data/models/flashcard_deck.dart';
import '../../data/repositories/flashcards_repository.dart';

class FlashcardsHubPage extends StatefulWidget {
  const FlashcardsHubPage({super.key, this.initialTopic, this.pdfId});

  final String? initialTopic;
  final String? pdfId;

  @override
  State<FlashcardsHubPage> createState() => _FlashcardsHubPageState();
}

class _FlashcardsHubPageState extends State<FlashcardsHubPage> {
  late final TextEditingController _topic =
      TextEditingController(text: widget.initialTopic ?? '');
  List<FlashcardDeck> _decks = const [];
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _load();
    if ((widget.initialTopic ?? '').trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
    }
  }

  Future<void> _load() async {
    final list = await getIt<FlashcardsRepository>().list();
    if (!mounted) return;
    setState(() {
      _decks = list;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _topic.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.enterFlashcardTopic)),
      );
      return;
    }
    setState(() => _generating = true);
    try {
      final bytes = widget.pdfId == null
          ? null
          : await () async {
              final repo = getIt<DocumentsRepository>();
              final cached = repo.bytesFor(widget.pdfId!);
              if (cached != null) return cached;
              final doc = await repo.getById(widget.pdfId!);
              if (doc == null) return null;
              return repo.loadBytes(doc);
            }();
      final deck = await getIt<FlashcardsRepository>().generate(
        topic: topic,
        count: 8,
        pdfBytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _generating = false;
        _decks = [deck, ..._decks.where((d) => d.id != deck.id)];
      });
      context.push('/flashcards/review', extra: deck);
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.generationFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              12,
              AppLayout.screenMargin,
              32,
            ),
            children: [
              Text(S.flashcardsSubtitle,
                  style: TextStyle(color: AppColors.mutedOf(context))),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.generateFlashcards,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textOf(context),
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _topic,
                      onSubmitted: (_) => _generate(),
                      decoration: InputDecoration(
                        hintText: S.flashcardTopicHint,
                        filled: true,
                        fillColor: AppColors.altSurfaceOf(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: S.generateWithGemini,
                      icon: Icons.style_rounded,
                      loading: _generating,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(title: S.yourFlashcards),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_decks.isEmpty)
                Text(S.emptyFlashcardsHint,
                    style: TextStyle(color: AppColors.mutedOf(context)))
              else
                for (final deck in _decks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () =>
                          context.push('/flashcards/review', extra: deck),
                      child: Row(
                        children: [
                          Icon(Icons.style_rounded,
                              color: AppColors.primaryOf(context)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deck.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textOf(context),
                                    )),
                                Text(
                                  S.cardsCount(deck.length),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.softOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await getIt<FlashcardsRepository>()
                                  .delete(deck.id);
                              if (!mounted) return;
                              setState(() {
                                _decks = _decks
                                    .where((d) => d.id != deck.id)
                                    .toList();
                              });
                            },
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
