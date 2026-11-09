import 'package:countries_flags_quizz/models/country.dart';

/// The language a round is played in.
enum QuizLanguage { english, swedish, french }

extension QuizLanguageDetails on QuizLanguage {
  String get code {
    return switch (this) {
      QuizLanguage.english => 'en',
      QuizLanguage.swedish => 'sv',
      QuizLanguage.french => 'fr',
    };
  }

  /// Flag shown on the menu button for this language.
  String get flagCode {
    return switch (this) {
      QuizLanguage.english => 'GB',
      QuizLanguage.swedish => 'SE',
      QuizLanguage.french => 'FR',
    };
  }

  Country get flagCountry {
    return Country(
      code: flagCode,
      name: flagCode,
      swedish: flagCode,
      french: flagCode,
      continent: 'Europe',
    );
  }

  static QuizLanguage fromCode(String? code) {
    return switch (code) {
      'sv' => QuizLanguage.swedish,
      'fr' => QuizLanguage.french,
      _ => QuizLanguage.english,
    };
  }
}

extension LocalizedCountryName on Country {
  String nameIn(QuizLanguage language) {
    return switch (language) {
      QuizLanguage.english => name,
      QuizLanguage.swedish => swedish,
      QuizLanguage.french => french,
    };
  }
}

/// Words the player sees. Country names come from [LocalizedCountryName].
class QuizCopy {
  const QuizCopy(this.language);

  final QuizLanguage language;

  String get title {
    return switch (language) {
      QuizLanguage.english => 'Flag Quiz',
      QuizLanguage.swedish => 'Flaggquiz',
      QuizLanguage.french => 'Quiz des drapeaux',
    };
  }

  String get tagline {
    return switch (language) {
      QuizLanguage.english => 'Find 5 flags. Fewer tries makes a better game.',
      QuizLanguage.swedish =>
        'Hitta 5 flaggor. Färre försök ger ett bättre spel.',
      QuizLanguage.french =>
        'Trouve 5 drapeaux. Moins d\'essais, meilleure partie.',
    };
  }

  String best(int attempts) {
    return switch (language) {
      QuizLanguage.english => 'Best game: $attempts tries',
      QuizLanguage.swedish => 'Bästa spel: $attempts försök',
      QuizLanguage.french => 'Meilleure partie : $attempts essais',
    };
  }

  String get start {
    return switch (language) {
      QuizLanguage.english => 'Start',
      QuizLanguage.swedish => 'Starta',
      QuizLanguage.french => 'Commencer',
    };
  }

  String get stop {
    return switch (language) {
      QuizLanguage.english => 'Stop',
      QuizLanguage.swedish => 'Stopp',
      QuizLanguage.french => 'Stop',
    };
  }

  String tries(int attempts) {
    return switch (language) {
      QuizLanguage.english => 'Tries $attempts',
      QuizLanguage.swedish => 'Försök $attempts',
      QuizLanguage.french => 'Essais $attempts',
    };
  }

  String get whichFlag {
    return switch (language) {
      QuizLanguage.english => 'Which flag is this?',
      QuizLanguage.swedish => 'Vilken flagga är det här?',
      QuizLanguage.french => 'Quel est ce drapeau ?',
    };
  }

  String get yes {
    return switch (language) {
      QuizLanguage.english => 'Yes',
      QuizLanguage.swedish => 'Ja',
      QuizLanguage.french => 'Oui',
    };
  }

  String get lookAtTheGreenOne {
    return switch (language) {
      QuizLanguage.english => 'Look at the green one',
      QuizLanguage.swedish => 'Titta på den gröna',
      QuizLanguage.french => 'Regarde le vert',
    };
  }

  String flagOf(String name) {
    return switch (language) {
      QuizLanguage.english => 'Flag of $name',
      QuizLanguage.swedish => 'Flagga för $name',
      QuizLanguage.french => 'Drapeau : $name',
    };
  }

  String get wellDone {
    return switch (language) {
      QuizLanguage.english => 'Well done',
      QuizLanguage.swedish => 'Bra jobbat',
      QuizLanguage.french => 'Bravo',
    };
  }

  String rating(int stars) {
    return switch (language) {
      QuizLanguage.english => switch (stars) {
          5 => 'Perfect',
          4 => 'Great',
          3 => 'Good',
          2 => 'Nice work',
          _ => 'You did it',
        },
      QuizLanguage.swedish => switch (stars) {
          5 => 'Perfekt',
          4 => 'Jättebra',
          3 => 'Bra',
          2 => 'Bra kämpat',
          _ => 'Du klarade det',
        },
      QuizLanguage.french => switch (stars) {
          5 => 'Parfait',
          4 => 'Super',
          3 => 'Bien',
          2 => 'Beau travail',
          _ => 'Tu as réussi',
        },
    };
  }

  String result(int target, int attempts) {
    return switch (language) {
      QuizLanguage.english => '$target flags in $attempts tries',
      QuizLanguage.swedish => '$target flaggor på $attempts försök',
      QuizLanguage.french => '$target drapeaux en $attempts essais',
    };
  }

  String stars(int count) {
    return switch (language) {
      QuizLanguage.english => '$count stars',
      QuizLanguage.swedish => '$count stjärnor',
      QuizLanguage.french => '$count étoiles',
    };
  }

  String get newBest {
    return switch (language) {
      QuizLanguage.english => 'New best',
      QuizLanguage.swedish => 'Nytt rekord',
      QuizLanguage.french => 'Nouveau record',
    };
  }

  String get newGame {
    return switch (language) {
      QuizLanguage.english => 'New game',
      QuizLanguage.swedish => 'Nytt spel',
      QuizLanguage.french => 'Nouvelle partie',
    };
  }

  String get loadError {
    return switch (language) {
      QuizLanguage.english => 'The country list could not be loaded.',
      QuizLanguage.swedish => 'Landlistan kunde inte läsas.',
      QuizLanguage.french => 'La liste des pays n\'a pas pu être chargée.',
    };
  }

  String get tryAgain {
    return switch (language) {
      QuizLanguage.english => 'Try again',
      QuizLanguage.swedish => 'Försök igen',
      QuizLanguage.french => 'Réessayer',
    };
  }

  String languageName(QuizLanguage value) {
    return switch (value) {
      QuizLanguage.english => 'English',
      QuizLanguage.swedish => 'Svenska',
      QuizLanguage.french => 'Français',
    };
  }
}
