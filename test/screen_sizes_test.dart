import 'dart:math';

import 'package:countries_flags_quizz/data/language_store.dart';
import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/flag_image.dart';
import 'package:countries_flags_quizz/ui/quiz_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_countries.dart';

void main() {
  // Logical points. iPad Pro 13-inch is 1032 x 1376 at a pixel ratio of 2.
  const ipadPortrait = Size(1032, 1376);
  const ipadLandscape = Size(1376, 1032);
  const browser = Size(1440, 900);

  Future<void> playAt(
    WidgetTester tester, {
    required Size logicalSize,
    required double devicePixelRatio,
    List<Country>? countries,
  }) async {
    tester.view.devicePixelRatio = devicePixelRatio;
    tester.view.physicalSize = Size(
      logicalSize.width * devicePixelRatio,
      logicalSize.height * devicePixelRatio,
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      QuizApp(
        countries: countries ?? sampleCountries,
        scoreStore: MemoryScoreStore(),
        languageStore: MemoryLanguageStore(),
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
    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pumpAndSettle();
  }

  void expectWholeFlagsOnScreen(WidgetTester tester) {
    final squares = find.byType(AspectRatio);
    expect(squares, findsNWidgets(3));

    final view = tester.view.physicalSize / tester.view.devicePixelRatio;
    for (final element in squares.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final widget = element.widget as AspectRatio;
      expect(widget.aspectRatio, 1);
      expect(box.size.width, closeTo(box.size.height, 0.5));
      expect(box.size.shortestSide, greaterThanOrEqualTo(48));

      final origin = box.localToGlobal(Offset.zero);
      expect(origin.dx, greaterThanOrEqualTo(-0.5));
      expect(origin.dy, greaterThanOrEqualTo(-0.5));
      expect(origin.dx + box.size.width, lessThanOrEqualTo(view.width + 0.5));
      expect(
        origin.dy + box.size.height,
        lessThanOrEqualTo(view.height + 0.5),
      );
    }
    expect(tester.takeException(), isNull);
  }

  Future<void> answerCorrectly(WidgetTester tester) async {
    final name =
        tester.widget<Text>(find.byKey(const Key('country-name'))).data;
    final prompt = [
      ...sampleCountries,
      ...longCountryNames,
    ].firstWhere((country) => country.name == name);
    await tester.tap(find.byKey(Key('flag-${prompt.code}')));
    await tester.pumpAndSettle();
  }

  testWidgets('flag pictures are contained, so a wide screen cannot crop them',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlagImage(
            country: Country(
              code: 'FR',
              name: 'France',
              swedish: 'Frankrike',
              french: 'France',
              continent: 'Europe',
            ),
          ),
        ),
      ),
    );

    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
  });

  testWidgets('an iPad portrait round keeps every flag whole and tappable', (
    tester,
  ) async {
    await playAt(
      tester,
      logicalSize: ipadPortrait,
      devicePixelRatio: 2,
      countries: longCountryNames,
    );

    expectWholeFlagsOnScreen(tester);
    expect(find.text('0/5'), findsOneWidget);
    await answerCorrectly(tester);
    expect(find.text('1/5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an iPad landscape round keeps every flag whole and tappable', (
    tester,
  ) async {
    await playAt(
      tester,
      logicalSize: ipadLandscape,
      devicePixelRatio: 2,
    );

    expectWholeFlagsOnScreen(tester);
    await answerCorrectly(tester);
    expect(find.text('1/5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a browser window keeps every flag whole and tappable', (
    tester,
  ) async {
    await playAt(
      tester,
      logicalSize: browser,
      devicePixelRatio: 1,
      countries: longCountryNames,
    );

    expectWholeFlagsOnScreen(tester);
    await answerCorrectly(tester);
    expect(find.text('1/5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final longCountryNames = [
  sampleCountry('TZ', 'Tanzania, United Republic of', continent: 'Africa'),
  sampleCountry('LA', "Lao People's Democratic Republic", continent: 'Asia'),
  sampleCountry(
    'CD',
    'Congo, The Democratic Republic of the',
    continent: 'Africa',
  ),
];
