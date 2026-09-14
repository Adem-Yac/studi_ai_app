import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/documents/data/models/study_document.dart';
import '../../features/documents/data/repositories/documents_repository.dart';
import '../di/injection.dart';

/// Écrit le PDF en cache puis l'ouvre / le partage.
class PdfOpener {
  static Future<File> _fileFor(StudyDocument doc) async {
    final bytes = await getIt<DocumentsRepository>().loadBytes(doc);
    if (bytes == null || bytes.isEmpty) {
      throw Exception('pdf_unavailable');
    }
    final dir = await getTemporaryDirectory();
    final name = doc.fileName.trim().isNotEmpty
        ? doc.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        : '${doc.id}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> open(StudyDocument doc) async {
    final file = await _fileFor(doc);
    final result = await OpenFilex.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  static Future<void> share(StudyDocument doc) async {
    final file = await _fileFor(doc);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: doc.title),
    );
  }
}
