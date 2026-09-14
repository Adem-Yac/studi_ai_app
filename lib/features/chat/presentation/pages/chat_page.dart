import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/chat_cubit.dart';
import '../../data/models/chat_message.dart';
import '../chat_launcher.dart';
import '../widgets/ai_actions_sheet.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatCubit>(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    ChatLauncher.pending.addListener(_consumePending);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePending());
  }

  void _consumePending() {
    final prompt = ChatLauncher.consume();
    if (prompt != null && prompt.trim().isNotEmpty && mounted) {
      _send(prompt);
    }
  }

  @override
  void dispose() {
    ChatLauncher.pending.removeListener(_consumePending);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    context.read<ChatCubit>().sendMessage(value);
    _input.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        child: Column(
          children: [
            const _ChatHeader(),
            const _ActionChips(),
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (a, b) =>
                    a.messages.length != b.messages.length ||
                    a.error != b.error,
                listener: (context, state) {
                  _scrollToBottom();
                  if (state.error != null && state.error!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error!)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.isEmpty) return const _EmptyChat();
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) =>
                        _MessageBubble(message: state.messages[i]),
                  );
                },
              ),
            ),
            _InputBar(
              controller: _input,
              onSend: () => _send(_input.text),
              onAttach: () => showAiActionsSheet(
                context,
                onAction: (label, prompt) {
                  if (label == S.flashcards) {
                    context.push('/flashcards');
                    return;
                  }
                  _send(prompt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: StudyAIBrandBar(
        trailing: IconButton(
          onPressed: () => context.read<ChatCubit>().reset(),
          icon: Icon(Icons.refresh_rounded, color: AppColors.mutedOf(context)),
        ),
      ),
    );
  }
}

class _ActionChips extends StatelessWidget {
  const _ActionChips();

  @override
  Widget build(BuildContext context) {
    final chips = <(IconData, String, String?)>[
      (Icons.summarize_rounded, S.summarize, S.chatSummarizePrompt),
      (Icons.lightbulb_outline_rounded, S.explain, S.chatExplainPrompt),
      (Icons.quiz_outlined, S.generateQuiz, S.chatQuizPrompt),
      (Icons.style_rounded, S.flashcards, null),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = chips[i];
          return ActionChip(
            avatar: Icon(c.$1, size: 16, color: AppColors.primaryOf(context)),
            label: Text(c.$2),
            labelStyle: TextStyle(
              color: AppColors.primaryOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            backgroundColor: AppColors.chipOf(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide.none,
            ),
            onPressed: () {
              final prompt = c.$3;
              if (prompt == null) {
                context.push('/flashcards');
                return;
              }
              context.read<ChatCubit>().sendMessage(prompt);
            },
          );
        },
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StudyAILogo(size: 72),
            const SizedBox(height: 20),
            Text(S.askFirstQuestion,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOf(context),
                )),
            const SizedBox(height: 8),
            Text(
              S.emptyChatHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedOf(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.brandGradient : null,
                color: isUser ? null : AppColors.cardOf(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.borderOf(context)),
              ),
              child: message.pending
                  ? const _TypingIndicator()
                  : (isUser
                      ? Text(message.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, height: 1.4))
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: _markdownStyle(context),
                        )),
            ),
            if (!isUser && !message.pending) _AiActions(text: message.text),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      p: TextStyle(
          color: AppColors.textOf(context), fontSize: 15, height: 1.5),
      code: const TextStyle(
        color: Color(0xFFE1E0FF),
        backgroundColor: Colors.transparent,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF11162A),
        borderRadius: BorderRadius.circular(12),
      ),
      codeblockPadding: const EdgeInsets.all(14),
    );
  }
}

class _AiActions extends StatelessWidget {
  const _AiActions({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          _MiniAction(
            icon: Icons.copy_rounded,
            label: S.copy,
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.copied), duration: const Duration(seconds: 1)),
              );
            },
          ),
          const SizedBox(width: 4),
          _MiniAction(
            icon: Icons.refresh_rounded,
            label: S.regenerate,
            onTap: () => context.read<ChatCubit>().regenerateLast(),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.mutedOf(context),
      ),
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = (_c.value + i * 0.2) % 1.0;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.4 + 0.6 * (1 - (t - 0.5).abs() * 2)),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        const SizedBox(width: 8),
        Text(S.aiThinking,
            style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context))),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldOf(context),
        border: Border(top: BorderSide(color: AppColors.borderOf(context))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach,
            icon: Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primaryOf(context)),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.cardOf(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: TextStyle(color: AppColors.textOf(context)),
                      decoration: InputDecoration(
                        hintText: S.typeMessage,
                        hintStyle: TextStyle(color: AppColors.softOf(context)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none_rounded, color: AppColors.softOf(context)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
