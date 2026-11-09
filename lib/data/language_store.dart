import 'package:countries_flags_quizz/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LanguageStore {
  Future<QuizLanguage> read();

  Future<void> save(QuizLanguage language);
}

class MemoryLanguageStore implements LanguageStore {
  MemoryLanguageStore([this.language = QuizLanguage.english]);

  QuizLanguage language;

  @override
  Future<QuizLanguage> read() async => language;

  @override
  Future<void> save(QuizLanguage language) async {
    this.language = language;
  }
}

class PrefsLanguageStore implements LanguageStore {
  static const languageKey = 'language';

  @override
  Future<QuizLanguage> read() async {
    final prefs = await SharedPreferences.getInstance();
    return QuizLanguageDetails.fromCode(prefs.getString(languageKey));
  }

  @override
  Future<void> save(QuizLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language.code);
  }
}
