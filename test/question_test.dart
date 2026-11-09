import 'dart:math';

import 'package:countries_flags_quizz/game/question.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_countries.dart';

void main() {
  test('a question has three distinct flags and includes the country', () {
    final question = buildQuestion(sampleCountries, Random(1));

    expect(question.choices, hasLength(choicesPerQuestion));
    expect(
      question.choices.map((country) => country.code).toSet(),
      hasLength(choicesPerQuestion),
    );
    expect(
      question.choices.map((country) => country.code),
      contains(question.prompt.code),
    );
  });

  test('the same seed builds the same question', () {
    final first = buildQuestion(sampleCountries, Random(4));
    final second = buildQuestion(sampleCountries, Random(4));

    expect(first.prompt.code, second.prompt.code);
    expect(
      first.choices.map((country) => country.code),
      second.choices.map((country) => country.code),
    );
  });

  test('repeated codes count as one country', () {
    final question = buildQuestion(
      [france, france, spain, italy],
      Random(1),
    );

    expect(
      question.choices.map((country) => country.code).toSet(),
      hasLength(3),
    );
  });

  test('too few countries cannot make a question', () {
    expect(
      () => buildQuestion([france, france, spain], Random(1)),
      throwsArgumentError,
    );
  });

  test('the country just answered is left out when the pool allows it', () {
    final question = buildQuestion(
      sampleCountries,
      Random(2),
      avoidCode: france.code,
    );

    expect(question.prompt.code, isNot(france.code));
    expect(
      question.choices.map((country) => country.code),
      isNot(contains(france.code)),
    );
  });

  test('a full-size pool still builds a question when avoiding one country',
      () {
    final question = buildQuestion(
      [france, spain, italy],
      Random(2),
      avoidCode: france.code,
    );

    expect(question.choices, hasLength(3));
    expect(
      question.choices.map((country) => country.code),
      contains(question.prompt.code),
    );
  });
}
