import 'gemini_secrets.dart';

/// Résout la clé Gemini : `--dart-define` d'abord, sinon le fichier local.
abstract final class GeminiConfig {
  static const String _fromDefine = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static String get apiKey {
    if (_fromDefine.isNotEmpty) return _fromDefine;
    return kGeminiApiKey;
  }

  static bool get hasDirectKey => apiKey.isNotEmpty;
}
