import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/chat_message.dart';
import '../data/repositories/chat_repository.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.sending = false,
    this.loading = false,
    this.error,
    this.aiReady = true,
  });

  final List<ChatMessage> messages;
  final bool sending;
  final bool loading;
  final String? error;
  final bool aiReady;

  bool get isEmpty => messages.isEmpty;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? aiReady,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        aiReady: aiReady ?? this.aiReady,
      );
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState(loading: true));

  final ChatRepository _repository;
  int _seq = 0;

  String _id() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  Future<void> loadHistory() async {
    emit(state.copyWith(loading: true, aiReady: _repository.aiAvailable));
    final history = await _repository.loadHistory();
    emit(state.copyWith(
      messages: history,
      loading: false,
      aiReady: _repository.aiAvailable,
    ));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    final userMsg = ChatMessage(id: _id(), fromUser: true, text: trimmed);
    final pending =
        ChatMessage(id: _id(), fromUser: false, text: '', pending: true);

    final history = List<ChatMessage>.from(state.messages);
    emit(state.copyWith(
      messages: [...history, userMsg, pending],
      sending: true,
      clearError: true,
    ));
    await _repository.persist(userMsg);

    try {
      final reply = await _repository.send(history, trimmed);
      final aiMsg = ChatMessage(id: pending.id, fromUser: false, text: reply);
      _replacePending(pending.id, reply);
      await _repository.persist(aiMsg);
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '')
          : e.toString();
      _replacePending(
        pending.id,
        'Je n’ai pas pu répondre ($msg). Réessaie dans un instant.',
      );
      emit(state.copyWith(error: msg, sending: false));
    }
  }

  Future<void> regenerateLast() async {
    if (state.sending) return;
    final msgs = List<ChatMessage>.from(state.messages);
    final lastAiIndex = msgs.lastIndexWhere((m) => !m.fromUser);
    if (lastAiIndex < 0) return;
    final lastUserIndex = msgs.lastIndexWhere((m) => m.fromUser);
    if (lastUserIndex < 0) return;
    final prompt = msgs[lastUserIndex].text;
    msgs.removeAt(lastAiIndex);

    final pending =
        ChatMessage(id: _id(), fromUser: false, text: '', pending: true);
    final history = msgs.sublist(0, lastUserIndex + 1);
    emit(state.copyWith(messages: [...msgs, pending], sending: true));

    try {
      final reply = await _repository.send(
        history.sublist(0, history.length - 1),
        prompt,
      );
      _replacePending(pending.id, reply);
      await _repository.persist(
        ChatMessage(id: pending.id, fromUser: false, text: reply),
      );
    } catch (e) {
      _replacePending(
        pending.id,
        'Régénération impossible. Réessaie.',
      );
    }
  }

  void _replacePending(String id, String reply) {
    final updated = state.messages
        .map((m) => m.id == id ? m.copyWith(text: reply, pending: false) : m)
        .toList();
    emit(state.copyWith(messages: updated, sending: false));
  }

  Future<void> reset() async {
    await _repository.clearHistory();
    emit(const ChatState());
  }
}
