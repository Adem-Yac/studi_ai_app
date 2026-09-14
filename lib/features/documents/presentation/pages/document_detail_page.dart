import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/pdf_opener.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../chat/data/models/chat_message.dart';
import '../../../quiz/data/repositories/quiz_repository.dart';
import '../../data/models/study_document.dart';
import '../../data/repositories/documents_repository.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({super.key, required this.document});

  final StudyDocument document;

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  final _repo = getIt<DocumentsRepository>();
  late StudyDocument _doc = widget.document;
  bool _analyzing = false;

  Future<void> _analyze() async {
    setState(() => _analyzing = true);
    try {
      await _repo.loadBytes(_doc);
      final summary = await _repo.analyze(_doc);
      if (!mounted) return;
      setState(() {
        _doc = _doc.copyWith(summary: summary);
        _analyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.generationFailed('$e'))),
      );
    }
  }

  Future<void> _generateQuiz() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final bytes = await _repo.loadBytes(_doc);
      final quiz = await getIt<QuizRepository>().generate(
        topic: _doc.title,
        count: 5,
        pdfBytes: bytes,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/quiz/play', extra: quiz);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.generationFailed('$e'))),
      );
    }
  }

  Future<void> _openPdf() async {
    try {
      await PdfOpener.open(_doc);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.pdfUnavailable)),
      );
    }
  }

  Future<void> _sharePdf() async {
    try {
      await PdfOpener.share(_doc);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.pdfUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(
        title: const StudyAIAppBarTitle(),
        actions: [
          IconButton(
            tooltip: S.openPdf,
            onPressed: _openPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: S.share,
            onPressed: _sharePdf,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin, 8, AppLayout.screenMargin, 32),
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_doc.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOf(context),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_doc.pages > 0)
                    Text('${_doc.pages} ${S.pages} · ',
                        style: TextStyle(color: AppColors.softOf(context))),
                  Text('${_doc.sizeMb} ${S.mbUnit}',
                      style: TextStyle(color: AppColors.softOf(context))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 13, color: AppColors.success),
                        const SizedBox(width: 5),
                        Text(S.geminiReady,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openPdf,
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(S.openPdf),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/flashcards', extra: {
                        'topic': _doc.title,
                        'pdfId': _doc.id,
                      }),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: AppColors.borderOf(context)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: const Icon(Icons.style_rounded, size: 18),
                      label: Text(S.flashcards),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _AskSheet.show(context, _doc),
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: Text(S.askAboutDoc),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _analyzing ? null : _analyze,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: AppColors.borderOf(context)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: const Icon(Icons.summarize_rounded, size: 18),
                      label: Text(S.generateSummary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const StudyAILogo(size: 34, radius: 10),
                        const SizedBox(width: 10),
                        Text(S.aiSummary,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.textOf(context),
                            )),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_analyzing)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_doc.analyzed)
                      MarkdownBody(
                        data: _doc.summary!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                                Theme.of(context))
                            .copyWith(
                          p: TextStyle(
                              color: AppColors.textOf(context), height: 1.5),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.noSummaryYet,
                            style:
                                TextStyle(color: AppColors.mutedOf(context)),
                          ),
                          const SizedBox(height: 14),
                          GradientButton(
                            label: S.analyzeWithGemini,
                            icon: Icons.auto_awesome,
                            onPressed: _analyze,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: S.testChapterQuiz,
                icon: Icons.quiz_rounded,
                onPressed: _generateQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feuille "Poser une question sur ce document".
class _AskSheet {
  static void show(BuildContext context, StudyDocument doc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AskSheetBody(doc: doc),
      ),
    );
  }
}

class _AskSheetBody extends StatefulWidget {
  const _AskSheetBody({required this.doc});
  final StudyDocument doc;

  @override
  State<_AskSheetBody> createState() => _AskSheetBodyState();
}

class _AskSheetBodyState extends State<_AskSheetBody> {
  final _input = TextEditingController();
  final _gemini = getIt<GeminiService>();
  final _repo = getIt<DocumentsRepository>();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  int _seq = 0;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _input.text.trim();
    if (q.isEmpty || _loading) return;
    setState(() {
      _messages.add(ChatMessage(id: '${_seq++}', fromUser: true, text: q));
      _loading = true;
      _input.clear();
    });
    String answer;
    try {
      final bytes = _repo.bytesFor(widget.doc.id);
      answer = bytes != null
          ? await _gemini.analyzePdf(bytes, instruction: q)
          : await _gemini.generateText(
              'À propos du document « ${widget.doc.title} » : $q');
    } on GeminiUnavailable catch (e) {
      answer = 'Impossible de répondre pour le moment : ${e.message}';
    } catch (e) {
      answer = 'Erreur : $e';
    }
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(id: '${_seq++}', fromUser: false, text: answer));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderOf(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(S.askAboutDoc,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textOf(context),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          S.askAboutNamed(widget.doc.title),
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.mutedOf(context)),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final m = _messages[i];
                          return Align(
                            alignment: m.fromUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              decoration: BoxDecoration(
                                gradient: m.fromUser
                                    ? AppColors.brandGradient
                                    : null,
                                color: m.fromUser
                                    ? null
                                    : AppColors.altSurfaceOf(context),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: m.fromUser
                                  ? Text(m.text,
                                      style: const TextStyle(
                                          color: Colors.white))
                                  : MarkdownBody(data: m.text, selectable: true),
                            ),
                          );
                        },
                      ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _ask(),
                      decoration: InputDecoration(
                        hintText: S.yourQuestion,
                        filled: true,
                        fillColor: AppColors.altSurfaceOf(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _ask,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
