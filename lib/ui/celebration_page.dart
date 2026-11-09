import 'dart:math';

import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/game/session.dart';
import 'package:flutter/material.dart';

class CelebrationPage extends StatefulWidget {
  const CelebrationPage({
    super.key,
    required this.rating,
    required this.best,
    required this.isNewBest,
    required this.onPlayAgain,
  });

  final GameRating rating;
  final BestScore? best;
  final bool isNewBest;
  final VoidCallback onPlayAgain;

  @override
  State<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage>
    with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _confetti;
  late final Animation<double> _scale;
  late final List<_Bit> _bits;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scale = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
    );
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    final random = Random();
    _bits = List<_Bit>.generate(48, (_) => _Bit(random));
  }

  @override
  void dispose() {
    _pop.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rating = widget.rating;
    return Scaffold(
      key: const Key('celebration-screen'),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: const Icon(
                          Icons.emoji_events,
                          size: 96,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Well done',
                        key: const Key('well-done'),
                        textAlign: TextAlign.center,
                        style: text.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(rating.label, style: text.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '${rating.target} flags in ${rating.attempts} tries',
                        key: const Key('result'),
                        textAlign: TextAlign.center,
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: '${rating.stars} stars',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 1; i <= 5; i++)
                              Icon(
                                i <= rating.stars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFEAB308),
                                size: 36,
                              ),
                          ],
                        ),
                      ),
                      if (widget.isNewBest) ...[
                        const SizedBox(height: 12),
                        Text(
                          'New best',
                          key: const Key('new-best'),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else if (widget.best != null) ...[
                        const SizedBox(height: 12),
                        Text('Best game: ${widget.best!.attempts} tries'),
                      ],
                      const SizedBox(height: 32),
                      FilledButton(
                        key: const Key('play-again'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(220, 64),
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: widget.onPlayAgain,
                        child: const Text('New game'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      bits: _bits,
                      t: _confetti.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bit {
  _Bit(Random random)
      : color = _colors[random.nextInt(_colors.length)],
        dx = (random.nextDouble() - 0.5) * 2,
        velocity = 0.35 + random.nextDouble() * 0.7,
        spin = (random.nextDouble() - 0.5) * 8,
        size = 8 + random.nextDouble() * 10;

  static const _colors = [
    Color(0xFFEAB308),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF16A34A),
    Color(0xFFEA580C),
  ];

  final Color color;
  final double dx;
  final double velocity;
  final double spin;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.bits, required this.t});

  final List<_Bit> bits;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.22);
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final bit in bits) {
      final distance = bit.velocity * t * size.height;
      final pos = origin + Offset(bit.dx * distance * 0.85, distance * 0.95);
      final paint = Paint()..color = bit.color.withAlpha((fade * 255).round());
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(bit.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: bit.size,
            height: bit.size * 0.55,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
