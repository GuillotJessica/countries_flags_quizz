import 'dart:convert';

import 'package:countries_flags_quizz/models/country.dart';
import 'package:flutter/services.dart';

/// Places that are a poor fit for a child's flag round.
const excludedContinents = {'Antarctica'};

List<Country> parseCountries(String jsonString) {
  final parsed = jsonDecode(jsonString) as List<dynamic>;
  return parsed
      .map((item) => Country.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Drops excluded places and repeated codes, keeping the first of each code.
List<Country> playableCountries(List<Country> countries) {
  final seen = <String>{};
  return [
    for (final country in countries)
      if (seen.add(country.code) &&
          !excludedContinents.contains(country.continent))
        country,
  ];
}

Future<List<Country>> loadCountries() async {
  final jsonString = await rootBundle.loadString('assets/countries.json');
  return playableCountries(parseCountries(jsonString));
}
