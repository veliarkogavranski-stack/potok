# Поток / Flow

RSVP speed-reading app: words are shown one at a time at a fixed focal point, so your eyes never move. Built with Flutter, one screen, no accounts, works offline.

**Languages:** Russian, English, German, Polish (follows the system language).

## Features

- RSVP reading with an ORP (optimal recognition point) - the focus letter is always on the same axis
- Speed control: 100-1500 words per minute, live slider and seek bar with time elapsed / remaining
- Jump ±50 words, restart, reread-sentence (B), space = play/pause
- Outline view: builds a table of contents from short heading lines and `#` / `##` markup, tap to jump
- Font size 24-140, light/dark theme
- Reading progress is remembered per book and offered as "Resume"
- "My books" shelf on Android: opened books are copied to `Documents/My books`
- Formats: TXT, FB2, EPUB, DOCX, DOC, RTF, ODT, PDF, MOBI/AZW/AZW3/PRC

## Platforms

| Platform | Status |
| --- | --- |
| Android | APK (arm64 + armv7), tested |
| Windows | portable zip, tested |
| iOS | source ready, build needs macOS/Xcode |

## Build

```bash
flutter pub get
flutter build apk --release --target-platform android-arm64,android-arm
flutter build windows --release
```

## License

MIT - see [LICENSE](LICENSE).
