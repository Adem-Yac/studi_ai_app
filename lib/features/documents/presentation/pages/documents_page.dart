import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/documents_cubit.dart';
import '../../data/models/study_document.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key, required this.onOpenChat});

  final void Function(String prompt) onOpenChat;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DocumentsCubit>()..load(),
      child: _DocumentsView(onOpenChat: onOpenChat),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView({required this.onOpenChat});
  final void Function(String prompt) onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: BlocConsumer<DocumentsCubit, DocumentsState>(
              listenWhen: (a, b) => a.error != b.error && b.error != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error ?? '')),
                );
              },
              builder: (context, state) {
                final cubit = context.read<DocumentsCubit>();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenMargin,
                    12,
                    AppLayout.screenMargin,
                    AppLayout.bottomNavClearance,
                  ),
                  children: [
                    const StudyAIBrandBar(),
                    const SizedBox(height: 4),
                    Text(S.docsSubtitle,
                        style: TextStyle(color: AppColors.mutedOf(context))),
                    const SizedBox(height: 16),
                    _ImportCard(
                      importing: state.importing,
                      onImport: () async {
                        final doc = await cubit.importPdf();
                        if (doc != null && context.mounted) {
                          context.push('/document', extra: doc);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.documents.isEmpty)
                      _EmptyDocs()
                    else ...[
                      SectionHeader(
                        title: S.allFiles,
                        actionLabel: S.filesCount(state.documents.length),
                      ),
                      const SizedBox(height: 8),
                      for (final doc in state.documents)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DocCard(
                            doc: doc,
                            analyzing: state.analyzingId == doc.id,
                            onOpen: () => context.push('/document', extra: doc),
                            onAsk: () => onOpenChat(S.aboutDocument(doc.title)),
                            onDelete: () => cubit.delete(doc),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  const _ImportCard({required this.importing, required this.onImport});
  final bool importing;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: importing ? null : onImport,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.secondary.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.cardOf(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: importing
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Icon(Icons.cloud_upload_outlined,
                      color: AppColors.primaryOf(context), size: 28),
            ),
            const SizedBox(height: 12),
            Text(S.importNewPdf,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textOf(context),
                )),
            const SizedBox(height: 4),
            Text(S.importPdfHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedOf(context),
                )),
          ],
        ),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({
    required this.doc,
    required this.analyzing,
    required this.onOpen,
    required this.onAsk,
    required this.onDelete,
  });

  final StudyDocument doc;
  final bool analyzing;
  final VoidCallback onOpen;
  final VoidCallback onAsk;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('PDF',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOf(context),
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                        '${doc.pages > 0 ? "${doc.pages} ${S.pages} · " : ""}'
                        '${doc.sizeMb} ${S.mbUnit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.softOf(context),
                        )),
                    const SizedBox(width: 8),
                    if (analyzing)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOf(context)),
                          ),
                          const SizedBox(width: 4),
                          Text(S.analyzing,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryOf(context),
                              )),
                        ],
                      )
                    else if (doc.analyzed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(S.synthesized,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.softOf(context)),
            onSelected: (v) {
              switch (v) {
                case 'open':
                  onOpen();
                case 'ask':
                  onAsk();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'open', child: Text(S.open)),
              PopupMenuItem(value: 'ask', child: Text(S.askAboutDoc)),
              PopupMenuItem(
                value: 'delete',
                child: Text(S.delete,
                    style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDocs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded,
              size: 56, color: AppColors.softOf(context)),
          const SizedBox(height: 12),
          Text(S.noDocuments,
              style: TextStyle(color: AppColors.mutedOf(context))),
        ],
      ),
    );
  }
}
