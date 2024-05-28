import 'dart:async';
import 'dart:convert';

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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Isolate Demo';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Country>> futureCountries;

  @override
  void initState() {
    super.initState();
    futureCountries = loadCountries(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Country>>(
        future: futureCountries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return CountryList(countries: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class CountryList extends StatelessWidget {
  const CountryList({super.key, required this.countries});

  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        return  Image.network("https://flagcdn.com/144x108/${countries[index].code.toLowerCase()}.png");
        // return  Image.network("https://flagcdn.com/144x108/${countries[index].code}.png");
      },
    );
  }
}