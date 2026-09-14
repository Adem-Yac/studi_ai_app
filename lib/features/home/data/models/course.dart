import 'package:flutter/material.dart';

/// Un cours suivi par l'étudiant.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.subject,
    required this.chapter,
    required this.progress,
    required this.color,
    this.updatedLabel = '',
  });

  final String id;
  final String title;
  final String subject;
  final String chapter;
  final double progress; // 0..1
  final Color color;
  final String updatedLabel;

  static const List<Color> palette = [
    Color(0xFF5B5FEF),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  factory Course.fromMap(String id, Map<String, dynamic> m) => Course(
        id: id,
        title: (m['title'] ?? '').toString(),
        subject: (m['subject'] ?? '').toString(),
        chapter: (m['chapter'] ?? '').toString(),
        progress: (m['progress'] as num?)?.toDouble() ?? 0,
        color: palette[(m['colorIndex'] as num?)?.toInt() ?? 0 % palette.length],
        updatedLabel: (m['updatedLabel'] ?? '').toString(),
      );

  static List<Course> demo() => const [
        Course(
          id: 'c1',
          title: 'Flutter & Firebase Architecture',
          subject: 'Flutter',
          chapter: 'Chapitre 4 · State Management & Services',
          progress: 0.8,
          color: Color(0xFF5B5FEF),
          updatedLabel: 'il y a 2h',
        ),
        Course(
          id: 'c2',
          title: 'Laravel Eloquent ORM',
          subject: 'Laravel',
          chapter: 'Chapitre 2 · Migrations & Relations',
          progress: 0.55,
          color: Color(0xFF8B5CF6),
          updatedLabel: 'hier',
        ),
        Course(
          id: 'c3',
          title: 'English C1 · Academic Writing',
          subject: 'English C1',
          chapter: 'Unit 3 · Essays',
          progress: 0.4,
          color: Color(0xFF10B981),
          updatedLabel: 'il y a 3j',
        ),
        Course(
          id: 'c4',
          title: 'Algorithmique & Complexité',
          subject: 'Algorithme',
          chapter: 'Chapitre 5 · Big-O',
          progress: 0.65,
          color: Color(0xFFF59E0B),
          updatedLabel: 'il y a 5j',
        ),
      ];
}
