import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/app_settings.dart';
import '../../app/firebase_bootstrap.dart';
import '../../app/gemini_config.dart';

/// Levée quand l'IA n'est pas disponible ou qu'un appel a échoué.
class GeminiUnavailable implements Exception {
  const GeminiUnavailable([this.message = 'IA indisponible']);
  final String message;
  @override
  String toString() => 'GeminiUnavailable: $message';
}

class AiTurn {
  const AiTurn({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

class GeneratedFlashcard {
  const GeneratedFlashcard({required this.front, required this.back});
  final String front;
  final String back;
}

class GeneratedQuestion {
  const GeneratedQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// Gemini : Firebase AI Logic en priorité, sinon l'API Gemini (clé locale).
class GeminiService {
  GeminiService();

  static const String _firebaseModel = 'gemini-3.6-flash';
  static const List<String> _httpModels = [
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3-flash',
  ];

  GenerativeModel? _cachedModel;
  String? _cachedLang;
  String? _workingHttpModel;

  bool get isAvailable => firebaseReady || GeminiConfig.hasDirectKey;

  String get _langCode => AppSettings.lang.value;

  String get _langName => switch (_langCode) {
        'en' => 'English',
        'ar' => 'Modern Standard Arabic (العربية الفصحى)',
        _ => 'French (français)',
      };

  String get _levelLabel => switch ((_langCode, AppSettings.answerLevel.value)) {
        ('en', AnswerLevel.simple) => 'simple and accessible',
        ('en', AnswerLevel.expert) => 'expert, precise and technical',
        ('en', _) => 'university-level, clear and structured',
        ('ar', AnswerLevel.simple) => 'بسيط وواضح للجميع',
        ('ar', AnswerLevel.expert) => 'خبير ودقيق وتقني',
        ('ar', _) => 'جامعي واضح ومنظّم',
        (_, AnswerLevel.simple) => 'simple et accessible (vulgarisation)',
        (_, AnswerLevel.expert) => 'expert, précis et technique',
        _ => 'universitaire, clair et structuré',
      };

  String get _languageLock => switch (_langCode) {
        'en' =>
          'OUTPUT LANGUAGE: English. Write the entire answer in English. '
              'Do not use French or Arabic except unavoidable proper nouns, formulas, or code.',
        'ar' =>
          'لغة الإخراج: العربية الفصحى. اكتب الإجابة كاملة بالعربية. '
              'لا تستخدم الفرنسية أو الإنجليزية إلا في أسماء الأعلام أو المعادلات أو التعليمات البرمجية.',
        _ =>
          'LANGUE DE SORTIE : français. Rédige toute la réponse en français. '
              'N’utilise pas l’anglais ni l’arabe sauf noms propres, formules ou code.',
      };

  String _withLanguage(String prompt) => '$_languageLock\n\n$prompt';

  String get _systemPrompt => switch (_langCode) {
        'en' =>
          'You are StudyAI, a kind and versatile study assistant. '
          'You can help with any subject (math, science, computer science, languages, '
          'history, economics, and more): explain, summarize, make quizzes or flashcards. '
          'A PDF is optional. Always reply in English at a $_levelLabel level. '
          '$_languageLock Use Markdown when useful. Give concrete examples. '
          'Never assume the student’s country, major, or another language.',
        'ar' =>
          'أنت StudyAI، مساعد دراسة ودود ومتعدد التخصصات. '
          'يمكنك المساعدة في أي مادة (رياضيات، علوم، حاسوب، لغات، تاريخ، اقتصاد وغيرها): '
          'شرح، تلخيص، اختبارات أو بطاقات مراجعة. ملف PDF اختياري. '
          'أجب دائماً بالعربية الفصحى وبمستوى $_levelLabel. '
          '$_languageLock استخدم Markdown عند الحاجة وأعط أمثلة واضحة. '
          'لا تفترض تخصص الطالب أو بلده أو لغة أخرى.',
        _ =>
          "Tu es StudyAI, un assistant d'étude polyvalent et bienveillant. "
          "Tu peux répondre à n'importe quel sujet d'étude (maths, sciences, "
          "informatique, langues, histoire, économie, etc.) : expliquer, résumer, "
          "créer des QCM ou des fiches. Un PDF est optionnel. "
          "Réponds toujours en français avec un niveau $_levelLabel. "
          "$_languageLock Utilise le Markdown quand c'est utile, donne des exemples concrets. "
          "Ne suppose jamais une filière, un pays ou une autre langue.",
      };

  String get summaryInstruction => switch (_langCode) {
        'en' =>
          'Summarize this course document into a clear revision sheet '
          '(key points and important concepts). Write the whole summary in English.',
        'ar' =>
          'لخّص مستند الدرس هذا في ورقة مراجعة واضحة (نقاط أساسية ومفاهيم مهمة). '
          'اكتب الملخص كاملاً بالعربية الفصحى.',
        _ =>
          'Résume ce document de cours en une synthèse claire '
          '(points clés et concepts importants) pour réviser. '
          'Rédige toute la synthèse en français.',
      };

  GenerativeModel _firebaseModelInstance({
    GenerationConfig? config,
    String? system,
  }) {
    if (!firebaseReady) throw const GeminiUnavailable('Firebase non initialisé');
    if (_cachedLang != _langCode) {
      _cachedModel = null;
      _cachedLang = _langCode;
    }
    if (config == null && system == null && _cachedModel != null) {
      return _cachedModel!;
    }
    final model = FirebaseAI.googleAI().generativeModel(
      model: _firebaseModel,
      generationConfig: config,
      systemInstruction: Content.system(system ?? _systemPrompt),
    );
    if (config == null && system == null) _cachedModel = model;
    return model;
  }

  Future<String> generateText(String prompt) => _generate(
        contents: [
          {
            'role': 'user',
            'parts': [
              {'text': _withLanguage(prompt)}
            ]
          }
        ],
        firebase: () async {
          final res = await _firebaseModelInstance()
              .generateContent([Content.text(_withLanguage(prompt))]);
          return res.text?.trim();
        },
      );

  Future<String> chat(List<AiTurn> history, String message) => _generate(
        contents: [
          for (final t in history)
            {
              'role': t.fromUser ? 'user' : 'model',
              'parts': [
                {'text': t.text}
              ]
            },
          {
            'role': 'user',
            'parts': [
              {'text': _withLanguage(message)}
            ]
          },
        ],
        firebase: () async {
          final chatSession = _firebaseModelInstance().startChat(
            history: history
                .map((t) => t.fromUser
                    ? Content.text(t.text)
                    : Content.model([TextPart(t.text)]))
                .toList(),
          );
          final res = await chatSession
              .sendMessage(Content.text(_withLanguage(message)));
          return res.text?.trim();
        },
      );

  Future<String> summarize(String content) => generateText(
        switch (_langCode) {
          'en' =>
            'Summarize the following course into key revision points. '
                'Write the whole summary in English.\n\n$content',
          'ar' =>
            'لخّص الدرس التالي في نقاط مراجعة أساسية. '
                'اكتب الملخص كاملاً بالعربية الفصحى.\n\n$content',
          _ =>
            'Résume le cours suivant en points clés pour réviser. '
                'Rédige toute la synthèse en français.\n\n$content',
        },
      );

  Future<String> explain(String content) => generateText(
        switch (_langCode) {
          'en' =>
            'Explain this pedagogically, with a concrete example, in English:\n\n$content',
          'ar' =>
            'اشرح هذا بأسلوب تعليمي مع مثال واضح، بالعربية الفصحى:\n\n$content',
          _ =>
            'Explique de façon pédagogique, avec un exemple concret, en français :\n\n$content',
        },
      );

  Future<String> translate(String content, {String? to}) {
    final target = to ?? _langName;
    return generateText(switch (_langCode) {
      'en' => 'Translate the following text into $target:\n\n$content',
      'ar' => 'ترجم النص التالي إلى $target:\n\n$content',
      _ => 'Traduis le texte suivant en $target :\n\n$content',
    });
  }

  Future<String> analyzePdf(Uint8List bytes,
      {required String instruction}) async {
    final locked = _withLanguage(instruction);
    return _generate(
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': locked},
            {
              'inline_data': {
                'mime_type': 'application/pdf',
                'data': base64Encode(bytes),
              }
            },
          ]
        }
      ],
      firebase: () async {
        final res = await _firebaseModelInstance().generateContent([
          Content.multi([
            TextPart(locked),
            InlineDataPart('application/pdf', bytes),
          ]),
        ]);
        return res.text?.trim();
      },
    );
  }

  Future<List<GeneratedQuestion>> generateQuiz({
    required String topic,
    int count = 5,
    Uint8List? pdfBytes,
  }) async {
    final instruction = switch (_langCode) {
      'en' =>
        'Create a $count-question multiple-choice quiz about: $topic.\n'
            'Each question must have exactly 4 options, one correct answer '
            '(correctIndex 0-3), and a short explanation.\n'
            'CRITICAL: The question text, ALL 4 options, and the explanation '
            'MUST be written entirely in English.\n'
            'JSON keys stay in English. Return ONLY a JSON array: '
            '[{question, options, correctIndex, explanation}].',
      'ar' =>
        'أنشئ اختبار اختيار من متعدد من $count أسئلة حول: $topic.\n'
            'كل سؤال يجب أن يحتوي على 4 خيارات بالضبط، وإجابة صحيحة واحدة '
            '(correctIndex من 0 إلى 3)، وشرح قصير.\n'
            'مهم جداً: نص السؤال والخيارات الأربعة كلها والشرح يجب أن تُكتب '
            'بالعربية الفصحى فقط.\n'
            'مفاتيح JSON تبقى بالإنجليزية. أرجع مصفوفة JSON فقط: '
            '[{question, options, correctIndex, explanation}].',
      _ =>
        'Génère un QCM de $count questions sur : $topic.\n'
            'Chaque question doit avoir exactement 4 options, une bonne réponse '
            '(correctIndex 0-3) et une explication courte.\n'
            'OBLIGATOIRE : le texte de la question, les 4 options et '
            'l’explication doivent être entièrement en français.\n'
            'Les clés JSON restent en anglais. Réponds UNIQUEMENT avec un '
            'tableau JSON : [{question, options, correctIndex, explanation}].',
    };

    final locked = _withLanguage(instruction);

    final raw = await _generate(
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': locked},
            if (pdfBytes != null)
              {
                'inline_data': {
                  'mime_type': 'application/pdf',
                  'data': base64Encode(pdfBytes),
                }
              },
          ]
        }
      ],
      jsonMode: true,
      firebase: () async {
        final schema = Schema.array(
          items: Schema.object(
            properties: {
              'question': Schema.string(),
              'options': Schema.array(items: Schema.string()),
              'correctIndex': Schema.integer(
                description: 'Index (0-3) de la bonne réponse dans options',
              ),
              'explanation': Schema.string(),
            },
          ),
        );
        final config = GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
        );
        final content = <Content>[
          if (pdfBytes != null)
            Content.multi([
              TextPart(locked),
              InlineDataPart('application/pdf', pdfBytes),
            ])
          else
            Content.text(locked),
        ];
        final res =
            await _firebaseModelInstance(config: config).generateContent(content);
        return res.text?.trim();
      },
    );

    try {
      final decoded = jsonDecode(_extractJson(raw));
      final list = decoded is List
          ? decoded
          : (decoded is Map && decoded['questions'] is List)
              ? decoded['questions'] as List
              : throw const FormatException('JSON QCM inattendu');
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        final options = (m['options'] as List<dynamic>? ?? [])
            .map((o) => o.toString())
            .toList();
        return GeneratedQuestion(
          question: (m['question'] ?? '').toString(),
          options: options,
          correctIndex: (m['correctIndex'] as num?)?.toInt() ?? 0,
          explanation: (m['explanation'] ?? '').toString(),
        );
      }).toList();
    } on FormatException catch (e) {
      throw GeminiUnavailable('Réponse IA illisible: ${e.message}');
    }
  }

  Future<List<GeneratedFlashcard>> generateFlashcards({
    required String topic,
    int count = 8,
    Uint8List? pdfBytes,
  }) async {
    final instruction = switch (_langCode) {
      'en' =>
        'Create $count flashcards about: $topic.\n'
            'Each card has a short question (front) and a concise answer (back).\n'
            'CRITICAL: front and back MUST be entirely in English.\n'
            'Return ONLY JSON: [{front, back}].',
      'ar' =>
        'أنشئ $count بطاقات مراجعة حول: $topic.\n'
            'كل بطاقة سؤال قصير (front) وجواب موجز (back).\n'
            'مهم: front و back بالعربية الفصحى فقط.\n'
            'أرجع JSON فقط: [{front, back}].',
      _ =>
        'Crée $count flashcards sur : $topic.\n'
            'Chaque carte a une question courte (front) et une réponse concise (back).\n'
            'OBLIGATOIRE : front et back entièrement en français.\n'
            'JSON uniquement : [{front, back}].',
    };
    final locked = _withLanguage(instruction);
    final raw = await _generate(
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': locked},
            if (pdfBytes != null)
              {
                'inline_data': {
                  'mime_type': 'application/pdf',
                  'data': base64Encode(pdfBytes),
                }
              },
          ]
        }
      ],
      jsonMode: true,
      firebase: () async {
        final schema = Schema.array(
          items: Schema.object(
            properties: {
              'front': Schema.string(),
              'back': Schema.string(),
            },
          ),
        );
        final res = await _firebaseModelInstance(
          config: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: schema,
          ),
        ).generateContent([
          if (pdfBytes != null)
            Content.multi([
              TextPart(locked),
              InlineDataPart('application/pdf', pdfBytes),
            ])
          else
            Content.text(locked),
        ]);
        return res.text?.trim();
      },
    );
    try {
      final decoded = jsonDecode(_extractJson(raw));
      final list = decoded is List
          ? decoded
          : (decoded is Map && decoded['cards'] is List)
              ? decoded['cards'] as List
              : throw const FormatException('JSON flashcards inattendu');
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return GeneratedFlashcard(
          front: (m['front'] ?? m['question'] ?? '').toString(),
          back: (m['back'] ?? m['answer'] ?? '').toString(),
        );
      }).where((c) => c.front.trim().isNotEmpty && c.back.trim().isNotEmpty).toList();
    } on FormatException catch (e) {
      throw GeminiUnavailable('Réponse IA illisible: ${e.message}');
    }
  }

  Future<String> _generate({
    required List<Map<String, dynamic>> contents,
    required Future<String?> Function() firebase,
    bool jsonMode = false,
  }) async {
    // HTTP d'abord. Firebase AI Logic est désactivé tant que App Check
    // n'est pas forcé — on n'essaie pas ce chemin si une clé directe existe.
    if (GeminiConfig.hasDirectKey) {
      final text = await _httpGenerate(contents, jsonMode: jsonMode);
      if (text.isNotEmpty) return text;
    } else if (firebaseReady) {
      try {
        final text = await firebase();
        if (text != null && text.isNotEmpty) return text;
      } on FirebaseAIException catch (e) {
        debugPrint('[StudyAI] Firebase AI: ${e.message}');
      } catch (e) {
        debugPrint('[StudyAI] Firebase AI: $e');
      }
    }

    throw const GeminiUnavailable(
      'Impossible de joindre Gemini. Vérifie internet et réessaie.',
    );
  }

  Future<String> _httpGenerate(
    List<Map<String, dynamic>> contents, {
    bool jsonMode = false,
  }) async {
    final models = [
      ?_workingHttpModel,
      ..._httpModels.where((m) => m != _workingHttpModel),
    ];
    Object? lastError;
    for (final model in models) {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final text = await _httpCall(model, contents, jsonMode: jsonMode);
          _workingHttpModel = model;
          return text;
        } catch (e) {
          lastError = e;
          debugPrint('[StudyAI] Gemini HTTP $model try ${attempt + 1}: $e');
          final msg = e.toString();
          final gone = msg.contains('404') || msg.contains('NOT_FOUND');
          if (gone) break;
          final busy = msg.contains('503') ||
              msg.contains('429') ||
              msg.contains('UNAVAILABLE') ||
              msg.contains('high demand');
          if (!busy) break;
          await Future<void>.delayed(Duration(seconds: 1 + attempt * 2));
        }
      }
    }
    throw GeminiUnavailable(lastError?.toString() ?? 'Gemini HTTP échoué');
  }

  Future<String> _httpCall(
    String model,
    List<Map<String, dynamic>> contents, {
    required bool jsonMode,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent?key=${GeminiConfig.apiKey}',
    );
    final body = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        if (jsonMode) 'responseMimeType': 'application/json',
        'thinkingConfig': {'thinkingLevel': 'low'},
      },
    };
    final res = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': GeminiConfig.apiKey,
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw GeminiUnavailable('HTTP ${res.statusCode}: ${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiUnavailable('Réponse Gemini vide');
    }
    final parts = (((candidates.first as Map)['content'] as Map?)?['parts']
            as List<dynamic>?) ??
        const [];
    final buffer = StringBuffer();
    for (final part in parts) {
      final text = (part as Map)['text']?.toString();
      if (text != null) buffer.write(text);
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) throw const GeminiUnavailable('Réponse Gemini vide');
    return text;
  }

  String _extractJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) return trimmed;
    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');
    if (start >= 0 && end > start) return trimmed.substring(start, end + 1);
    return trimmed;
  }
}
