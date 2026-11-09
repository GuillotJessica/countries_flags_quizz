import 'dart:math';

import 'package:countries_flags_quizz/game/question.dart';
import 'package:countries_flags_quizz/models/country.dart';

/// Correct answers that finish a round.
const int flagsToWin = 5;

/// A round in progress.
///
/// The round ends at [target] correct answers. Wrong taps stay in the round,
/// and the result is [attempts]: how many tries those correct answers took.
class GameSnapshot {
  const GameSnapshot({
    required this.correct,
    required this.attempts,
    required this.question,
    this.pickedCode,
    this.target = flagsToWin,
  });

  final int correct;
  final int attempts;
  final Question question;
  final String? pickedCode;
  final int target;

  bool get isRevealing => pickedCode != null;

  bool get isComplete => correct >= target;

  bool get pickedTheRightFlag =>
      pickedCode != null && pickedCode == question.prompt.code;

  GameSnapshot copyWith({
    int? correct,
    int? attempts,
    Question? question,
    String? pickedCode,
    bool clearPicked = false,
    int? target,
  }) {
    return GameSnapshot(
      correct: correct ?? this.correct,
      attempts: attempts ?? this.attempts,
      question: question ?? this.question,
      pickedCode: clearPicked ? null : pickedCode ?? this.pickedCode,
      target: target ?? this.target,
    );
  }
}

GameSnapshot startGame(List<Country> countries, Random random) {
  return GameSnapshot(
    correct: 0,
    attempts: 0,
    question: buildQuestion(countries, random),
  );
}

/// Records a tap and keeps the same question so the choice can be shown.
///
/// A second tap while the choice is showing does nothing.
GameSnapshot revealAnswer(GameSnapshot game, String countryCode) {
  if (game.isRevealing || game.isComplete) {
    return game;
  }
  final right = countryCode == game.question.prompt.code;
  return game.copyWith(
    attempts: game.attempts + 1,
    correct: game.correct + (right ? 1 : 0),
    pickedCode: countryCode,
  );
}

/// Moves to the next country after a choice has been shown.
///
/// A finished round stays where it is.
GameSnapshot advanceGame(
  GameSnapshot game,
  List<Country> countries,
  Random random,
) {
  if (!game.isRevealing || game.isComplete) {
    return game;
  }
  return game.copyWith(
    clearPicked: true,
    question: buildQuestion(
      countries,
      random,
      avoidCode: game.question.prompt.code,
    ),
  );
}

/// How good a finished round was. Fewer [attempts] is better.
class GameRating {
  const GameRating({required this.attempts, required this.target});

  final int attempts;
  final int target;

  int get misses => attempts - target;

  int get stars {
    final extra = misses;
    if (extra <= 0) return 5;
    if (extra == 1) return 4;
    if (extra <= 3) return 3;
    if (extra <= 6) return 2;
    return 1;
  }

  String get label {
    return switch (stars) {
      5 => 'Perfect',
      4 => 'Great',
      3 => 'Good',
      2 => 'Nice work',
      _ => 'You did it',
    };
  }
}

GameRating rateGame(GameSnapshot game) {
  if (!game.isComplete) {
    throw StateError('Rate a round after $flagsToWin correct answers');
  }
  return GameRating(attempts: game.attempts, target: game.target);
}
