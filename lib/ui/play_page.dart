import 'package:countries_flags_quizz/game/session.dart';
import 'package:countries_flags_quizz/language.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/flag_image.dart';
import 'package:flutter/material.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({
    super.key,
    required this.copy,
    required this.game,
    required this.onPick,
    required this.onStop,
    this.flagBuilder,
  });

  final QuizCopy copy;
  final GameSnapshot game;
  final ValueChanged<String> onPick;
  final VoidCallback onStop;
  final FlagBuilder? flagBuilder;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final prompt = game.question.prompt;
    return Scaffold(
      key: const Key('play-screen'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    key: const Key('stop-game'),
                    onPressed: onStop,
                    child: Text(copy.stop),
                  ),
                  const Spacer(),
                  Text(
                    copy.tries(game.attempts),
                    key: const Key('tries'),
                    style: text.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _Progress(correct: game.correct, target: game.target),
              const SizedBox(height: 12),
              Text(copy.whichFlag, style: text.titleMedium),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    prompt.nameIn(copy.language),
                    key: const Key('country-name'),
                    textAlign: TextAlign.center,
                    style: text.headlineMedium,
                  ),
                ),
              ),
              if (game.isRevealing) ...[
                const SizedBox(height: 8),
                Text(
                  game.pickedTheRightFlag ? copy.yes : copy.lookAtTheGreenOne,
                  key: const Key('feedback'),
                  style: text.titleLarge?.copyWith(
                    color: game.pickedTheRightFlag
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: SizedBox.expand(
                      child: _Choices(
                        copy: copy,
                        game: game,
                        onPick: onPick,
                        flagBuilder: flagBuilder,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.correct, required this.target});

  final int correct;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$correct/$target',
          key: const Key('progress'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(width: 12),
        for (var i = 0; i < target; i++)
          Icon(
            i < correct ? Icons.star : Icons.star_border,
            key: Key('progress-star-$i'),
            color: const Color(0xFFEAB308),
            size: 28,
          ),
      ],
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.copy,
    required this.game,
    required this.onPick,
    this.flagBuilder,
  });

  final QuizCopy copy;
  final GameSnapshot game;
  final ValueChanged<String> onPick;
  final FlagBuilder? flagBuilder;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final flags = [
          for (final country in game.question.choices)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _FlagChoice(
                      country: country,
                      game: game,
                      copy: copy,
                      onPick: onPick,
                      flagBuilder: flagBuilder,
                    ),
                  ),
                ),
              ),
            ),
        ];
        if (orientation == Orientation.landscape) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: flags,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: flags,
        );
      },
    );
  }
}

class _FlagChoice extends StatelessWidget {
  const _FlagChoice({
    required this.country,
    required this.game,
    required this.copy,
    required this.onPick,
    this.flagBuilder,
  });

  final Country country;
  final GameSnapshot game;
  final QuizCopy copy;
  final ValueChanged<String> onPick;
  final FlagBuilder? flagBuilder;

  @override
  Widget build(BuildContext context) {
    final isPrompt = country.code == game.question.prompt.code;
    final isPicked = country.code == game.pickedCode;
    var border = Colors.transparent;
    if (game.isRevealing && isPrompt) {
      border = const Color(0xFF15803D);
    } else if (game.isRevealing && isPicked) {
      border = const Color(0xFFDC2626);
    }

    return Semantics(
      button: true,
      label: copy.flagOf(country.nameIn(copy.language)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: Colors.white,
            child: InkWell(
              key: Key('flag-${country.code}'),
              onTap: game.isRevealing ? null : () => onPick(country.code),
              child: SizedBox.expand(
                child: FlagImage(country: country, builder: flagBuilder),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
