import 'package:countries_flags_quizz/game/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fewest tries saved for a finished round.
class BestScore {
  const BestScore({required this.attempts, required this.target});

  final int attempts;
  final int target;

  bool isBetterThan(BestScore? other) {
    if (other == null || other.target != target) {
      return true;
    }
    return attempts < other.attempts;
  }
}

class SavedScore {
  const SavedScore({required this.best, required this.improved});

  final BestScore best;
  final bool improved;
}

abstract class ScoreStore {
  Future<BestScore?> readBest();

  Future<SavedScore> saveIfBetter(GameRating rating);
}

class MemoryScoreStore implements ScoreStore {
  BestScore? _best;

  @override
  Future<BestScore?> readBest() async => _best;

  @override
  Future<SavedScore> saveIfBetter(GameRating rating) async {
    final next = BestScore(attempts: rating.attempts, target: rating.target);
    final improved = next.isBetterThan(_best);
    if (improved) {
      _best = next;
    }
    return SavedScore(best: _best!, improved: improved);
  }
}

class PrefsScoreStore implements ScoreStore {
  static const attemptsKey = 'best_attempts';
  static const targetKey = 'best_target';

  @override
  Future<BestScore?> readBest() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(attemptsKey);
    final target = prefs.getInt(targetKey);
    if (attempts == null || target == null) {
      return null;
    }
    return BestScore(attempts: attempts, target: target);
  }

  @override
  Future<SavedScore> saveIfBetter(GameRating rating) async {
    final current = await readBest();
    final next = BestScore(attempts: rating.attempts, target: rating.target);
    if (!next.isBetterThan(current)) {
      return SavedScore(best: current!, improved: false);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(attemptsKey, next.attempts);
    await prefs.setInt(targetKey, next.target);
    return SavedScore(best: next, improved: true);
  }
}
