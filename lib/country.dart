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

class QuizzCard extends StatefulWidget {
  const QuizzCard({
    super.key,
    required this.countries,
    this.child,
  });

  final List<Country> countries;
  final Widget? child;

  @override
  State<QuizzCard> createState() => _QuizzCard();
}

enum StatusEnum { zero, one, two }

class _QuizzCard extends State<QuizzCard> {
  StatusEnum _status = StatusEnum.zero;
  void updateStatus(StatusEnum newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<int> randIndexes = [];
    while (randIndexes.length < 3) {
      int i = Random().nextInt(widget.countries.length);
      if (!randIndexes.contains(i)) {
        randIndexes.add(i);
      }
    }
    int randomCountry = Random().nextInt(3);
    return Center(
        child: Column(children: <Widget>[
      Text(widget.countries[randIndexes[randomCountry]].name,
          style: const TextStyle(fontSize: 50)),
      Flexible(
          child: ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final item =
                    widget.countries[randIndexes[index]].code.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    if (item ==
                        widget.countries[randIndexes[randomCountry]].code
                            .toLowerCase()) {
                      updateStatus(StatusEnum.one);
                    } else {
                      updateStatus(StatusEnum.two);
                    }
                  },
                  child: Container(
                      color: Colors.blue[200],
                      padding: const EdgeInsets.all(3),
                      child: Image.network(
                        "https://flagcdn.com/144x108/$item.png",
                        width: 300,
                        height: 150,
                        fit: BoxFit.contain,
                      )),
                );
              })),
      Container(
        child: switch (_status) {
          StatusEnum.zero => const Text("Pick a flag"),
          StatusEnum.one => const Text("Correct"),
          StatusEnum.two => const Text("Wrong"),
        },
      )
    ]));
  }
}
