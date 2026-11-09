import 'package:countries_flags_quizz/models/country.dart';
import 'package:flutter/material.dart';

typedef FlagBuilder = Widget Function(Country country);

class FlagImage extends StatelessWidget {
  const FlagImage({super.key, required this.country, this.builder});

  final Country country;
  final FlagBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final custom = builder?.call(country);
    if (custom != null) {
      return custom;
    }

    final code = country.code.toLowerCase();
    return Image.network(
      'https://flagcdn.com/w640/$code.png',
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const ColoredBox(
          color: Color(0xFFD5DDE6),
          child: Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: const Color(0xFFE8EEF5),
          child: Center(
            child: Text(
              country.code,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      },
    );
  }
}
