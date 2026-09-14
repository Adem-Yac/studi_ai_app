import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/l10n/app_strings.dart';
import '../data/models/study_document.dart';
import '../data/repositories/documents_repository.dart';

class DocumentsState {
  const DocumentsState({
    this.documents = const [],
    this.loading = true,
    this.importing = false,
    this.analyzingId,
    this.error,
  });

  final List<StudyDocument> documents;
  final bool loading;
  final bool importing;
  final String? analyzingId;
  final String? error;

  DocumentsState copyWith({
    List<StudyDocument>? documents,
    bool? loading,
    bool? importing,
    String? analyzingId,
    bool clearAnalyzing = false,
    String? error,
    bool clearError = false,
  }) =>
      DocumentsState(
        documents: documents ?? this.documents,
        loading: loading ?? this.loading,
        importing: importing ?? this.importing,
        analyzingId: clearAnalyzing ? null : (analyzingId ?? this.analyzingId),
        error: clearError ? null : (error ?? this.error),
      );
}

class DocumentsCubit extends Cubit<DocumentsState> {
  DocumentsCubit(this._repository) : super(const DocumentsState());

  final DocumentsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final docs = await _repository.list();
      emit(state.copyWith(documents: docs, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Sélectionne + importe un PDF. Renvoie le document créé (ou null si annulé).
  Future<StudyDocument?> importPdf() async {
    emit(state.copyWith(importing: true, clearError: true));
    try {
      final picked = await _repository.pickPdf();
      if (picked == null) {
        emit(state.copyWith(importing: false));
        return null;
      }
      final doc = await _repository.importPdf(
        picked,
        subject: S.generalSubject,
      );
      emit(state.copyWith(
        documents: [doc, ...state.documents],
        importing: false,
      ));
      return doc;
    } catch (e) {
      emit(state.copyWith(importing: false, error: e.toString()));
      return null;
    }
  }

  Future<void> analyze(StudyDocument doc) async {
    emit(state.copyWith(analyzingId: doc.id, clearError: true));
    try {
      final summary = await _repository.analyze(doc);
      final updated = state.documents
          .map((d) => d.id == doc.id ? d.copyWith(summary: summary) : d)
          .toList();
      emit(state.copyWith(documents: updated, clearAnalyzing: true));
    } catch (e) {
      emit(state.copyWith(clearAnalyzing: true, error: e.toString()));
    }
  }

  Future<void> delete(StudyDocument doc) async {
    await _repository.delete(doc);
    emit(state.copyWith(
      documents: state.documents.where((d) => d.id != doc.id).toList(),
    ));
  }
}
