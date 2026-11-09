import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/game/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  GameRating rating(int attempts) {
    return GameRating(attempts: attempts, target: flagsToWin);
  }

  group('MemoryScoreStore', () {
    test('keeps the game with the fewest tries', () async {
      final store = MemoryScoreStore();

      expect(await store.readBest(), isNull);

      final first = await store.saveIfBetter(rating(8));
      expect(first.improved, isTrue);
      expect(first.best.attempts, 8);

      final worse = await store.saveIfBetter(rating(10));
      expect(worse.improved, isFalse);
      expect(worse.best.attempts, 8);

      final better = await store.saveIfBetter(rating(6));
      expect(better.improved, isTrue);
      expect(better.best.attempts, 6);
      expect((await store.readBest())?.attempts, 6);
    });
  });

  group('PrefsScoreStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('remembers the best game on disk', () async {
      final store = PrefsScoreStore();

      expect(await store.readBest(), isNull);

      final saved = await store.saveIfBetter(rating(7));
      expect(saved.improved, isTrue);

      final again = PrefsScoreStore();
      expect((await again.readBest())?.attempts, 7);

      final worse = await again.saveIfBetter(rating(9));
      expect(worse.improved, isFalse);
      expect((await PrefsScoreStore().readBest())?.attempts, 7);
    });
  });
}
