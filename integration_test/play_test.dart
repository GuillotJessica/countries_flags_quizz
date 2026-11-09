import 'package:countries_flags_quizz/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a round keeps three whole flags on screen', (tester) async {
    app.main();
    await tester.pump();
    await _waitFor(tester, find.byKey(const Key('start-game')));

    await tester.tap(find.byKey(const Key('start-game')));
    await tester.pump();
    await _waitFor(tester, find.byKey(const Key('country-name')));
    await tester.pump(const Duration(seconds: 2));

    final squares = find.byType(AspectRatio);
    expect(squares, findsNWidgets(3));

    final view = tester.view.physicalSize / tester.view.devicePixelRatio;
    for (final element in squares.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final widget = element.widget as AspectRatio;
      expect(widget.aspectRatio, 1);
      expect(box.size.width, closeTo(box.size.height, 0.5));
      expect(box.size.shortestSide, greaterThanOrEqualTo(48));

      final origin = box.localToGlobal(Offset.zero);
      expect(origin.dx, greaterThanOrEqualTo(-0.5));
      expect(origin.dy, greaterThanOrEqualTo(-0.5));
      expect(origin.dx + box.size.width, lessThanOrEqualTo(view.width + 0.5));
      expect(
        origin.dy + box.size.height,
        lessThanOrEqualTo(view.height + 0.5),
      );
    }

    final name =
        tester.widget<Text>(find.byKey(const Key('country-name'))).data;
    await tester.tap(find.bySemanticsLabel('Flag of $name'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}
