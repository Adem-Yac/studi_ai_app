import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/study_document.dart';

/// Résultat d'une sélection de fichier PDF.
class PickedPdf {
  const PickedPdf({
    required this.bytes,
    required this.fileName,
    required this.sizeMb,
  });
  final Uint8List bytes;
  final String fileName;
  final double sizeMb;
}

/// Gère les documents : sélection, upload Storage, metadata Firestore, analyse.
class DocumentsRepository {
  DocumentsRepository(
    this._gemini, {
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final GeminiService _gemini;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  /// Bytes gardés en mémoire pour l'analyse / génération de quiz.
  final Map<String, Uint8List> _bytesCache = {};

  Uint8List? bytesFor(String id) => _bytesCache[id];

  Future<StudyDocument?> getById(String id) async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    try {
      final snap = await _col(uid).doc(id).get();
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return StudyDocument.fromMap(snap.id, data);
    } catch (e) {
      debugPrint('DocumentsRepository.getById: $e');
      return null;
    }
  }

  Future<StudyDocument?> findByTitle(String title) async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    final needle = title.trim().toLowerCase();
    if (needle.isEmpty) return null;
    try {
      final snap = await _col(uid).limit(40).get();
      for (final d in snap.docs) {
        final doc = StudyDocument.fromMap(d.id, d.data());
        if (doc.title.toLowerCase() == needle ||
            doc.fileName.toLowerCase().startsWith(needle)) {
          return doc;
        }
      }
    } catch (e) {
      debugPrint('DocumentsRepository.findByTitle: $e');
    }
    return null;
  }

  /// Bytes du PDF : cache mémoire, sinon Storage.
  Future<Uint8List?> loadBytes(StudyDocument doc) async {
    final cached = _bytesCache[doc.id];
    if (cached != null && cached.isNotEmpty) return cached;
    final path = doc.storagePath;
    if (path == null || path.isEmpty) return null;
    try {
      final data = await _storage.ref(path).getData(50 * 1024 * 1024);
      if (data != null && data.isNotEmpty) {
        _bytesCache[doc.id] = data;
      }
      return data;
    } catch (e) {
      debugPrint('DocumentsRepository.loadBytes: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.documents);

  Future<List<StudyDocument>> list() async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return const [];
    try {
      final snap =
          await _col(uid).orderBy('createdAt', descending: true).get();
      return snap.docs
          .map((d) => StudyDocument.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('DocumentsRepository.list: $e');
      return const [];
    }
  }

  /// Ouvre le sélecteur de fichiers et renvoie le PDF choisi (ou null).
  Future<PickedPdf?> pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Impossible de lire le fichier sélectionné.');
    }
    final sizeMb = bytes.lengthInBytes / (1024 * 1024);
    if (sizeMb > 50) {
      throw Exception('Fichier trop volumineux (${sizeMb.toStringAsFixed(1)} '
          'Mo). Limite : 50 Mo.');
    }
    return PickedPdf(
      bytes: bytes,
      fileName: file.name,
      sizeMb: sizeMb,
    );
  }

  /// Importe un PDF : upload (si possible) + création metadata.
  Future<StudyDocument> importPdf(PickedPdf pdf, {String subject = 'Général'}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _bytesCache[id] = pdf.bytes;

    final title = pdf.fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    String? storagePath;

    final uid = _auth.currentUser?.uid;
    if (firebaseReady && uid != null) {
      try {
        final ref = _storage.ref('users/$uid/documents/$id.pdf');
        await ref.putData(
          pdf.bytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        storagePath = ref.fullPath;
      } catch (e) {
        debugPrint('DocumentsRepository.importPdf upload: $e');
      }
    }

    var doc = StudyDocument(
      id: id,
      title: title,
      fileName: pdf.fileName,
      subject: subject,
      pages: 0,
      sizeMb: double.parse(pdf.sizeMb.toStringAsFixed(1)),
      storagePath: storagePath,
    );

    if (firebaseReady && uid != null) {
      try {
        await _col(uid).doc(id).set({
          ...doc.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        await _firestore
            .collection(FirestorePaths.users)
            .doc(uid)
            .collection(FirestorePaths.courses)
            .doc(id)
            .set({
          'title': title,
          'subject': subject,
          'chapter': pdf.fileName,
          'progress': 0.0,
          'colorIndex': DateTime.now().millisecond % 5,
          'updatedLabel': S.justNow,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('DocumentsRepository.importPdf meta: $e');
      }
    }
    return doc;
  }

  /// Génère une synthèse IA du document.
  Future<String> analyze(StudyDocument doc) async {
    final bytes = _bytesCache[doc.id];
    try {
      final summary = bytes != null
          ? await _gemini.analyzePdf(
              bytes,
              instruction: _gemini.summaryInstruction,
            )
          : await _gemini.summarize(doc.title);
      await _persistSummary(doc.id, summary);
      return summary;
    } on GeminiUnavailable catch (e) {
      throw Exception('Analyse IA impossible : ${e.message}');
    }
  }

  Future<void> _persistSummary(String id, String summary) async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return;
    try {
      await _col(uid).doc(id).set({'summary': summary}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('DocumentsRepository._persistSummary: $e');
    }
  }

  Future<void> delete(StudyDocument doc) async {
    _bytesCache.remove(doc.id);
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return;
    try {
      await _col(uid).doc(doc.id).delete();
      if (doc.storagePath != null) {
        await _storage.ref(doc.storagePath!).delete();
      }
    } catch (e) {
      debugPrint('DocumentsRepository.delete: $e');
    }
  }
}
