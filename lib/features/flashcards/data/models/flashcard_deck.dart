/// Une carte question / réponse.
class Flashcard {
  const Flashcard({required this.front, required this.back});

  final String front;
  final String back;

  factory Flashcard.fromMap(Map<String, dynamic> m) => Flashcard(
        front: (m['front'] ?? '').toString(),
        back: (m['back'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {'front': front, 'back': back};
}

/// Paquet de flashcards persisté.
class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.cards,
    this.subject = '',
  });

  final String id;
  final String title;
  final String subject;
  final List<Flashcard> cards;

  int get length => cards.length;

  factory FlashcardDeck.fromMap(String id, Map<String, dynamic> m) =>
      FlashcardDeck(
        id: id,
        title: (m['title'] ?? '').toString(),
        subject: (m['subject'] ?? '').toString(),
        cards: (m['cards'] as List<dynamic>? ?? [])
            .map((e) => Flashcard.fromMap(Map<String, dynamic>.from(e as Map)))
            .where((c) => c.front.trim().isNotEmpty)
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'cards': cards.map((c) => c.toMap()).toList(),
      };
}
