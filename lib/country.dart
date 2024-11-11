import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<List<Country>> loadCountries(http.Client client) async {
  String jsonString = await rootBundle.loadString('countries.json');
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseCountries, jsonString);
}

Future<List<List<Country>>> createCountriesQuizz(int size) async {
  var countries = await loadCountries(http.Client());
  List<Country> quizz(int i) => List<Country>.generate(
      3, (i) => countries[Random().nextInt(countries.length)]);
  return List<List<Country>>.generate(10, quizz);
}

// A function that converts a response body into a List<Photo>.
List<Country> parseCountries(String responseBody) {
  final parsed =
      (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();

  return parsed.map<Country>((json) => Country.fromJson(json)).toList();
}

class Country {
  final String code;
  final String name;
  final String swedish;
  final String french;
  final String continent;

  const Country({
    required this.code,
    required this.name,
    required this.swedish,
    required this.french,
    required this.continent,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      code: json['code'] as String,
      swedish: json['swedish'] as String,
      french: json['french'] as String,
      continent: json['continent'] as String,
    );
  }
}

class QuizzCard extends StatelessWidget {
  const QuizzCard({
    super.key,
    required this.countries,
    required this.update,
    this.child,
  });
//QuizzCard
  final List<Country> countries;
  final Function update;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    Country randTitle = countries[Random().nextInt(countries.length)];
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.5,
        color: Colors.white,
        child: Column(children: <Widget>[
          Expanded(
              child:
                  Text(randTitle.name, style: const TextStyle(fontSize: 50))),
          ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final item = countries[index].code.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    update(item == randTitle.code.toLowerCase());
                  },
                  child: Container(
                      padding: const EdgeInsets.all(3),
                      child: Image.network(
                        "https://flagcdn.com/144x108/$item.png",
                        width: 300,
                        height: 150,
                        fit: BoxFit.contain,
                      )),
                );
              }),
        ]));
  }
}
