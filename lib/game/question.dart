import 'dart:math';

import 'package:countries_flags_quizz/models/country.dart';

/// Flags shown for each country name.
const int choicesPerQuestion = 3;

class Question {
  const Question({required this.prompt, required this.choices});

  /// Country the player has to find.
  final Country prompt;

  /// Flags to choose from. Always includes [prompt].
  final List<Country> choices;
}

/// Builds one question from [countries].
///
/// Choices are distinct. [avoidCode] is left out when the remaining pool is
/// still large enough, so the next question is not the one just answered.
Question buildQuestion(
  List<Country> countries,
  Random random, {
  String? avoidCode,
  int choiceCount = choicesPerQuestion,
}) {
  if (choiceCount < 2) {
    throw ArgumentError.value(choiceCount, 'choiceCount', 'At least 2');
  }

  final unique = <String, Country>{
    for (final country in countries) country.code: country,
  };
  final pool = unique.values.toList();
  if (avoidCode != null && pool.length - 1 >= choiceCount) {
    pool.removeWhere((country) => country.code == avoidCode);
  }
  if (pool.length < choiceCount) {
    throw ArgumentError(
      'Need at least $choiceCount different countries for a question',
    );
  }

  pool.shuffle(random);
  final prompt = pool.first;
  final choices = pool.take(choiceCount).toList()..shuffle(random);
  return Question(prompt: prompt, choices: choices);
}
