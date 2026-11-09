import 'dart:math';

import 'package:countries_flags_quizz/game/session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_countries.dart';

void main() {
  test('a new round has not been tried yet', () {
    final game = startGame(sampleCountries, Random(1));

    expect(game.correct, 0);
    expect(game.attempts, 0);
    expect(game.isComplete, isFalse);
    expect(game.isRevealing, isFalse);
  });

  test('a correct flag counts as a try and a point, and stays on screen', () {
    final game = startGame(sampleCountries, Random(1));
    final revealed = revealAnswer(game, game.question.prompt.code);

    expect(revealed.correct, 1);
    expect(revealed.attempts, 1);
    expect(revealed.pickedTheRightFlag, isTrue);
    expect(revealed.question.prompt.code, game.question.prompt.code);
    expect(revealed.isComplete, isFalse);
  });

  test('a wrong flag costs a try and does not add a point', () {
    final game = startGame(sampleCountries, Random(1));
    final wrong = game.question.choices.firstWhere(
      (country) => country.code != game.question.prompt.code,
    );
    final revealed = revealAnswer(game, wrong.code);

    expect(revealed.correct, 0);
    expect(revealed.attempts, 1);
    expect(revealed.pickedTheRightFlag, isFalse);
  });

  test('a second tap while the choice is showing does not count', () {
    final game = startGame(sampleCountries, Random(1));
    final revealed = revealAnswer(game, game.question.prompt.code);
    final other = game.question.choices.firstWhere(
      (country) => country.code != game.question.prompt.code,
    );
    final again = revealAnswer(revealed, other.code);

    expect(again.attempts, revealed.attempts);
    expect(again.correct, revealed.correct);
    expect(again.pickedCode, revealed.pickedCode);
  });

  test('the next question is a different country', () {
    final random = Random(3);
    final game = startGame(sampleCountries, random);
    final revealed = revealAnswer(game, game.question.prompt.code);
    final next = advanceGame(revealed, sampleCountries, random);

    expect(next.isRevealing, isFalse);
    expect(next.correct, revealed.correct);
    expect(next.attempts, revealed.attempts);
    expect(next.question.prompt.code, isNot(game.question.prompt.code));
  });

  test('the score is the tries it took to reach five correct answers', () {
    final random = Random(7);
    var game = startGame(sampleCountries, random);
    const answers = [true, false, true, true, false, true, true];

    for (final correct in answers) {
      final code = correct
          ? game.question.prompt.code
          : game.question.choices
              .firstWhere(
                (country) => country.code != game.question.prompt.code,
              )
              .code;
      game = revealAnswer(game, code);
      if (!game.isComplete) {
        game = advanceGame(game, sampleCountries, random);
      }
    }

    expect(game.correct, flagsToWin);
    expect(game.attempts, 7);
    expect(game.isComplete, isTrue);
    expect(advanceGame(game, sampleCountries, random), same(game));

    final rating = rateGame(game);
    expect(rating.attempts, 7);
    expect(rating.stars, 3);
    expect(rating.label, 'Good');
  });

  test('an unfinished round has no rating', () {
    final game = startGame(sampleCountries, Random(1));

    expect(() => rateGame(game), throwsStateError);
  });

  test('fewer misses earn a better rating', () {
    GameRating ratingFor(int attempts) {
      return GameRating(attempts: attempts, target: flagsToWin);
    }

    expect(ratingFor(5).label, 'Perfect');
    expect(ratingFor(5).stars, 5);
    expect(ratingFor(6).label, 'Great');
    expect(ratingFor(6).stars, 4);
    expect(ratingFor(8).label, 'Good');
    expect(ratingFor(8).stars, 3);
    expect(ratingFor(11).label, 'Nice work');
    expect(ratingFor(11).stars, 2);
    expect(ratingFor(12).label, 'You did it');
    expect(ratingFor(12).stars, 1);
  });
}
