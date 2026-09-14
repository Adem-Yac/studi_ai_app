/// Clés SharedPreferences centralisées.
abstract final class StorageKeys {
  // AppSettings
  static const settingsLang = 'settings_lang_v1';
  static const settingsTheme = 'settings_theme_v1';
  static const settingsNotifs = 'settings_notifs_v1';
  static const settingsAnswerLevel = 'settings_answer_level_v1';
  static const settingsOnboardingDone = 'settings_onboarding_done_v1';

  // Cache local
  static const coursesCache = 'courses_cache_v1';
  static const progressCache = 'progress_cache_v1';

  static String conversationsCache(String uid) => 'conversations_cache_$uid';
  static String profilePhotoPath(String uid) => 'profile_photo_path_$uid';
}
