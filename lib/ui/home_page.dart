import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onStart, this.best});

  final VoidCallback onStart;
  final BestScore? best;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      key: const Key('home-screen'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(
                    child: Text('🇫🇷   🇧🇷   🇯🇵',
                        style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Flag Quiz',
                    textAlign: TextAlign.center,
                    style: text.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Find 5 flags. Fewer tries makes a better game.',
                    textAlign: TextAlign.center,
                    style: text.titleLarge,
                  ),
                  if (best != null) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Best game: ${best!.attempts} tries',
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
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
