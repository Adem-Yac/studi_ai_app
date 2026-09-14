import '../app_settings.dart';

/// Chaînes localisées StudyAI (FR par défaut, EN, AR).
/// Accès statique : `S.appName`, ou `S.get('key')`.
abstract final class S {
  static String get _lang => AppSettings.lang.value;

  static String get(String key) {
    final entry = _dict[key];
    if (entry == null) return key;
    return entry[_lang] ?? entry['fr'] ?? key;
  }

  // Raccourcis les plus utilisés.
  static String get appName => 'StudyAI';
  static String get tagline => get('tagline');
  static String get continueLabel => get('continue');
  static String get skip => get('skip');
  static String get retry => get('retry');
  static String get cancel => get('cancel');
  static String get save => get('save');
  static String get delete => get('delete');
  static String get close => get('close');
  static String get send => get('send');
  static String get search => get('search');
  static String get seeAll => get('see_all');
  static String get loading => get('loading');
  static String get comingSoon => get('coming_soon');

  // Auth
  static String get login => get('login');
  static String get register => get('register');
  static String get email => get('email');
  static String get password => get('password');
  static String get confirmPassword => get('confirm_password');
  static String get fullName => get('full_name');
  static String get forgotPassword => get('forgot_password');
  static String get continueWithGoogle => get('continue_google');
  static String get welcomeBack => get('welcome_back');
  static String get createAccount => get('create_account');
  static String get noAccount => get('no_account');
  static String get haveAccount => get('have_account');
  static String get signOut => get('sign_out');

  // Nav
  static String get navHome => get('nav_home');
  static String get navChat => get('nav_chat');
  static String get navDocs => get('nav_docs');
  static String get navQuiz => get('nav_quiz');
  static String get navProfile => get('nav_profile');

  // Home
  static String greeting(String name) =>
      get('greeting').replaceAll('{name}', name);
  static String get homeQuestion => get('home_question');
  static String get askStudyAI => get('ask_studyai');
  static String get askPrompt => get('ask_prompt');
  static String get startConversation => get('start_conversation');
  static String get myCourses => get('my_courses');
  static String get weekProgress => get('week_progress');
  static String get recommendedQuiz => get('recommended_quiz');

  // Chat / AI actions
  static String get summarize => get('summarize');
  static String get explain => get('explain');
  static String get generateQuiz => get('generate_quiz');
  static String get flashcards => get('flashcards');
  static String get translate => get('translate');
  static String get copy => get('copy');
  static String get copied => get('copied');
  static String get regenerate => get('regenerate');
  static String get whatToDo => get('what_to_do');
  static String get typeMessage => get('type_message');
  static String get aiThinking => get('ai_thinking');

  // Documents
  static String get myDocuments => get('my_documents');
  static String get importPdf => get('import_pdf');
  static String get askAboutDoc => get('ask_about_doc');
  static String get aiSummary => get('ai_summary');
  static String get pages => get('pages');
  static String get noDocuments => get('no_documents');
  static String get open => get('open');

  // Quiz
  static String get quiz => get('quiz');
  static String get question => get('question');
  static String get next => get('next');
  static String get finish => get('finish');
  static String get yourScore => get('your_score');
  static String get correctAnswers => get('correct_answers');
  static String get wrongAnswers => get('wrong_answers');
  static String get seeMistakes => get('see_mistakes');
  static String get retryQuiz => get('retry_quiz');
  static String get startQuiz => get('start_quiz');
  static String get questionsCount => get('questions_count');

  // Progress
  static String get myProgress => get('my_progress');
  static String get studyTime => get('study_time');
  static String get quizDone => get('quiz_done');
  static String get avgScore => get('avg_score');
  static String get activeStreak => get('active_streak');
  static String get masteryBySubject => get('mastery_by_subject');

  // Profile / settings
  static String get profile => get('profile');
  static String get settings => get('settings');
  static String get darkMode => get('dark_mode');
  static String get language => get('language');
  static String get notifications => get('notifications');
  static String get account => get('account');
  static String get answerLevel => get('answer_level');
  static String get aiModel => get('ai_model');

