import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/language.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/flag_image.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.copy,
    required this.language,
    required this.onStart,
    required this.onLanguage,
    this.best,
    this.flagBuilder,
  });

  final QuizCopy copy;
  final QuizLanguage language;
  final VoidCallback onStart;
  final ValueChanged<QuizLanguage> onLanguage;
  final BestScore? best;
  final FlagBuilder? flagBuilder;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      key: const Key('home-screen'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final code in const ['FR', 'BR', 'JP'])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: SizedBox(
                                    width: 72,
                                    height: 48,
                                    child: FlagImage(
                                      country: _mark(code),
                                      builder: flagBuilder,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          copy.title,
                          textAlign: TextAlign.center,
                          style: text.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          copy.tagline,
                          textAlign: TextAlign.center,
                          style: text.titleLarge,
                        ),
                        if (best != null) ...[
                          const SizedBox(height: 28),
                          Text(
                            copy.best(best!.attempts),
                            key: const Key('best-score'),
                            style: text.titleMedium,
                          ),
                        ],
                        const SizedBox(height: 36),
                        FilledButton(
                          key: const Key('start-game'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(220, 64),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: onStart,
                          child: Text(copy.start),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final choice in QuizLanguage.values) ...[
                    if (choice != QuizLanguage.values.first)
                      const SizedBox(width: 16),
                    _LanguageFlag(
                      language: choice,
                      selected: choice == language,
                      label: copy.languageName(choice),
                      onPressed: () => onLanguage(choice),
                      flagBuilder: flagBuilder,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Country _mark(String code) {
  return Country(
    code: code,
    name: code,
    swedish: code,
    french: code,
    continent: 'Europe',
  );
}

class _LanguageFlag extends StatelessWidget {
  const _LanguageFlag({
    required this.language,
    required this.selected,
    required this.label,
    required this.onPressed,
    this.flagBuilder,
  });

  final QuizLanguage language;
  final bool selected;
  final String label;
  final VoidCallback onPressed;
  final FlagBuilder? flagBuilder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('language-${language.code}'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 96,
            height: 64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE7E1D8),
                width: selected ? 4 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.expand(
                child: FlagImage(
                  country: language.flagCountry,
                  builder: flagBuilder,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
