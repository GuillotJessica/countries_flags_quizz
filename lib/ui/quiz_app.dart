import 'dart:async';
import 'dart:math';

import 'package:countries_flags_quizz/data/country_repository.dart';
import 'package:countries_flags_quizz/data/score_store.dart';
import 'package:countries_flags_quizz/game/question.dart';
import 'package:countries_flags_quizz/game/session.dart';
import 'package:countries_flags_quizz/models/country.dart';
import 'package:countries_flags_quizz/ui/celebration_page.dart';
import 'package:countries_flags_quizz/ui/flag_image.dart';
import 'package:countries_flags_quizz/ui/home_page.dart';
import 'package:countries_flags_quizz/ui/play_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizApp extends StatefulWidget {
  const QuizApp({
    super.key,
    this.countries,
    this.scoreStore,
    this.random,
    this.feedbackDelay = const Duration(milliseconds: 900),
    this.flagBuilder,
  });

  final List<Country>? countries;
  final ScoreStore? scoreStore;
  final Random? random;
  final Duration feedbackDelay;
  final FlagBuilder? flagBuilder;

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late final Random _random;
  late final ScoreStore _scores;

  var _stage = _Stage.loading;
  List<Country> _countries = const [];
  GameSnapshot? _game;
  GameRating? _rating;
  BestScore? _best;
  var _improved = false;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? Random();
    _scores = widget.scoreStore ?? PrefsScoreStore();
    _load();
  }

  Future<void> _load() async {
    if (mounted && _stage != _Stage.loading) {
      setState(() => _stage = _Stage.loading);
    }
    try {
      final countries = widget.countries ?? await loadCountries();
      final best = await _scores.readBest();
      if (!mounted) return;
      if (countries.length < choicesPerQuestion) {
        setState(() => _stage = _Stage.error);
        return;
      }
      setState(() {
        _countries = countries;
        _best = best;
        _stage = _Stage.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _stage = _Stage.error);
    }
  }

  void _start() {
    setState(() {
      _game = startGame(_countries, _random);
      _rating = null;
      _improved = false;
      _stage = _Stage.playing;
    });
  }

  void _stop() {
    setState(() {
      _game = null;
      _stage = _Stage.ready;
    });
  }

  Future<void> _pick(String code) async {
    final game = _game;
    if (game == null || game.isRevealing || game.isComplete) {
      return;
    }
    final revealed = revealAnswer(game, code);
    setState(() => _game = revealed);
    unawaited(_haptic(revealed.pickedTheRightFlag));
    await Future<void>.delayed(widget.feedbackDelay);
    if (!mounted || _game != revealed) {
      return;
    }
    if (revealed.isComplete) {
      final rating = rateGame(revealed);
      final saved = await _save(rating);
      if (!mounted) return;
      setState(() {
        _rating = rating;
        _best = saved.best;
        _improved = saved.improved;
        _stage = _Stage.celebrating;
      });
      return;
    }
    setState(() {
      _game = advanceGame(revealed, _countries, _random);
    });
  }

  Future<void> _haptic(bool correct) async {
    try {
      if (correct) {
        await HapticFeedback.lightImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      // The round still moves on if the device has no haptics channel.
    }
  }

  Future<SavedScore> _save(GameRating rating) async {
    try {
      return await _scores.saveIfBetter(rating);
    } catch (_) {
      return SavedScore(
        best: _best ??
            BestScore(attempts: rating.attempts, target: rating.target),
        improved: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flag Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
          headlineMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
          headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      home: switch (_stage) {
        _Stage.loading => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        _Stage.error => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('The country list could not be loaded.'),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: _load, child: const Text('Try again')),
                ],
              ),
            ),
          ),
        _Stage.ready => HomePage(onStart: _start, best: _best),
        _Stage.playing => PlayPage(
            game: _game!,
            onPick: _pick,
            onStop: _stop,
            flagBuilder: widget.flagBuilder,
          ),
        _Stage.celebrating => CelebrationPage(
            rating: _rating!,
            best: _best,
            isNewBest: _improved,
            onPlayAgain: _start,
          ),
      },
    );
  }
}

enum _Stage { loading, error, ready, playing, celebrating }
