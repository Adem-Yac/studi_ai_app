/// Un message de conversation IA.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fromUser,
    required this.text,
    DateTime? createdAt,
    this.pending = false,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final bool fromUser;
  final String text;
  final DateTime createdAt;
  final bool pending;

  ChatMessage copyWith({String? text, bool? pending}) => ChatMessage(
        id: id,
        fromUser: fromUser,
        text: text ?? this.text,
        createdAt: createdAt,
        pending: pending ?? this.pending,
      );

  Map<String, dynamic> toMap() => {
        'fromUser': fromUser,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) {
    final raw = m['createdAt'];
    DateTime created;
    if (raw is DateTime) {
      created = raw;
    } else if (raw is String) {
      created = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      try {
        created = (raw as dynamic).toDate() as DateTime;
      } catch (_) {
        created = DateTime.now();
      }
    }
    return ChatMessage(
      id: id,
      fromUser: m['fromUser'] as bool? ?? false,
      text: (m['text'] ?? '').toString(),
      createdAt: created,
    );
  }
}
