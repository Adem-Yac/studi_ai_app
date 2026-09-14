import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../home/data/models/course.dart';
import '../../cubit/subjects_cubit.dart';
import '../../data/models/study_subject.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubjectsCubit>()..load(),
      child: const _SubjectsView(),
    );
  }
}

class _SubjectsView extends StatelessWidget {
  const _SubjectsView();

  Future<void> _edit(
    BuildContext context, {
    StudySubject? existing,
  }) async {
    final ctrl = TextEditingController(text: existing?.name ?? '');
    var colorIndex = existing?.colorIndex ??
        (DateTime.now().millisecond % Course.palette.length);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
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
                  Text(
                    existing == null ? S.addSubject : S.editSubject,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOf(ctx),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: S.subjectName),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < Course.palette.length; i++)
                        GestureDetector(
                          onTap: () => setLocal(() => colorIndex = i),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Course.palette[i],
                            child: colorIndex == i
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                    ],
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
      },
    );
    final name = ctrl.text.trim();
    ctrl.dispose();
    if (saved != true || name.isEmpty || !context.mounted) return;
    final cubit = context.read<SubjectsCubit>();
    if (existing == null) {
      await cubit.add(name, colorIndex: colorIndex);
    } else {
      await cubit.save(StudySubject(
        id: existing.id,
        name: name,
        colorIndex: colorIndex,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(title: const StudyAIAppBarTitle()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(S.addSubject),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: BlocBuilder<SubjectsCubit, SubjectsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    S.emptySubjectsHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedOf(context)),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenMargin,
                  12,
                  AppLayout.screenMargin,
                  96,
                ),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = state.items[i];
                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: s.color, radius: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textOf(context),
                              )),
                        ),
                        IconButton(
                          tooltip: S.editSubject,
                          onPressed: () => _edit(context, existing: s),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: S.delete,
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(S.deleteSubject),
                                content: Text(S.deleteSubjectConfirm(s.name)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(S.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text(S.delete),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true && context.mounted) {
                              await context.read<SubjectsCubit>().remove(s);
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
