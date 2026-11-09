import 'dart:math';

import 'package:countries_flags_quizz/data/language_store.dart';
import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/language.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/quiz_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const france = Country(
    code: 'FR',
    name: 'France',
    swedish: 'Frankrike',
    french: 'France',
    continent: 'Europe',
  );
  const spain = Country(
    code: 'ES',
    name: 'Spain',
    swedish: 'Spanien',
    french: 'Espagne',
    continent: 'Europe',
  );
  const japan = Country(
    code: 'JP',
    name: 'Japan',
    swedish: 'Japan',
    french: 'Japon',
    continent: 'Asia',
  );
  const countries = [france, spain, japan];

  test('a country answers in the chosen language', () {
    expect(france.nameIn(QuizLanguage.english), 'France');
    expect(france.nameIn(QuizLanguage.swedish), 'Frankrike');
    expect(spain.nameIn(QuizLanguage.french), 'Espagne');
  });

  test('an unknown saved code stays in English', () {
    expect(QuizLanguageDetails.fromCode(null), QuizLanguage.english);
    expect(QuizLanguageDetails.fromCode('de'), QuizLanguage.english);
    expect(QuizLanguageDetails.fromCode('sv'), QuizLanguage.swedish);
    expect(QuizLanguageDetails.fromCode('fr'), QuizLanguage.french);
  });

  test('the language choice is remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final store = PrefsLanguageStore();

    expect(await store.read(), QuizLanguage.english);

    await store.save(QuizLanguage.french);

    expect(await PrefsLanguageStore().read(), QuizLanguage.french);
  });

  testWidgets('flag buttons at the bottom of the menu choose the language', (
    tester,
  ) async {
    final languages = MemoryLanguageStore();
    await tester.pumpWidget(
      QuizApp(
        countries: countries,
        scoreStore: MemoryScoreStore(),
        languageStore: languages,
        random: Random(1),
        feedbackDelay: Duration.zero,
        flagBuilder: (Country country) {
          return ColoredBox(
            color: const Color(0xFFBFDBFE),
            child: Text(country.code),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BR'), findsOneWidget);
    expect(find.text('JP'), findsOneWidget);
    expect(find.byKey(const Key('language-en')), findsOneWidget);
    expect(find.byKey(const Key('language-sv')), findsOneWidget);
    expect(find.byKey(const Key('language-fr')), findsOneWidget);

    final view = tester.view.physicalSize / tester.view.devicePixelRatio;
    final start = tester.getRect(find.byKey(const Key('start-game')));
    final swedish = tester.getRect(find.byKey(const Key('language-sv')));
    expect(swedish.top, greaterThan(start.bottom));
    expect(swedish.bottom, greaterThan(view.height - 40));

    await tester.tap(find.byKey(const Key('language-sv')));
    await tester.pumpAndSettle();

    expect(languages.language, QuizLanguage.swedish);
    expect(find.text('Flaggquiz'), findsOneWidget);
    expect(find.text('Starta'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();

    final shown =
        tester.widget<Text>(find.byKey(const Key('country-name'))).data;
    expect(countries.map((country) => country.swedish), contains(shown));
    expect(find.text('Vilken flagga är det här?'), findsOneWidget);
    expect(find.text('Försök 0'), findsOneWidget);
  });
}