  static String get editProfile => get('edit_profile');
  static String get student => get('student');
  static String get orContinueWith => get('or_continue_with');
  static String get studyField => get('study_field');
  static String get accountSaved => get('account_saved');
  static String get aiPreferences => get('ai_preferences');
  static String get appDisplay => get('app_display');
  static String get accountData => get('account_data');
  static String get securityPassword => get('security_password');
  static String get enabled => get('enabled');
  static String get disabled => get('disabled');
  static String get notifsSubtitle => get('notifs_subtitle');
  static String get appearance => get('appearance');
  static String get languageAndAi => get('language_and_ai');
  static String get privacy => get('privacy');
  static String get noCoursesYet => get('no_courses_yet');
  static String get noQuizzesYet => get('no_quizzes_yet');
  static String get searchHint => get('search_hint');
  static String get importNewPdf => get('import_new_pdf');
  static String get importPdfHint => get('import_pdf_hint');
  static String get allFiles => get('all_files');
  static String get synthesized => get('synthesized');
  static String get generateCustomQuiz => get('generate_custom_quiz');
  static String get quizTopicHint => get('quiz_topic_hint');
  static String get generateWithGemini => get('generate_with_gemini');
  static String get yourQuizzes => get('your_quizzes');
  static String get emptyQuizHint => get('empty_quiz_hint');
  static String get enterQuizTopic => get('enter_quiz_topic');
  static String get documentDetail => get('document_detail');
  static String get backHome => get('back_home');
  static String get wellDone => get('well_done');
  static String get keepGoing => get('keep_going');
  static String get weeklyGoal => get('weekly_goal');
  static String get askFirstQuestion => get('ask_first_question');
  static String get emptyChatHint => get('empty_chat_hint');
  static String get online => get('online');
  static String get forgotPasswordHint => get('forgot_password_hint');
  static String get onboardingBadge1 => get('onboarding_badge_1');
  static String get onboardingTitle1 => get('onboarding_title_1');
  static String get onboardingBody1 => get('onboarding_body_1');
  static String get onboardingBadge2 => get('onboarding_badge_2');
  static String get onboardingTitle2 => get('onboarding_title_2');
  static String get onboardingBody2 => get('onboarding_body_2');
  static String get onboardingBadge3 => get('onboarding_badge_3');
  static String get onboardingTitle3 => get('onboarding_title_3');
  static String get onboardingBody3 => get('onboarding_body_3');
  static String get quizSubtitle => get('quiz_subtitle');
  static String get docsSubtitle => get('docs_subtitle');
  static String get alreadyStudent => get('already_student');
  static String get joinFree => get('join_free');
  static String get signupEmailShown => get('signup_email_shown');
  static String get levelSimple => get('level_simple');
  static String get levelUniversity => get('level_university');
  static String get levelExpert => get('level_expert');
  static String weekday(int index) => get('weekday_$index');
  static String get geminiReady => get('gemini_ready');
  static String get generateSummary => get('generate_summary');
  static String get noSummaryYet => get('no_summary_yet');
  static String get analyzeWithGemini => get('analyze_with_gemini');
  static String get testChapterQuiz => get('test_chapter_quiz');
  static String get yourQuestion => get('your_question');
  static String get analyzing => get('analyzing');
  static String filesCount(int n) =>
      get('files_count').replaceAll('{count}', '$n');
  static String get skipQuestion => get('skip_question');
  static String get hide => get('hide');
  static String yourAnswer(String a) =>
      get('your_answer').replaceAll('{answer}', a);
  static String correctAnswer(String a) =>
      get('correct_answer').replaceAll('{answer}', a);
  static String generationFailed(String e) =>
      get('generation_failed').replaceAll('{error}', e);
  static String get active => get('active');
  static String get ofStudy => get('of_study');
  static String get validated => get('validated');
  static String get streakLabel => get('streak_label');
  static String get seeDetails => get('see_details');
  static String get discover => get('discover');
  static String difficulty(String level) =>
      get('difficulty').replaceAll('{level}', level);
  static String get difficultyMedium => get('difficulty_medium');
  static String get progressPowered => get('progress_powered');
  static String get weeklyActivity => get('weekly_activity');
  static String get badgesRewards => get('badges_rewards');
  static String get weeklyGoalHint => get('weekly_goal_hint');
  static String get studentName => get('student_name');
  static String get generalSubject => get('general_subject');
  static String get justNow => get('just_now');
  static String get mbUnit => get('mb_unit');
  static String get promptSummarize => get('prompt_summarize');
  static String get promptExplain => get('prompt_explain');
  static String get promptQuiz => get('prompt_quiz');
  static String get promptFlashcards => get('prompt_flashcards');
  static String get promptTranslate => get('prompt_translate');
  static String get chatSummarizePrompt => get('chat_summarize_prompt');
  static String get chatExplainPrompt => get('chat_explain_prompt');
  static String get chatQuizPrompt => get('chat_quiz_prompt');
  static String askAboutNamed(String title) =>
      get('ask_about_named').replaceAll('{title}', title);
  static String aboutDocument(String title) =>
      get('about_document').replaceAll('{title}', title);
  static String get progressStartTitle => get('progress_start_title');
  static String get progressStartSub => get('progress_start_sub');
  static String get progressHighTitle => get('progress_high_title');
  static String get progressHighSub => get('progress_high_sub');
  static String get progressMidTitle => get('progress_mid_title');
  static String get progressMidSub => get('progress_mid_sub');
  static String get progressLowTitle => get('progress_low_title');
  static String get progressLowSub => get('progress_low_sub');
  static String get badgeQuizGenius => get('badge_quiz_genius');
  static String get badgeGold => get('badge_gold');
  static String get badgeRegular => get('badge_regular');
  static String get badgeSilver => get('badge_silver');
  static String get badgeExplorer => get('badge_explorer');
  static String get badgeBronze => get('badge_bronze');
  static String get appVersion => get('app_version');
  static String get askStudyAiBadge => get('ask_studyai_badge');
  static String get subjects => get('subjects');
  static String get addSubject => get('add_subject');
  static String get editSubject => get('edit_subject');
  static String get subjectName => get('subject_name');
  static String get emptySubjectsHint => get('empty_subjects_hint');
  static String get deleteSubject => get('delete_subject');
  static String deleteSubjectConfirm(String name) =>
      get('delete_subject_confirm').replaceAll('{name}', name);
  static String get searchEmptyHint => get('search_empty_hint');
  static String get noSearchResults => get('no_search_results');
  static String get courseUnavailable => get('course_unavailable');
  static String get openPdf => get('open_pdf');
  static String get share => get('share');
  static String get pdfUnavailable => get('pdf_unavailable');
  static String get flashcardsSubtitle => get('flashcards_subtitle');
  static String get generateFlashcards => get('generate_flashcards');
  static String get flashcardTopicHint => get('flashcard_topic_hint');
  static String get enterFlashcardTopic => get('enter_flashcard_topic');
  static String get yourFlashcards => get('your_flashcards');
  static String get emptyFlashcardsHint => get('empty_flashcards_hint');
  static String cardsCount(int n) =>
      get('cards_count').replaceAll('{count}', '$n');
  static String get tapToFlip => get('tap_to_flip');
  static String get answer => get('answer');
  static String get previous => get('previous');
  static String get openFlashcards => get('open_flashcards');
  static String get changePassword => get('change_password');
  static String get currentPassword => get('current_password');
  static String get newPassword => get('new_password');
  static String get passwordUpdated => get('password_updated');
  static String get emailVerification => get('email_verification');
  static String get emailVerified => get('email_verified');
  static String get emailNotVerified => get('email_not_verified');
  static String get verificationSent => get('verification_sent');
  static String get resetPasswordEmail => get('reset_password_email');
  static String get privacyBody => get('privacy_body');
  static String get copyAccountInfo => get('copy_account_info');
  static String get deleteAccount => get('delete_account');
  static String get deleteAccountConfirm => get('delete_account_confirm');

