import 'package:flutter/material.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/navigation/study_opener.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../data/search_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialQuery ?? '');
  List<SearchHit> _hits = const [];
  bool _loading = false;
  String _last = '';

  @override
  void initState() {
    super.initState();
    if ((_ctrl.text).trim().isNotEmpty) {
      _run(_ctrl.text);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _run(String raw) async {
    final q = raw.trim();
    _last = q;
    if (q.isEmpty) {
      setState(() {
        _hits = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final hits = await getIt<SearchRepository>().search(q);
    if (!mounted || _last != q) return;
    setState(() {
      _hits = hits;
      _loading = false;
    });
  }

  IconData _icon(String kind) => switch (kind) {
        'document' => Icons.picture_as_pdf_rounded,
        'quiz' => Icons.quiz_rounded,
        'flashcard' => Icons.style_rounded,
        'subject' => Icons.category_rounded,
        _ => Icons.menu_book_rounded,
      };

  String _kindLabel(String kind) => switch (kind) {
        'document' => S.navDocs,
        'quiz' => S.quiz,
        'flashcard' => S.flashcards,
        'subject' => S.subjects,
        _ => S.myCourses,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenMargin, 8, AppLayout.screenMargin, 8),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: _run,
                  onSubmitted: _run,
                  decoration: InputDecoration(
                    hintText: S.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.cardOf(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.borderOf(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.borderOf(context)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _ctrl.text.trim().isEmpty
                        ? Center(
                            child: Text(
                              S.searchEmptyHint,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AppColors.mutedOf(context)),
                            ),
                          )
                        : _hits.isEmpty
                            ? Center(
                                child: Text(
                                  S.noSearchResults,
                                  style: TextStyle(
                                      color: AppColors.mutedOf(context)),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppLayout.screenMargin,
                                  4,
                                  AppLayout.screenMargin,
                                  24,
                                ),
                                itemCount: _hits.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final hit = _hits[i];
                                  return AppCard(
                                    onTap: () =>
                                        StudyOpener.openHit(context, hit),
                                    child: Row(
                                      children: [
                                        Icon(_icon(hit.kind),
                                            color: AppColors.primaryOf(context)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(hit.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textOf(context),
                                                  )),
                                              const SizedBox(height: 2),
                                              Text(
                                                [
                                                  _kindLabel(hit.kind),
                                                  if (hit.subtitle.isNotEmpty)
                                                    hit.subtitle,
                                                ].join(' · '),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.softOf(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right_rounded,
                                            color: AppColors.softOf(context)),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
