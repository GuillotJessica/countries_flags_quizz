import 'dart:math';

import 'package:countries_flags_quizz/data/language_store.dart';
import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/game/session.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/quiz_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_countries.dart';

void main() {
  Future<void> openApp(
    WidgetTester tester, {
    ScoreStore? scoreStore,
    Size? physicalSize,
    Duration feedbackDelay = Duration.zero,
  }) async {
    if (physicalSize != null) {
      tester.view.physicalSize = physicalSize;
      tester.view.devicePixelRatio = 2;
    }
    await tester.pumpWidget(
      QuizApp(
        countries: sampleCountries,
        scoreStore: scoreStore ?? MemoryScoreStore(),
        languageStore: MemoryLanguageStore(),
        random: Random(1),
        feedbackDelay: feedbackDelay,
        flagBuilder: (Country country) {
          return ColoredBox(color: const Color(0xFFBFDBFE));
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts a round and asks for a flag', (tester) async {
    await openApp(tester);

    expect(find.text('Flag Quiz'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('play-screen')), findsOneWidget);
    expect(find.byKey(const Key('progress')), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Tries 0'), findsOneWidget);

    final name = tester.widget<Text>(find.byKey(const Key('country-name')));
    final prompt = sampleCountries.firstWhere(
      (country) => country.name == name.data,
    );
    expect(find.byKey(Key('flag-${prompt.code}')), findsOneWidget);
  });

  testWidgets('a wrong flag costs a try and keeps the score at zero', (
    tester,
  ) async {
    await openApp(tester, feedbackDelay: const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();

    final name =
        tester.widget<Text>(find.byKey(const Key('country-name'))).data;
    final prompt =
        sampleCountries.firstWhere((country) => country.name == name);
    final wrong = sampleCountries.firstWhere(
      (country) =>
          country.code != prompt.code &&
          find.byKey(Key('flag-${country.code}')).evaluate().isNotEmpty,
    );

    await tester.tap(find.byKey(Key('flag-${wrong.code}')));
    await tester.pump();
    expect(find.text('Look at the green one'), findsOneWidget);
    expect(find.text('Tries 1'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Tries 1'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
  });

  testWidgets('five correct flags end the round and a new game can start', (
    tester,
  ) async {
    final scores = MemoryScoreStore();
    await openApp(tester, scoreStore: scores);

    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();

    for (var i = 0; i < flagsToWin; i++) {
      final name =
          tester.widget<Text>(find.byKey(const Key('country-name'))).data;
      final prompt = sampleCountries.firstWhere(
        (country) => country.name == name,
      );
      await tester.tap(find.byKey(Key('flag-${prompt.code}')));
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('well-done')), findsOneWidget);
    expect(find.text('Perfect'), findsOneWidget);
    expect(find.text('5 flags in 5 tries'), findsOneWidget);
    expect(find.byKey(const Key('new-best')), findsOneWidget);
    expect((await scores.readBest())?.attempts, 5);

    await tester.tap(find.byKey(const Key('play-again')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('play-screen')), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Tries 0'), findsOneWidget);
  });

  testWidgets('stopping a round returns home without a score', (tester) async {
    final scores = MemoryScoreStore();
    await openApp(tester, scoreStore: scores);

    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('stop-game')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-screen')), findsOneWidget);
    expect(find.byKey(const Key('best-score')), findsNothing);
    expect(await scores.readBest(), isNull);
  });
}
