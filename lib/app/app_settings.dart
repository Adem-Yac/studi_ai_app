import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/storage_keys.dart';

/// Niveau de détail des réponses de l'IA.
enum AnswerLevel { simple, university, expert }

/// Préférences locales (langue, thème, notifications, onboarding, niveau IA).
abstract final class AppSettings {
  static final lang = ValueNotifier<String>('fr');
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final notificationsEnabled = ValueNotifier<bool>(true);
  static final onboardingDone = ValueNotifier<bool>(false);
  static final answerLevel = ValueNotifier<AnswerLevel>(AnswerLevel.university);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getString(StorageKeys.settingsLang);
    if (stored == 'en' || stored == 'ar' || stored == 'fr') {
      lang.value = stored!;
    } else {
      final device = PlatformDispatcher.instance.locale.languageCode;
      lang.value = switch (device) {
        'fr' => 'fr',
        'ar' => 'ar',
        _ => 'en',
      };
      await prefs.setString(StorageKeys.settingsLang, lang.value);
    }

    final theme = prefs.getString(StorageKeys.settingsTheme);
    themeMode.value = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    notificationsEnabled.value =
        prefs.getBool(StorageKeys.settingsNotifs) ?? true;
    onboardingDone.value =
        prefs.getBool(StorageKeys.settingsOnboardingDone) ?? false;

    final level = prefs.getString(StorageKeys.settingsAnswerLevel);
    answerLevel.value = AnswerLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => AnswerLevel.university,
    );
  }

  static Future<void> setLang(String code) async {
    final next = switch (code) {
      'en' || 'ar' || 'fr' => code,
      _ => 'fr',
    };
    lang.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.settingsLang, next);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.settingsTheme,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.settingsNotifs, enabled);
  }

  static Future<void> setOnboardingDone(bool done) async {
    onboardingDone.value = done;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.settingsOnboardingDone, done);
  }

  static Future<void> setAnswerLevel(AnswerLevel level) async {
    answerLevel.value = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.settingsAnswerLevel, level.name);
  }
}
