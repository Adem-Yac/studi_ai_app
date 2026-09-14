/// Un document PDF importé et analysé.
class StudyDocument {
  const StudyDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.subject,
    required this.pages,
    required this.sizeMb,
    this.summary,
    this.retentionScore,
    this.storagePath,
    this.localPath,
  });

  final String id;
  final String title;
  final String fileName;
  final String subject;
  final int pages;
  final double sizeMb;
  final String? summary;
  final int? retentionScore; // 0..100
  final String? storagePath;
  final String? localPath;

  bool get analyzed => summary != null && summary!.isNotEmpty;

  StudyDocument copyWith({String? summary, int? retentionScore}) => StudyDocument(
        id: id,
        title: title,
        fileName: fileName,
        subject: subject,
        pages: pages,
        sizeMb: sizeMb,
        summary: summary ?? this.summary,
        retentionScore: retentionScore ?? this.retentionScore,
        storagePath: storagePath,
        localPath: localPath,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'fileName': fileName,
        'subject': subject,
        'pages': pages,
        'sizeMb': sizeMb,
        'summary': summary,
        'retentionScore': retentionScore,
        'storagePath': storagePath,
      };

  factory StudyDocument.fromMap(String id, Map<String, dynamic> m) =>
      StudyDocument(
        id: id,
        title: (m['title'] ?? '').toString(),
        fileName: (m['fileName'] ?? '').toString(),
        subject: (m['subject'] ?? 'Général').toString(),
        pages: (m['pages'] as num?)?.toInt() ?? 0,
        sizeMb: (m['sizeMb'] as num?)?.toDouble() ?? 0,
        summary: m['summary']?.toString(),
        retentionScore: (m['retentionScore'] as num?)?.toInt(),
        storagePath: m['storagePath']?.toString(),
      );

  static List<StudyDocument> demo() => const [
        StudyDocument(
          id: 'd1',
          title: 'Cours_Architecture_Flutter_Clean',
          fileName: 'Cours_Architecture_Flutter_Clean.pdf',
          subject: 'Flutter',
          pages: 48,
          sizeMb: 4.2,
          retentionScore: 94,
          summary:
              "Ce cours détaille le pattern BLoC, l'injection de dépendances "
              "avec get_it et la séparation en 3 couches (Domain, Data, "
              "Presentation).",
        ),
        StudyDocument(
          id: 'd2',
          title: 'Laravel_C1_API_REST_Documentation',
          fileName: 'Laravel_C1_API_REST_Documentation.pdf',
          subject: 'Laravel',
          pages: 32,
          sizeMb: 2.1,
        ),
        StudyDocument(
          id: 'd3',
          title: 'English_Grammar_C1_Advanced_Notes',
          fileName: 'English_Grammar_C1_Advanced_Notes.pdf',
          subject: 'English C1',
          pages: 18,
          sizeMb: 1.0,
        ),
        StudyDocument(
          id: 'd4',
          title: 'Algorithmique_Complexite_BigO',
          fileName: 'Algorithmique_Complexite_BigO.pdf',
          subject: 'Algorithme',
          pages: 60,
          sizeMb: 3.4,
        ),
      ];
}
