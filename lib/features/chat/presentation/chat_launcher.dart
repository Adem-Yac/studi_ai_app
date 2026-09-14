import 'package:flutter/foundation.dart';

/// Permet à d'autres écrans (accueil, documents) d'ouvrir le chat avec un
/// prompt pré-rempli à envoyer automatiquement.
abstract final class ChatLauncher {
  static final ValueNotifier<String?> pending = ValueNotifier<String?>(null);

  static void queue(String prompt) => pending.value = prompt;

  static String? consume() {
    final value = pending.value;
    pending.value = null;
    return value;
  }
}
