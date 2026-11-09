class Country {
  const Country({
    required this.code,
    required this.name,
    required this.swedish,
    required this.french,
    required this.continent,
  });

  final String code;
  final String name;
  final String swedish;
  final String french;
  final String continent;

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
