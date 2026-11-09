import 'package:countries_flags_quizz/models/country.dart';

Country sampleCountry(
  String code,
  String name, {
  String continent = 'Europe',
}) {
  return Country(
    code: code,
    name: name,
    swedish: name,
    french: name,
    continent: continent,
  );
}

final france = sampleCountry('FR', 'France');
final spain = sampleCountry('ES', 'Spain');
final italy = sampleCountry('IT', 'Italy');
final japan = sampleCountry('JP', 'Japan', continent: 'Asia');
final brazil = sampleCountry('BR', 'Brazil', continent: 'South America');
final canada = sampleCountry('CA', 'Canada', continent: 'North America');
final antarctica = sampleCountry('AQ', 'Antarctica', continent: 'Antarctica');

final sampleCountries = [france, spain, italy, japan, brazil, canada];
