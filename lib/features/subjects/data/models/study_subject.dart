import 'package:flutter/material.dart';

import '../../../home/data/models/course.dart';

/// Matière créée par l'étudiant.
class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    this.colorIndex = 0,
  });

  final String id;
  final String name;
  final int colorIndex;

  Color get color => Course.palette[colorIndex % Course.palette.length];

  Map<String, dynamic> toMap() => {
        'name': name,
        'colorIndex': colorIndex,
      };

  factory StudySubject.fromMap(String id, Map<String, dynamic> m) =>
      StudySubject(
        id: id,
        name: (m['name'] ?? '').toString(),
        colorIndex: (m['colorIndex'] as num?)?.toInt() ?? 0,
      );
}