  static const Map<String, Map<String, String>> _dict = {
    'tagline': {
      'fr': "Ton assistant d'étude propulsé par Gemini & Firebase",
      'en': 'Your study assistant powered by Gemini & Firebase',
      'ar': 'مساعد الدراسة الخاص بك بدعم من Gemini و Firebase',
    },
    'continue': {'fr': 'Continuer', 'en': 'Continue', 'ar': 'متابعة'},
    'skip': {'fr': 'Passer', 'en': 'Skip', 'ar': 'تخطّي'},
    'retry': {'fr': 'Réessayer', 'en': 'Retry', 'ar': 'إعادة'},
    'cancel': {'fr': 'Annuler', 'en': 'Cancel', 'ar': 'إلغاء'},
    'save': {'fr': 'Enregistrer', 'en': 'Save', 'ar': 'حفظ'},
    'delete': {'fr': 'Supprimer', 'en': 'Delete', 'ar': 'حذف'},
    'close': {'fr': 'Fermer', 'en': 'Close', 'ar': 'إغلاق'},
    'send': {'fr': 'Envoyer', 'en': 'Send', 'ar': 'إرسال'},
    'search': {'fr': 'Rechercher', 'en': 'Search', 'ar': 'بحث'},
    'see_all': {'fr': 'Voir tout', 'en': 'See all', 'ar': 'عرض الكل'},
    'loading': {'fr': 'Chargement…', 'en': 'Loading…', 'ar': 'جارٍ التحميل…'},
    'coming_soon': {'fr': 'Bientôt disponible', 'en': 'Coming soon', 'ar': 'قريبًا'},

    'login': {'fr': 'Se connecter', 'en': 'Sign in', 'ar': 'تسجيل الدخول'},
    'register': {'fr': "S'inscrire", 'en': 'Sign up', 'ar': 'إنشاء حساب'},
    'email': {'fr': 'Adresse e-mail', 'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'fr': 'Mot de passe', 'en': 'Password', 'ar': 'كلمة المرور'},
    'confirm_password': {
      'fr': 'Confirmer le mot de passe',
      'en': 'Confirm password',
      'ar': 'تأكيد كلمة المرور'
    },
    'full_name': {'fr': 'Nom complet', 'en': 'Full name', 'ar': 'الاسم الكامل'},
    'forgot_password': {
      'fr': 'Mot de passe oublié ?',
      'en': 'Forgot password?',
      'ar': 'نسيت كلمة المرور؟'
    },
    'continue_google': {
      'fr': 'Continuer avec Google',
      'en': 'Continue with Google',
      'ar': 'المتابعة عبر Google'
    },
    'welcome_back': {
      'fr': 'Ravi de te revoir !',
      'en': 'Welcome back!',
      'ar': 'مرحبًا بعودتك!'
    },
    'create_account': {
      'fr': 'Créer un compte',
      'en': 'Create an account',
      'ar': 'إنشاء حساب'
    },
    'no_account': {
      'fr': 'Pas encore de compte ?',
      'en': "Don't have an account?",
      'ar': 'ليس لديك حساب؟'
    },
    'have_account': {
      'fr': 'Déjà un compte ?',
      'en': 'Already have an account?',
      'ar': 'لديك حساب بالفعل؟'
    },
    'sign_out': {'fr': 'Déconnexion', 'en': 'Sign out', 'ar': 'تسجيل الخروج'},

    'nav_home': {'fr': 'Accueil', 'en': 'Home', 'ar': 'الرئيسية'},
    'nav_chat': {'fr': 'Chat IA', 'en': 'AI Chat', 'ar': 'المحادثة'},
    'nav_docs': {'fr': 'Documents', 'en': 'Documents', 'ar': 'المستندات'},
    'nav_quiz': {'fr': 'Quiz', 'en': 'Quiz', 'ar': 'اختبار'},
    'nav_profile': {'fr': 'Profil', 'en': 'Profile', 'ar': 'الملف'},

    'greeting': {'fr': 'Bonjour {name}', 'en': 'Hello {name}', 'ar': 'مرحبًا {name}'},
    'home_question': {
      'fr': "Que veux-tu apprendre aujourd'hui ?",
      'en': 'What do you want to learn today?',
      'ar': 'ماذا تريد أن تتعلم اليوم؟'
    },
    'ask_studyai': {'fr': 'Ask StudyAI', 'en': 'Ask StudyAI', 'ar': 'اسأل StudyAI'},
    'ask_prompt': {
      'fr': 'Pose ta question ou glisse ton cours en PDF',
      'en': 'Ask a question or drop your course as PDF',
      'ar': 'اطرح سؤالك أو أرفق درسك بصيغة PDF'
    },
    'start_conversation': {
      'fr': 'Commencer une conversation',
      'en': 'Start a conversation',
      'ar': 'ابدأ محادثة'
    },
    'my_courses': {'fr': 'Mes cours', 'en': 'My courses', 'ar': 'دروسي'},
    'week_progress': {
      'fr': 'Progression de la semaine',
      'en': 'This week progress',
      'ar': 'تقدم الأسبوع'
    },
    'recommended_quiz': {
      'fr': 'Quiz recommandés',
      'en': 'Recommended quizzes',
      'ar': 'اختبارات مقترحة'
    },

    'summarize': {'fr': 'Résumer', 'en': 'Summarize', 'ar': 'تلخيص'},
    'explain': {'fr': 'Expliquer', 'en': 'Explain', 'ar': 'شرح'},
    'generate_quiz': {'fr': 'Générer un quiz', 'en': 'Generate a quiz', 'ar': 'إنشاء اختبار'},
    'flashcards': {'fr': 'Flashcards', 'en': 'Flashcards', 'ar': 'بطاقات'},
    'translate': {'fr': 'Traduire', 'en': 'Translate', 'ar': 'ترجمة'},
    'copy': {'fr': 'Copier', 'en': 'Copy', 'ar': 'نسخ'},
    'copied': {'fr': 'Copié', 'en': 'Copied', 'ar': 'تم النسخ'},
    'regenerate': {'fr': 'Regénérer', 'en': 'Regenerate', 'ar': 'إعادة توليد'},
    'what_to_do': {
      'fr': 'Que veux-tu faire ?',
      'en': 'What do you want to do?',
      'ar': 'ماذا تريد أن تفعل؟'
    },
    'type_message': {
      'fr': 'Pose ta question à StudyAI…',
      'en': 'Ask StudyAI…',
      'ar': 'اطرح سؤالك على StudyAI…'
    },
    'ai_thinking': {'fr': 'StudyAI réfléchit…', 'en': 'StudyAI is thinking…', 'ar': 'StudyAI يفكر…'},

    'my_documents': {'fr': 'Mes Documents', 'en': 'My Documents', 'ar': 'مستنداتي'},
    'import_pdf': {'fr': 'Importer un PDF', 'en': 'Import a PDF', 'ar': 'استيراد PDF'},
    'ask_about_doc': {
      'fr': 'Poser une question',
      'en': 'Ask about this document',
      'ar': 'اسأل عن هذا المستند'
    },
    'ai_summary': {'fr': 'Synthèse IA', 'en': 'AI Summary', 'ar': 'ملخص الذكاء'},
    'pages': {'fr': 'pages', 'en': 'pages', 'ar': 'صفحات'},
    'no_documents': {
      'fr': 'Aucun document pour le moment',
      'en': 'No documents yet',
      'ar': 'لا توجد مستندات بعد'
    },
    'open': {'fr': 'Ouvrir', 'en': 'Open', 'ar': 'فتح'},

    'quiz': {'fr': 'Quiz', 'en': 'Quiz', 'ar': 'اختبار'},
    'question': {'fr': 'Question', 'en': 'Question', 'ar': 'سؤال'},
    'next': {'fr': 'Suivant', 'en': 'Next', 'ar': 'التالي'},
    'finish': {'fr': 'Terminer', 'en': 'Finish', 'ar': 'إنهاء'},
    'your_score': {'fr': 'Ton score', 'en': 'Your score', 'ar': 'نتيجتك'},
    'correct_answers': {'fr': 'Bonnes réponses', 'en': 'Correct answers', 'ar': 'إجابات صحيحة'},
    'wrong_answers': {'fr': 'Mauvaises réponses', 'en': 'Wrong answers', 'ar': 'إجابات خاطئة'},
    'see_mistakes': {'fr': 'Voir les erreurs', 'en': 'See mistakes', 'ar': 'عرض الأخطاء'},
    'retry_quiz': {'fr': 'Refaire le quiz', 'en': 'Retry quiz', 'ar': 'إعادة الاختبار'},
    'start_quiz': {'fr': 'Lancer', 'en': 'Start', 'ar': 'ابدأ'},
    'questions_count': {'fr': 'Questions', 'en': 'Questions', 'ar': 'أسئلة'},

    'my_progress': {'fr': 'Mon Suivi', 'en': 'My Progress', 'ar': 'تقدمي'},
    'study_time': {'fr': "Temps d'étude", 'en': 'Study time', 'ar': 'وقت الدراسة'},
    'quiz_done': {'fr': 'Quiz réalisés', 'en': 'Quizzes done', 'ar': 'اختبارات مكتملة'},
    'avg_score': {'fr': 'Score moyen', 'en': 'Average score', 'ar': 'متوسط النتيجة'},
    'active_streak': {'fr': 'Série active', 'en': 'Active streak', 'ar': 'سلسلة نشطة'},
    'mastery_by_subject': {
      'fr': 'Maîtrise par matière',
      'en': 'Mastery by subject',
      'ar': 'الإتقان حسب المادة'
    },

    'profile': {'fr': 'Profil', 'en': 'Profile', 'ar': 'الملف الشخصي'},
    'settings': {'fr': 'Paramètres', 'en': 'Settings', 'ar': 'الإعدادات'},
    'dark_mode': {'fr': 'Mode sombre', 'en': 'Dark mode', 'ar': 'الوضع الداكن'},
    'language': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة'},
    'notifications': {'fr': 'Notifications', 'en': 'Notifications', 'ar': 'الإشعارات'},
    'account': {'fr': 'Compte', 'en': 'Account', 'ar': 'الحساب'},
    'answer_level': {
      'fr': 'Niveau des réponses',
      'en': 'Answer level',
      'ar': 'مستوى الإجابات'
    },
    'ai_model': {'fr': 'Modèle IA', 'en': 'AI model', 'ar': 'نموذج الذكاء'},

    // Erreurs auth
    'auth_invalid_email': {
      'fr': 'Adresse e-mail invalide.',
      'en': 'Invalid email address.',
      'ar': 'بريد إلكتروني غير صالح.'
    },
    'auth_weak_password': {
      'fr': 'Le mot de passe doit contenir au moins 6 caractères.',
      'en': 'Password must be at least 6 characters.',
      'ar': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.'
    },
    'auth_wrong_password': {
      'fr': 'Mot de passe incorrect.',
      'en': 'Wrong password.',
      'ar': 'كلمة المرور غير صحيحة.'
    },
    'auth_passwords_mismatch': {
      'fr': 'Les mots de passe ne correspondent pas.',
      'en': 'Passwords do not match.',
      'ar': 'كلمتا المرور غير متطابقتين.'
    },
    'auth_generic_error': {
      'fr': 'Une erreur est survenue. Réessaie.',
      'en': 'Something went wrong. Try again.',
      'ar': 'حدث خطأ. حاول مجددًا.'
    },
    'auth_network_error': {
      'fr': 'Pas de connexion. Vérifie internet et réessaie.',
      'en': 'No connection. Check internet and try again.',
      'ar': 'لا يوجد اتصال. تحقق من الإنترنت وحاول مجددًا.'
    },
    'auth_email_in_use': {
      'fr': 'Cet e-mail est déjà utilisé.',
      'en': 'This email is already in use.',
      'ar': 'هذا البريد مستخدم بالفعل.'
    },
    'auth_too_many': {
      'fr': 'Trop de tentatives. Attends un moment.',
      'en': 'Too many attempts. Please wait.',
      'ar': 'محاولات كثيرة. انتظر قليلًا.'
    },
    'auth_reset_sent': {
      'fr': 'E-mail de réinitialisation envoyé.',
      'en': 'Password reset email sent.',
      'ar': 'تم إرسال بريد إعادة التعيين.'
    },
    'auth_google_config': {
      'fr': 'Connexion Google indisponible. Ferme l’app, relance-la, puis réessaie.',
      'en': 'Google sign-in is unavailable. Close the app, reopen it, then try again.',
      'ar': 'تسجيل الدخول عبر Google غير متاح. أغلق التطبيق ثم أعد المحاولة.'
    },
    'auth_google_failed': {
      'fr': 'Connexion Google impossible. Réessaie ou utilise e-mail / mot de passe.',
      'en': 'Google sign-in failed. Try again or use email and password.',
      'ar': 'تعذر تسجيل الدخول عبر Google. أعد المحاولة أو استخدم البريد.'
    },
    'edit_profile': {'fr': 'Modifier le profil', 'en': 'Edit profile', 'ar': 'تعديل الملف'},
    'student': {'fr': 'étudiant', 'en': 'student', 'ar': 'طالب'},
    'or_continue_with': {'fr': 'OU CONTINUER AVEC', 'en': 'OR CONTINUE WITH', 'ar': 'أو المتابعة عبر'},
    'study_field': {'fr': 'Filière / matière', 'en': 'Field of study', 'ar': 'التخصص'},
    'account_saved': {'fr': 'Profil enregistré', 'en': 'Profile saved', 'ar': 'تم حفظ الملف'},
    'ai_preferences': {'fr': "PRÉFÉRENCES DE L'IA", 'en': 'AI PREFERENCES', 'ar': 'تفضيلات الذكاء'},
    'app_display': {'fr': 'APPLICATION & AFFICHAGE', 'en': 'APP & DISPLAY', 'ar': 'التطبيق والعرض'},
    'account_data': {'fr': 'COMPTE & DONNÉES', 'en': 'ACCOUNT & DATA', 'ar': 'الحساب والبيانات'},
    'security_password': {
      'fr': 'Sécurité & mot de passe',
      'en': 'Security & password',
      'ar': 'الأمان وكلمة المرور'
    },
    'enabled': {'fr': 'Activé', 'en': 'On', 'ar': 'مفعّل'},
    'disabled': {'fr': 'Désactivé', 'en': 'Off', 'ar': 'متوقف'},
    'notifs_subtitle': {
      'fr': 'Rappels et nouveaux résultats',
      'en': 'Reminders and new results',
      'ar': 'تذكيرات ونتائج جديدة'
    },
    'appearance': {'fr': 'APPARENCE', 'en': 'APPEARANCE', 'ar': 'المظهر'},
    'language_and_ai': {'fr': 'LANGUE & IA', 'en': 'LANGUAGE & AI', 'ar': 'اللغة والذكاء'},
    'privacy': {'fr': 'Confidentialité', 'en': 'Privacy', 'ar': 'الخصوصية'},
    'no_courses_yet': {
      'fr': 'Importe un PDF ou génère un quiz : tes cours apparaîtront ici.',
      'en': 'Import a PDF or generate a quiz — your courses will show up here.',
      'ar': 'استورد ملف PDF أو أنشئ اختبارًا لتظهر دروسك هنا.'
    },
    'no_quizzes_yet': {
      'fr': 'Aucun quiz encore. Ouvre l’onglet Quiz pour en générer un.',
      'en': 'No quizzes yet. Open the Quiz tab to generate one.',
      'ar': 'لا اختبارات بعد. افتح تبويب الاختبار لإنشاء واحد.'
    },
    'search_hint': {
      'fr': 'Rechercher un cours, un concept…',
      'en': 'Search a course, a concept…',
      'ar': 'ابحث عن درس أو مفهوم…'
    },
    'import_new_pdf': {
      'fr': '+ Importer un nouveau PDF',
      'en': '+ Import a new PDF',
      'ar': '+ استيراد PDF جديد'
    },
    'import_pdf_hint': {
      'fr': 'Choisis un fichier PDF (max 50 Mo)',
      'en': 'Pick a PDF file (max 50 MB)',
      'ar': 'اختر ملف PDF (حد أقصى 50 ميغابايت)'
    },
    'all_files': {'fr': 'Tous les fichiers', 'en': 'All files', 'ar': 'كل الملفات'},
    'synthesized': {'fr': 'Synthétisé', 'en': 'Summarized', 'ar': 'ملخّص'},
    'generate_custom_quiz': {
      'fr': 'Générer un quiz personnalisé',
      'en': 'Generate a custom quiz',
      'ar': 'إنشاء اختبار مخصص'
    },
    'quiz_topic_hint': {
      'fr': 'Ex. : les pointeurs en C, la Révolution…',
      'en': 'e.g. pointers in C, the French Revolution…',
      'ar': 'مثال: المؤشرات في C، الثورة…'
    },
    'generate_with_gemini': {
      'fr': 'Générer avec Gemini',
      'en': 'Generate with Gemini',
      'ar': 'إنشاء عبر Gemini'
    },
    'your_quizzes': {'fr': 'Tes quiz', 'en': 'Your quizzes', 'ar': 'اختباراتك'},
    'empty_quiz_hint': {
      'fr': 'Aucun quiz pour l’instant. Génère-en un ci-dessus.',
      'en': 'No quizzes yet. Generate one above.',
      'ar': 'لا اختبارات بعد. أنشئ واحدًا أعلاه.'
    },
    'enter_quiz_topic': {
      'fr': 'Entre un sujet pour générer un quiz.',
      'en': 'Enter a topic to generate a quiz.',
      'ar': 'أدخل موضوعًا لإنشاء اختبار.'
    },
    'document_detail': {'fr': 'Détail du document', 'en': 'Document detail', 'ar': 'تفاصيل المستند'},
    'back_home': {'fr': "Retour à l'accueil", 'en': 'Back to home', 'ar': 'العودة للرئيسية'},
    'well_done': {'fr': 'Bien joué', 'en': 'Well done', 'ar': 'أحسنت'},
    'keep_going': {'fr': 'Continue', 'en': 'Keep going', 'ar': 'تابع'},
    'weekly_goal': {
      'fr': "Objectif d'étude hebdomadaire",
      'en': 'Weekly study goal',
      'ar': 'هدف الدراسة الأسبوعي'
    },
    'ask_first_question': {
      'fr': 'Pose ta première question',
      'en': 'Ask your first question',
      'ar': 'اطرح سؤالك الأول'
    },
    'empty_chat_hint': {
      'fr': "Demande une explication sur n'importe quel sujet, un résumé, un QCM… (un PDF est optionnel).",
      'en': 'Ask for an explanation on any topic, a summary, a quiz… (a PDF is optional).',
      'ar': 'اطلب شرحًا لأي موضوع، أو ملخصًا، أو اختبارًا… (ملف PDF اختياري).'
    },
    'online': {'fr': 'En ligne', 'en': 'Online', 'ar': 'متصل'},
    'forgot_password_hint': {
      'fr': "Entre ton adresse e-mail, nous t'enverrons un lien de réinitialisation.",
      'en': "Enter your email and we'll send a reset link.",
      'ar': 'أدخل بريدك وسنرسل رابط إعادة التعيين.'
    },
    'onboarding_badge_1': {'fr': 'Synthèse Magique', 'en': 'Smart notes', 'ar': 'ملخص ذكي'},
    'onboarding_title_1': {
      'fr': 'Apprends plus intelligemment',
      'en': 'Learn smarter',
      'ar': 'تعلّم بذكاء'
    },
    'onboarding_body_1': {
      'fr': 'Résumés instantanés de tes cours et fiches de révision automatiques enrichies par IA.',
      'en': 'Instant course summaries and AI-powered revision sheets.',
      'ar': 'ملخصات فورية لدروسك وبطاقات مراجعة يولّدها الذكاء الاصطناعي.'
    },
    'onboarding_badge_2': {'fr': 'Assistant IA', 'en': 'AI assistant', 'ar': 'مساعد ذكي'},
    'onboarding_title_2': {
      'fr': 'Ton assistant IA personnel',
      'en': 'Your personal AI tutor',
      'ar': 'مدرّسك الشخصي بالذكاء الاصطناعي'
    },
    'onboarding_body_2': {
      'fr': 'Pose tes questions, importe un PDF, obtiens des explications claires propulsées par Gemini.',
      'en': 'Ask questions, import a PDF, get clear Gemini-powered explanations.',
      'ar': 'اطرح أسئلتك، استورد PDF، واحصل على شروح واضحة من Gemini.'
    },
    'onboarding_badge_3': {'fr': 'Révision Active', 'en': 'Active recall', 'ar': 'مراجعة نشطة'},
    'onboarding_title_3': {
      'fr': 'Teste tes connaissances',
      'en': 'Test your knowledge',
      'ar': 'اختبر معرفتك'
    },
    'onboarding_body_3': {
      'fr': 'Génère des QCM adaptés et suis ta progression.',
      'en': 'Generate tailored quizzes and track your progress.',
      'ar': 'أنشئ اختبارات مناسبة وتابع تقدمك.'
    },
    'quiz_subtitle': {
      'fr': 'Teste tes connaissances avec des QCM générés par IA',
      'en': 'Test yourself with AI-generated quizzes',
      'ar': 'اختبر نفسك باختبارات يولّدها الذكاء الاصطناعي'
    },
    'docs_subtitle': {
      'fr': 'Analyse intelligente de tes supports PDF avec Gemini',
      'en': 'Smart analysis of your PDF notes with Gemini',
      'ar': 'تحليل ذكي لمذكرات PDF عبر Gemini'
    },
    'already_student': {
      'fr': 'Déjà étudiant sur StudyAI ?',
      'en': 'Already on StudyAI?',
      'ar': 'لديك حساب StudyAI؟'
    },
    'join_free': {
      'fr': 'Créer un profil étudiant gratuit.',
      'en': 'Create a free student profile.',
      'ar': 'أنشئ ملف طالب مجاني.'
    },
    'signup_email_shown': {
      'fr': 'Compte créé. Un e-mail de vérification a été envoyé à {email}',
      'en': 'Account created. A verification email was sent to {email}',
      'ar': 'تم إنشاء الحساب. أُرسل بريد التحقق إلى {email}'
    },
    'level_simple': {'fr': 'Simple', 'en': 'Simple', 'ar': 'بسيط'},
    'level_university': {
      'fr': 'Universitaire / Avancé',
      'en': 'University / Advanced',
      'ar': 'جامعي / متقدم'
    },
    'level_expert': {'fr': 'Expert', 'en': 'Expert', 'ar': 'خبير'},
    'weekday_0': {'fr': 'Lun', 'en': 'Mon', 'ar': 'الإثنين'},
    'weekday_1': {'fr': 'Mar', 'en': 'Tue', 'ar': 'الثلاثاء'},
    'weekday_2': {'fr': 'Mer', 'en': 'Wed', 'ar': 'الأربعاء'},
    'weekday_3': {'fr': 'Jeu', 'en': 'Thu', 'ar': 'الخميس'},
    'weekday_4': {'fr': 'Ven', 'en': 'Fri', 'ar': 'الجمعة'},
    'weekday_5': {'fr': 'Sam', 'en': 'Sat', 'ar': 'السبت'},
    'weekday_6': {'fr': 'Dim', 'en': 'Sun', 'ar': 'الأحد'},
    'gemini_ready': {
      'fr': 'Analyse Gemini prête',
      'en': 'Gemini analysis ready',
      'ar': 'تحليل Gemini جاهز'
    },
    'generate_summary': {
      'fr': 'Générer résumé',
      'en': 'Generate summary',
      'ar': 'إنشاء ملخص'
    },
    'no_summary_yet': {
      'fr': "Aucune synthèse générée pour le moment. Lance l'analyse Gemini pour obtenir les points clés.",
      'en': 'No summary yet. Run Gemini analysis to get the key points.',
      'ar': 'لا ملخص بعد. شغّل تحليل Gemini للحصول على النقاط الأساسية.'
    },
    'analyze_with_gemini': {
      'fr': 'Analyser avec Gemini',
      'en': 'Analyze with Gemini',
      'ar': 'تحليل عبر Gemini'
    },
    'test_chapter_quiz': {
      'fr': 'Tester ce chapitre en Quiz',
      'en': 'Quiz this chapter',
      'ar': 'اختبر هذا الفصل'
    },
    'your_question': {'fr': 'Ta question…', 'en': 'Your question…', 'ar': 'سؤالك…'},
    'analyzing': {'fr': 'Analyse…', 'en': 'Analyzing…', 'ar': 'جارٍ التحليل…'},
    'files_count': {
      'fr': '{count} fichiers',
      'en': '{count} files',
      'ar': '{count} ملفات'
    },
    'skip_question': {'fr': 'Passer', 'en': 'Skip', 'ar': 'تخطي'},
    'hide': {'fr': 'Masquer', 'en': 'Hide', 'ar': 'إخفاء'},
    'your_answer': {
      'fr': 'Ta réponse : {answer}',
      'en': 'Your answer: {answer}',
      'ar': 'إجابتك: {answer}'
    },
    'correct_answer': {
      'fr': 'Bonne réponse : {answer}',
      'en': 'Correct answer: {answer}',
      'ar': 'الإجابة الصحيحة: {answer}'
    },
    'generation_failed': {
      'fr': 'Génération impossible : {error}',
      'en': 'Could not generate: {error}',
      'ar': 'تعذر الإنشاء: {error}'
    },
    'active': {'fr': 'Actif', 'en': 'Active', 'ar': 'نشط'},
    'of_study': {'fr': "d'étude", 'en': 'study', 'ar': 'دراسة'},
    'validated': {'fr': 'validés', 'en': 'passed', 'ar': 'ناجحة'},
    'streak_label': {'fr': 'série', 'en': 'streak', 'ar': 'سلسلة'},
    'see_details': {'fr': 'Voir le détail', 'en': 'See details', 'ar': 'عرض التفاصيل'},
    'discover': {'fr': 'Découvrir', 'en': 'Discover', 'ar': 'اكتشف'},
    'difficulty': {
      'fr': 'Difficulté {level}',
      'en': 'Difficulty {level}',
      'ar': 'الصعوبة {level}'
    },
    'difficulty_medium': {'fr': 'Moyenne', 'en': 'Medium', 'ar': 'متوسطة'},
    'progress_powered': {
      'fr': "Optimisé par l'analyse cognitive StudyAI",
      'en': 'Powered by StudyAI cognitive analysis',
      'ar': 'مدعوم بتحليل StudyAI المعرفي'
    },
    'weekly_activity': {
      'fr': 'Activité hebdomadaire',
      'en': 'Weekly activity',
      'ar': 'نشاط الأسبوع'
    },
    'badges_rewards': {
      'fr': 'Badges & Récompenses',
      'en': 'Badges & rewards',
      'ar': 'الشارات والمكافآت'
    },
    'weekly_goal_hint': {
      'fr': 'Tes stats se mettent à jour après chaque quiz.',
      'en': 'Your stats update after each quiz.',
      'ar': 'تُحدَّث إحصاءاتك بعد كل اختبار.'
    },
    'student_name': {'fr': 'Étudiant', 'en': 'Student', 'ar': 'طالب'},
    'general_subject': {'fr': 'Général', 'en': 'General', 'ar': 'عام'},
    'just_now': {'fr': 'à l’instant', 'en': 'just now', 'ar': 'الآن'},
    'mb_unit': {'fr': 'Mo', 'en': 'MB', 'ar': 'ميغابايت'},
    'prompt_summarize': {
      'fr': 'Résume mon dernier cours en points clés faciles à retenir.',
      'en': 'Summarize my last lesson into key points that are easy to remember.',
      'ar': 'لخّص درسي الأخير في نقاط أساسية سهلة الحفظ.'
    },
    'prompt_explain': {
      'fr': "Explique-moi ce concept comme si j'avais 15 ans, avec un exemple.",
      'en': 'Explain this concept simply, as if I were 15, with an example.',
      'ar': 'اشرح هذا المفهوم ببساطة، كما لو كان عمري 15 عامًا، مع مثال.'
    },
    'prompt_quiz': {
      'fr': 'Génère un QCM de 5 questions pour tester mes connaissances.',
      'en': 'Generate a 5-question multiple-choice quiz to test me.',
      'ar': 'أنشئ اختبار اختيار من متعدد من 5 أسئلة لاختباري.'
    },
    'prompt_flashcards': {
      'fr': 'Crée 5 flashcards (question / réponse) sur ce chapitre.',
      'en': 'Create 5 flashcards (question / answer) on this chapter.',
      'ar': 'أنشئ 5 بطاقات (سؤال / جواب) عن هذا الفصل.'
    },
    'prompt_translate': {
      'fr': 'Traduis ce texte en anglais académique.',
      'en': 'Translate this text into academic English.',
      'ar': 'ترجم هذا النص إلى إنجليزية أكاديمية.'
    },
    'chat_summarize_prompt': {
      'fr': 'Résume les points clés de notre discussion.',
      'en': 'Summarize the key points of our discussion.',
      'ar': 'لخّص النقاط الأساسية لنقاشنا.'
    },
    'chat_explain_prompt': {
      'fr': 'Explique plus simplement, avec un exemple concret.',
      'en': 'Explain more simply, with a concrete example.',
      'ar': 'اشرح بأسلوب أبسط، مع مثال ملموس.'
    },
    'chat_quiz_prompt': {
      'fr': 'Génère un petit QCM de 3 questions sur ce sujet.',
      'en': 'Generate a short 3-question quiz on this topic.',
      'ar': 'أنشئ اختبارًا قصيرًا من 3 أسئلة عن هذا الموضوع.'
    },
    'ask_about_named': {
      'fr': 'Interroge Gemini sur « {title} »',
      'en': 'Ask Gemini about “{title}”',
      'ar': 'اسأل Gemini عن « {title} »'
    },
    'about_document': {
      'fr': 'À propos du document « {title} » : ',
      'en': 'About the document “{title}”: ',
      'ar': 'حول المستند « {title} »: '
    },
    'progress_start_title': {
      'fr': 'Commence quand tu veux 💪',
      'en': 'Start whenever you like 💪',
      'ar': 'ابدأ متى شئت 💪'
    },
    'progress_start_sub': {
      'fr': 'Passe un premier quiz pour lancer ta progression.',
      'en': 'Take a first quiz to start tracking progress.',
      'ar': 'قدّم أول اختبار لبدء تتبع تقدمك.'
    },
    'progress_high_title': {
      'fr': 'Objectif presque atteint ! 🔥',
      'en': 'Almost there! 🔥',
      'ar': 'أوشكت على الهدف! 🔥'
    },
    'progress_high_sub': {
      'fr': 'Continue, tu maîtrises tes sujets.',
      'en': 'Keep going — you are mastering your topics.',
      'ar': 'تابع، أنت تُتقن مواضيعك.'
    },
    'progress_mid_title': {
      'fr': 'Belle progression 👏',
      'en': 'Nice progress 👏',
      'ar': 'تقدم رائع 👏'
    },
    'progress_mid_sub': {
      'fr': 'Enchaîne un quiz pour améliorer ta moyenne.',
      'en': 'Take another quiz to raise your average.',
      'ar': 'قدّم اختبارًا آخر لرفع معدلك.'
    },
    'progress_low_title': {'fr': 'En route 🚀', 'en': 'On the way 🚀', 'ar': 'في الطريق 🚀'},
    'progress_low_sub': {
      'fr': 'Rejoue quelques quiz pour consolider tes acquis.',
      'en': 'Replay a few quizzes to lock in what you learned.',
      'ar': 'أعد بعض الاختبارات لتثبيت ما تعلمته.'
    },
    'badge_quiz_genius': {'fr': 'Génie du QCM', 'en': 'Quiz genius', 'ar': 'عبقري الاختبارات'},
    'badge_gold': {'fr': 'Rang Or', 'en': 'Gold', 'ar': 'ذهبي'},
    'badge_regular': {'fr': 'Étudiant régulier', 'en': 'Regular student', 'ar': 'طالب منتظم'},
    'badge_silver': {'fr': 'Rang Argent', 'en': 'Silver', 'ar': 'فضي'},
    'badge_explorer': {'fr': 'Explorateur IA', 'en': 'AI explorer', 'ar': 'مستكشف الذكاء'},
    'badge_bronze': {'fr': 'Rang Bronze', 'en': 'Bronze', 'ar': 'برونزي'},
    'app_version': {
      'fr': 'StudyAI · Version 1.0.0',
      'en': 'StudyAI · Version 1.0.0',
      'ar': 'StudyAI · الإصدار 1.0.0'
    },
    'ask_studyai_badge': {'fr': 'ASK STUDYAI', 'en': 'ASK STUDYAI', 'ar': 'اسأل STUDYAI'},
    'subjects': {'fr': 'Matières', 'en': 'Subjects', 'ar': 'المواد'},
    'add_subject': {'fr': 'Ajouter une matière', 'en': 'Add a subject', 'ar': 'إضافة مادة'},
    'edit_subject': {'fr': 'Modifier la matière', 'en': 'Edit subject', 'ar': 'تعديل المادة'},
    'subject_name': {'fr': 'Nom de la matière', 'en': 'Subject name', 'ar': 'اسم المادة'},
    'empty_subjects_hint': {
      'fr': 'Crée tes matières (Maths, Histoire…) pour classer tes cours.',
      'en': 'Create subjects (Math, History…) to organize your courses.',
      'ar': 'أنشئ موادك لتنظيم دروسك.',
    },
    'delete_subject': {'fr': 'Supprimer la matière', 'en': 'Delete subject', 'ar': 'حذف المادة'},
    'delete_subject_confirm': {
      'fr': 'Supprimer « {name} » ? Tes documents restent en place.',
      'en': 'Delete “{name}”? Your documents stay in place.',
      'ar': 'حذف « {name} »؟ تبقى مستنداتك كما هي.',
    },
    'search_empty_hint': {
      'fr': 'Cherche un cours, un PDF, un quiz ou une matière.',
      'en': 'Search a course, PDF, quiz or subject.',
      'ar': 'ابحث عن درس أو PDF أو اختبار أو مادة.',
    },
    'no_search_results': {
      'fr': 'Aucun résultat.',
      'en': 'No results.',
      'ar': 'لا نتائج.',
    },
    'course_unavailable': {
      'fr': 'Impossible d’ouvrir ce cours pour le moment.',
      'en': 'Could not open this course right now.',
      'ar': 'تعذر فتح هذا الدرس الآن.',
    },
    'open_pdf': {'fr': 'Ouvrir le PDF', 'en': 'Open PDF', 'ar': 'فتح PDF'},
    'share': {'fr': 'Partager', 'en': 'Share', 'ar': 'مشاركة'},
    'pdf_unavailable': {
      'fr': 'PDF introuvable. Réimporte le fichier.',
      'en': 'PDF not found. Import the file again.',
      'ar': 'تعذر العثور على PDF. أعد استيراد الملف.',
    },
    'flashcards_subtitle': {
      'fr': 'Cartes de révision générées par Gemini, à retourner une par une.',
      'en': 'Gemini-generated review cards you flip one by one.',
      'ar': 'بطاقات مراجعة يولّدها Gemini تقلبها واحدة تلو الأخرى.',
    },
    'generate_flashcards': {
      'fr': 'Générer des flashcards',
      'en': 'Generate flashcards',
      'ar': 'إنشاء بطاقات',
    },
    'flashcard_topic_hint': {
      'fr': 'Ex. : la photosynthèse, les temps en anglais…',
      'en': 'e.g. photosynthesis, English tenses…',
      'ar': 'مثال: البناء الضوئي، الأزمنة…',
    },
    'enter_flashcard_topic': {
      'fr': 'Entre un sujet pour générer des flashcards.',
      'en': 'Enter a topic to generate flashcards.',
      'ar': 'أدخل موضوعًا لإنشاء البطاقات.',
    },
    'your_flashcards': {'fr': 'Tes paquets', 'en': 'Your decks', 'ar': 'حزمك'},
    'empty_flashcards_hint': {
      'fr': 'Aucun paquet encore. Génère-en un ci-dessus.',
      'en': 'No decks yet. Generate one above.',
      'ar': 'لا حزم بعد. أنشئ واحدة أعلاه.',
    },
    'cards_count': {
      'fr': '{count} cartes',
      'en': '{count} cards',
      'ar': '{count} بطاقات',
    },
    'tap_to_flip': {
      'fr': 'Touche pour retourner',
      'en': 'Tap to flip',
      'ar': 'المس للقلب',
    },
    'answer': {'fr': 'Réponse', 'en': 'Answer', 'ar': 'الجواب'},
    'previous': {'fr': 'Précédent', 'en': 'Previous', 'ar': 'السابق'},
    'open_flashcards': {
      'fr': 'Ouvrir les flashcards',
      'en': 'Open flashcards',
      'ar': 'فتح البطاقات',
    },
    'change_password': {
      'fr': 'Changer le mot de passe',
      'en': 'Change password',
      'ar': 'تغيير كلمة المرور',
    },
    'current_password': {
      'fr': 'Mot de passe actuel',
      'en': 'Current password',
      'ar': 'كلمة المرور الحالية',
    },
    'new_password': {
      'fr': 'Nouveau mot de passe',
      'en': 'New password',
      'ar': 'كلمة المرور الجديدة',
    },
    'password_updated': {
      'fr': 'Mot de passe mis à jour.',
      'en': 'Password updated.',
      'ar': 'تم تحديث كلمة المرور.',
    },
    'email_verification': {
      'fr': 'Vérification e-mail',
      'en': 'Email verification',
      'ar': 'التحقق من البريد',
    },
    'email_verified': {
      'fr': 'Adresse vérifiée',
      'en': 'Email verified',
      'ar': 'البريد موثّق',
    },
    'email_not_verified': {
      'fr': 'Pas encore vérifiée — touche pour renvoyer le lien',
      'en': 'Not verified yet — tap to resend the link',
      'ar': 'غير موثّق بعد — المس لإعادة إرسال الرابط',
    },
    'verification_sent': {
      'fr': 'E-mail de vérification envoyé.',
      'en': 'Verification email sent.',
      'ar': 'تم إرسال بريد التحقق.',
    },
    'reset_password_email': {
      'fr': 'Lien de réinitialisation',
      'en': 'Reset link',
      'ar': 'رابط إعادة التعيين',
    },
    'privacy_body': {
      'fr':
          'StudyAI stocke ton profil, tes PDF, quiz et flashcards dans ton compte Firebase. Tu peux copier tes infos ou supprimer le compte. La suppression est définitive.',
      'en':
          'StudyAI stores your profile, PDFs, quizzes and flashcards in your Firebase account. You can copy your info or delete the account. Deletion is permanent.',
      'ar':
          'يخزّن StudyAI ملفك وملفات PDF والاختبارات والبطاقات في حساب Firebase. يمكنك نسخ معلوماتك أو حذف الحساب نهائيًا.',
    },
    'copy_account_info': {
      'fr': 'Copier e-mail et identifiant',
      'en': 'Copy email and account ID',
      'ar': 'نسخ البريد ومعرّف الحساب',
    },
    'delete_account': {
      'fr': 'Supprimer mon compte',
      'en': 'Delete my account',
      'ar': 'حذف حسابي',
    },
    'delete_account_confirm': {
      'fr':
          'Cette action est irréversible. Tes données d’étude seront perdues.',
      'en': 'This cannot be undone. Your study data will be lost.',
      'ar': 'لا يمكن التراجع. ستُفقد بيانات دراستك.',
    },
    'auth_requires_recent_login': {
      'fr': 'Reconnecte-toi puis réessaie cette action.',
      'en': 'Sign in again, then retry this action.',
      'ar': 'سجّل الدخول مجددًا ثم أعد المحاولة.',
    },
  };
}
