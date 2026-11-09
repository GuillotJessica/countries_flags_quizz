import 'package:countries_flags_quizz/data/country_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_countries.dart';

void main() {
  test('playable countries drop Antarctica and repeated codes', () {
    const json = '''
[
  {"name":"France","code":"FR","swedish":"Frankrike","french":"France","continent":"Europe"},
  {"name":"France again","code":"FR","swedish":"Frankrike","french":"France","continent":"Europe"},
  {"name":"Antarctica","code":"AQ","swedish":"Antarktis","french":"Antarctique","continent":"Antarctica"}
]
''';

    final countries = playableCountries(parseCountries(json));

    expect(countries.map((country) => country.code), ['FR']);
    expect(countries.single.name, 'France');
    expect(countries.single.french, 'France');
    expect(countries.single.swedish, 'Frankrike');
  });

  test('the filter keeps a normal country', () {
    final countries = playableCountries([france, antarctica, france]);

    expect(countries, [france]);
  });

  test('the bundled list loads and leaves out Antarctica', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final countries = await loadCountries();

    expect(countries.length, greaterThan(150));
    expect(
      countries.map((country) => country.continent),
      isNot(contains('Antarctica')),
    );
    expect(
      countries.map((country) => country.code).toSet(),
      hasLength(countries.length),
    );
    expect(
      countries.map((country) => country.code),
      containsAll(['FR', 'SE', 'JP']),
    );
  });
}
