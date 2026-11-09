# Flag Quiz

A small flag game for a child. It is meant to be played on an iPad, and it also runs on Android and in a browser.

A round shows a country name and three flags. The round ends at 5 correct answers. A wrong tap stays in the round, and the score is how many tries those 5 answers took. Fewer tries is a better game. A perfect round is 5 tries.

The menu has flag buttons for English, Swedish, and French. Country names and the words on screen follow that choice. The language and the best score stay on the device.

![Flag Quiz home](screenshots/home.png)

A wrong flag stays on screen long enough to see the right one, outlined in green.

![A round in progress](screenshots/play.png)

![Well done](screenshots/well-done.png)

## Score

| Tries | Rating |
| --- | --- |
| 5 | Perfect, 5 stars |
| 6 | Great, 4 stars |
| 7–8 | Good, 3 stars |
| 9–11 | Nice work, 2 stars |
| 12 or more | You did it, 1 star |

Stopping a round does not save a score. The best game is the fewest tries, shown on the menu.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (this project was built with 3.47)
- A network connection during a round. The country list is bundled. The flag pictures come from [flagcdn.com](https://flagcdn.com)

## Start

```sh
flutter pub get
flutter devices
```

On the iPad simulator:

```sh
open -a Simulator
flutter run
```

If more than one device is listed, pick it:

```sh
flutter run -d "iPad Pro 13-inch (M5)"
```

On Android, start an emulator or plug in a phone. `flutter devices` lists it. Start the app with `flutter run -d <device-id>`.

In a browser:

```sh
flutter run -d chrome
```

On a physical iPad, connect it with a cable, unlock it, and trust the computer. Then run `flutter devices` and `flutter run -d <device-id>`.

## Test

```sh
flutter analyze
flutter test
```

`flutter test` covers the round rules, the saved score, a full game from Start to the well-done screen, the language buttons, and the flag layout on an iPad in portrait and landscape and in a 1440×900 browser window.

A round can also be played on a booted iPad simulator:

```sh
flutter test integration_test/play_test.dart -d "iPad Pro 13-inch (M5)"
```

Chrome cannot run that device test. The browser layout is covered by `flutter test`.

## Project layout

| Path | What it is |
| --- | --- |
| `lib/game` | Round rules. No Flutter imports. |
| `lib/ui` | Menu, play, and well-done screens. |
| `lib/data` | Country list, best score, and language. |
| `assets/countries.json` | Countries, with English, Swedish, and French names. |
| `integration_test` | One round on a booted iPad simulator. |

## License

[MIT](LICENSE) © 2026 Jessica Guillot
