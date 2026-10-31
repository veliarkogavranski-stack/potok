// «Поток» - MVP скорочтения (RSVP). Один файл, без внешних пакетов.
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

// ---- Локализация: ru / en / de / pl (язык системы, запас - русский) ----

String _detectedLang() {
  final raw = Platform.localeName.toLowerCase();
  for (final l in ['en', 'de', 'pl', 'ru']) {
    if (raw.startsWith(l)) return l;
  }
  return 'ru';
}

const Map<String, String> _trRu = {
  'appName': 'Поток',
  'continueTitle': 'ПРОДОЛЖИТЬ ЧТЕНИЕ',
  'emptyList': 'Список пуст.',
  'word': 'слово',
  'of': 'из',
  'hint': 'Вставь книгу, статью, любой текст или перетащи файл...',
  'read': 'Читать',
  'pickOrPaste': 'Выбери книгу или вставь текст',
  'openFile': 'Открыть файл...',
  'myBooks': 'Мои книги',
  'resume': 'Продолжить',
  'readError': 'Не удалось прочитать файл',
  'noText': 'В файле не найден читаемый текст (возможно, скан или бинарный формат)',
  'fileNotFound': 'Файл не найден',
  'pastedText': 'Вставленный текст',
  'author': 'Автор',
  'pathUnavailable': 'Путь недоступен (вставленный текст)',
  'close': 'Закрыть',
  'fwd50': 'вперёд 50',
  'back50': '50 назад',
  'wpmUnit': 'слов/мин',
  'words': 'слов',
  'ttToStart': 'В начало',
  'ttBack50': '50 слов назад',
  'ttPlay': 'Пуск/пауза (пробел)',
  'ttFwd50': '50 слов вперёд',
  'ttOverview': 'Страница-обзор',
  'ttReread': 'Перечитать предложение (B)',
  'ttFont': 'Размер шрифта',
  'ttTheme': 'Тема',
  'ttExit': 'Выход (Esc)',
  'fontTitle': 'Размер шрифта',
  'done': 'Готово',
  'sessionDone': 'Сессия завершена',
  'wordsRead': 'Слов прочитано',
  'time': 'Время',
  'secShort': 'с',
  'minShort': 'мин',
  'avgSpeed': 'Средняя скорость',
  'outline': 'Оглавление',
  'sections': 'разделов',
  'noHeadings': 'Заголовков в этом тексте не нашла.\n'
      'Оглавление строится из коротких строк-заголовков\n'
      'и разметки вида # или ##.',
  'kb': 'КБ',
  'mb': 'МБ',
  'refresh': 'Обновить',
  'accessNeeded': 'Чтобы «Поток» видел твои книги, дай ему доступ к файлам телефона.\n'
      'Без этого системный выбор файлов не показывает .fb2 — тип файла ему неизвестен.',
  'grantAccess': 'Разрешить доступ',
  'checkAgain': 'Проверить снова',
  'noBooks': 'Книг не нашлось.\nПоложи файл (.fb2, .txt, .epub, .docx, .doc, .rtf, .odt, .pdf, .mobi, .azw3) в папку «Загрузки» или «Документы» и нажми «Обновить».',
};

const Map<String, String> _trEn = {
  'appName': 'Flow',
  'continueTitle': 'RESUME READING',
  'emptyList': 'List is empty.',
  'word': 'word',
  'of': 'of',
  'hint': 'Paste a book, an article, any text, or drop a file here...',
  'read': 'Read',
  'pickOrPaste': 'Pick a book or paste text',
  'openFile': 'Open file...',
  'myBooks': 'My books',
  'resume': 'Resume',
  'readError': 'Could not read the file',
  'noText': 'No readable text found in the file (maybe a scan or a binary format)',
  'fileNotFound': 'File not found',
  'pastedText': 'Pasted text',
  'author': 'Author',
  'pathUnavailable': 'Path unavailable (pasted text)',
  'close': 'Close',
  'fwd50': 'forward 50',
  'back50': 'back 50',
  'wpmUnit': 'wpm',
  'words': 'words',
  'ttToStart': 'To start',
  'ttBack50': '50 words back',
  'ttPlay': 'Play/pause (space)',
  'ttFwd50': '50 words forward',
  'ttOverview': 'Outline',
  'ttReread': 'Reread sentence (B)',
  'ttFont': 'Font size',
  'ttTheme': 'Theme',
  'ttExit': 'Exit (Esc)',
  'fontTitle': 'Font size',
  'done': 'Done',
  'sessionDone': 'Session complete',
  'wordsRead': 'Words read',
  'time': 'Time',
  'secShort': 's',
  'minShort': 'min',
  'avgSpeed': 'Average speed',
  'outline': 'Outline',
  'sections': 'sections',
  'noHeadings': 'No headings found in this text.\n'
      'The outline is built from short heading lines\n'
      'and # or ## markup.',
  'kb': 'KB',
  'mb': 'MB',
  'refresh': 'Refresh',
  'accessNeeded': 'To let Flow see your books, give it access to phone files.\n'
      'Otherwise the system file picker hides .fb2 — it does not know the type.',
  'grantAccess': 'Allow access',
  'checkAgain': 'Check again',
  'noBooks': 'No books found.\nPut a file (.fb2, .txt, .epub, .docx, .doc, .rtf, .odt, .pdf, .mobi, .azw3) into Downloads or Documents and tap Refresh.',
};

const Map<String, String> _trDe = {
  'appName': 'Flow',
  'continueTitle': 'WEITERLESEN',
  'emptyList': 'Liste ist leer.',
  'word': 'Wort',
  'of': 'von',
  'hint': 'Buch, Artikel, beliebigen Text einfügen oder Datei hierher ziehen...',
  'read': 'Lesen',
  'pickOrPaste': 'Buch wählen oder Text einfügen',
  'openFile': 'Datei öffnen...',
  'myBooks': 'Meine Bücher',
  'resume': 'Weiter',
  'readError': 'Datei konnte nicht gelesen werden',
  'noText': 'Keine lesbare Schrift in der Datei gefunden (vielleicht Scan oder Binärformat)',
  'fileNotFound': 'Datei nicht gefunden',
  'pastedText': 'Eingefügter Text',
  'author': 'Autor',
  'pathUnavailable': 'Pfad nicht verfügbar (eingefügter Text)',
  'close': 'Schließen',
  'fwd50': 'vor 50',
  'back50': '50 zurück',
  'wpmUnit': 'Wörter/Min',
  'words': 'Wörter',
  'ttToStart': 'Zum Anfang',
  'ttBack50': '50 Wörter zurück',
  'ttPlay': 'Start/Pause (Leertaste)',
  'ttFwd50': '50 Wörter vor',
  'ttOverview': 'Übersicht',
  'ttReread': 'Satz nochmal lesen (B)',
  'ttFont': 'Schriftgröße',
  'ttTheme': 'Design',
  'ttExit': 'Beenden (Esc)',
  'fontTitle': 'Schriftgröße',
  'done': 'Fertig',
  'sessionDone': 'Sitzung beendet',
  'wordsRead': 'Gelesene Wörter',
  'time': 'Zeit',
  'secShort': 's',
  'minShort': 'Min',
  'avgSpeed': 'Durchschnittstempo',
  'outline': 'Inhalt',
  'sections': 'Abschnitte',
  'noHeadings': 'Keine Überschriften in diesem Text gefunden.\n'
      'Das Inhaltsverzeichnis entsteht aus kurzen Überschriftenzeilen\n'
      'und # oder ## Auszeichnung.',
  'kb': 'KB',
  'mb': 'MB',
  'refresh': 'Aktualisieren',
  'accessNeeded': 'Damit Flow deine Bücher sieht, gib ihm Zugriff auf die Handyaldateien.\n'
      'Ohne das verbirgt der Systemdateidialog .fb2 — der Typ ist ihm unbekannt.',
  'grantAccess': 'Zugriff erlauben',
  'checkAgain': 'Erneut prüfen',
  'noBooks': 'Keine Bücher gefunden.\nLege eine Datei (.fb2, .txt, .epub, .docx, .doc, .rtf, .odt, .pdf, .mobi, .azw3) in Downloads oder Dokumente und tippe auf Aktualisieren.',
};

const Map<String, String> _trPl = {
  'appName': 'Flow',
  'continueTitle': 'KONTYNUUJ CZYTANIE',
  'emptyList': 'Lista jest pusta.',
  'word': 'słowo',
  'of': 'z',
  'hint': 'Wklej książkę, artykuł, dowolny tekst albo przeciągnij plik...',
  'read': 'Czytaj',
  'pickOrPaste': 'Wybierz książkę lub wklej tekst',
  'openFile': 'Otwórz plik...',
  'myBooks': 'Moje książki',
  'resume': 'Kontynuuj',
  'readError': 'Nie udało się odczytać pliku',
  'noText': 'Nie znaleziono czytelnego tekstu w pliku (może skan lub format binarny)',
  'fileNotFound': 'Nie znaleziono pliku',
  'pastedText': 'Wklejony tekst',
  'author': 'Autor',
  'pathUnavailable': 'Ścieżka niedostępna (wklejony tekst)',
  'close': 'Zamknij',
  'fwd50': 'do przodu 50',
  'back50': '50 do tyłu',
  'wpmUnit': 'słów/min',
  'words': 'słów',
  'ttToStart': 'Do początku',
  'ttBack50': '50 słów do tyłu',
  'ttPlay': 'Start/pauza (spacja)',
  'ttFwd50': '50 słów do przodu',
  'ttOverview': 'Spis treści',
  'ttReread': 'Przeczytaj zdanie ponownie (B)',
  'ttFont': 'Rozmiar czcionki',
  'ttTheme': 'Motyw',
  'ttExit': 'Wyjście (Esc)',
  'fontTitle': 'Rozmiar czcionki',
  'done': 'Gotowe',
  'sessionDone': 'Sesja zakończona',
  'wordsRead': 'Przeczytane słowa',
  'time': 'Czas',
  'secShort': 's',
  'minShort': 'min',
  'avgSpeed': 'Średnia prędkość',
  'outline': 'Spis treści',
  'sections': 'sekcji',
  'noHeadings': 'Nie znalazłam nagłówków w tym tekście.\n'
      'Spis treści buduje się z krótkich linii-nagłówków\n'
      'i znaczników # lub ##.',
  'kb': 'KB',
  'mb': 'MB',
  'refresh': 'Odśwież',
  'accessNeeded': 'Aby Flow widział twoje książki, daj mu dostęp do plików telefonu.\n'
      'Bez tego systemowy wybór plików nie pokazuje .fb2 — nie zna tego typu.',
  'grantAccess': 'Zezwól na dostęp',
  'checkAgain': 'Sprawdź ponownie',
  'noBooks': 'Nie znaleziono książek.\nPołóż plik (.fb2, .txt, .epub, .docx, .doc, .rtf, .odt, .pdf, .mobi, .azw3) do folderu Pobrane lub Dokumenty i naciśnij Odśwież.',
};

final String Function(String) tr = () {
  const langs = {'ru': _trRu, 'en': _trEn, 'de': _trDe, 'pl': _trPl};
  final m = langs[_detectedLang()] ?? _trRu;
  return (String key) => m[key] ?? _trRu[key] ?? key;
}();

// ---- Файлы на телефоне (мост к MainActivity, только Android) ----


const MethodChannel _storageChannel = MethodChannel('potok/storage');

String? _dataDirOverride;

Future<bool> androidHasAccess() async {
  try {
    return await _storageChannel.invokeMethod<bool>('hasAccess') ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> androidRequestAccess() async {
  try {
    await _storageChannel.invokeMethod('requestAccess');
  } catch (_) {
    // нет канала - не Android, просто ничего не делаем
  }
}

Future<List<Map<String, dynamic>>> androidListFiles() async {
  try {
    final raw = await _storageChannel.invokeMethod<List<dynamic>>('listFiles');
    return (raw ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  } catch (_) {
    return const [];
  }
}

/// Сложить книгу на полку Документы/Поток; вернуть путь к копии или null.
Future<String?> androidImportBook(String path) async {
  try {
    return await _storageChannel.invokeMethod<String>('importBook', path);
  } catch (_) {
    return null;
  }
}

// ---- Память чтения: история файлов и места остановки ----

String _histDir() {
  if (_dataDirOverride != null) return _dataDirOverride!;
  final appdata = Platform.environment['APPDATA'];
  return '${appdata ?? '.'}\\potok';
}

String _histPath() => '${_histDir()}\\history.json';

Map<String, dynamic> loadHistory() {
  try {
    final f = File(_histPath());
    if (!f.existsSync()) return {'items': <dynamic>[]};
    final decoded = jsonDecode(f.readAsStringSync());
    if (decoded is List) return {'items': decoded};
    if (decoded is Map<String, dynamic>) return decoded;
    return {'items': <dynamic>[]};
  } catch (_) {
    return {'items': <dynamic>[]};
  }
}

void saveHistory(Map<String, dynamic> h) {
  try {
    final dir = Directory(_histDir());
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File(_histPath()).writeAsStringSync(jsonEncode(h));
  } catch (_) {
    // Память - не критичный путь: не умеем сохранить, читаем дальше.
  }
}

/// Записать/обновить запись о месте остановки. Вызывается из читалки.
void rememberProgress({
  required String kind,
  String? path,
  String? text,
  required String title,
  required int index,
  required int total,
  required double wpm,
  required double fontSize,
}) {
  final h = loadHistory();
  final items = (h['items'] as List?) ?? [];
  items.removeWhere((e) =>
      e is Map && (path != null ? e['path'] == path : e['text'] == text));
  final storedText =
      text == null ? null : (text.length > 200000 ? text.substring(0, 200000) : text);
  items.insert(0, {
    'kind': kind,
    'path': ?path,
    'text': ?storedText,
    'title': title,
    'index': index,
    'total': total,
    'wpm': wpm,
    'fontSize': fontSize,
    'ts': DateTime.now().toIso8601String(),
  });
  while (items.length > 10) {
    items.removeLast();
  }
  h['items'] = items;
  saveHistory(h);
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Тестовый режим: potok.exe --demo открывает читалку сразу с демо-текстом.
  final demo = args.contains('--demo');
  if (Platform.isAndroid) {
    try {
      final dir = await _storageChannel.invokeMethod<String>('dataDir');
      if (dir != null && dir.isNotEmpty) _dataDirOverride = dir;
    } catch (_) {
      // Канал недоступен - история просто не сохранится, чтение работает.
    }
  }
  runApp(PotokApp(demoText: demo ? _demoText : null));
}

const String _demoText =
    'Скорочтение это навык читать быстрее без потери понимания смысла. '
    'Текст подаётся по одному слову, глаза остаются на месте. '
    'Красная буква в центре слова это точка распознавания, она всегда на одной оси. \n\n'
    'Вместо движений глаз по строке слово само приходит в центр зрения. '
    'Знаки препинания дают паузы, длинные слова держатся чуть дольше. ';

class PotokApp extends StatelessWidget {
  final String? demoText;
  const PotokApp({super.key, this.demoText});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: tr('appName'),
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        themeMode: ThemeMode.dark,
        home: demoText != null
            ? ReaderScreen(text: _buildDemoText(demoText!), autoplay: true)
            : const HomeScreen(),
      );
}

// Демо-книга: нумерованные главы на базе демо-абзаца, чтобы оглавление было живым.
String _buildDemoText(String paragraph) {
  const titles = [
    'Точка распознавания', 'Как это работает', 'Ритм и паузы',
    'Скорость и понимание', 'Привычка глаза', 'Практика каждый день',
  ];
  final sb = StringBuffer();
  for (var i = 0; i < titles.length; i++) {
    sb.write('# Глава ${i + 1}. ${titles[i]}\n\n');
    sb.write(paragraph);
    sb.write('\n\n');
  }
  return sb.toString();
}

// ---- Разбор текста ----

class Chunk {
  final String word;
  final int orpIndex;
  final double delayFactor;
  const Chunk(this.word, this.orpIndex, this.delayFactor);
}

int _orp(String w) =>
    w.isEmpty ? 0 : ((w.length * 0.4).floor()).clamp(0, w.length - 1);

bool _isNumericLike(String w) => RegExp(r'\d').hasMatch(w);

bool _isAbbrev(String w) {
  final clean = w.replaceAll(RegExp(r'[.,!?"()\-]'), '');
  if (clean.length <= 1) return true;
  if (clean == clean.toUpperCase() &&
      RegExp(r'^[А-ЯЁA-Z]{2,4}$').hasMatch(clean)) {
    return true;
  }
  return false;
}

List<Chunk> parseText(String text, int chunkSize) {
  final chunks = <Chunk>[];
  final paragraphs = text.split(RegExp(r'\n\s*\n'));
  final sentenceEnd = RegExp(r'[.!?…]["»)\]]?$');
  final clauseEnd = RegExp(r'[,;:—–-]["»)\]]?$');
  for (final para in paragraphs) {
    final words =
        para.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    for (var i = 0; i < words.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, words.length);
      final group = words.sublist(i, end);
      final joined = group.join(' ');
      var f = 1.0;
      final last = group.last;
      if (sentenceEnd.hasMatch(last)) {
        f = 2.5;
      } else if (clauseEnd.hasMatch(last)) {
        f = 1.5;
      }
      if (end >= words.length) f = f < 3 ? 3 : f;
      if (joined.length > 13) f += 1.0;
      if (_isNumericLike(joined) || _isAbbrev(joined)) f += 0.8;
      chunks.add(Chunk(joined, _orp(joined), f));
    }
  }
  return chunks;
}

// ---- Экран ввода ----

// ---- Извлечение текста из файлов ----

String extractTxt(String path) {
  final bytes = File(path).readAsBytesSync();
  // UTF-8 с BOM, строгий UTF-8, потом Windows-1251 (обычный русский txt).
  if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3), allowMalformed: true);
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return cp1251Decode(bytes);
  }
}

/// Windows-1251: Cyrillic А-я = 0xC0-0xFF, Ё/ё = 0xA8/0xB8, остальное - похожие латыни.
String cp1251Decode(List<int> b) {
  const table = [
    0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021,
    0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
    0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
    0x0000, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
    0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7,
    0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
    0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7,
    0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
  ];
  final sb = StringBuffer();
  for (final byte in b) {
    if (byte < 0x80) {
      sb.writeCharCode(byte);
    } else if (byte >= 0xC0) {
      sb.writeCharCode(0x0410 + (byte - 0xC0));
    } else if (byte >= 0xA0) {
      sb.writeCharCode(table[byte - 0xA0]);
    } else {
      sb.writeCharCode(byte);
    }
  }
  return sb.toString();
}

String extractFb2(String path) {
  final bytes = File(path).readAsBytesSync();
  var raw = _decodeFb2Bytes(bytes);
  // Декларацию убираем: дальше это уже Dart-строка (UTF-16), объявление только сбивает парсер.
  raw = raw.replaceFirst(RegExp(r'^\s*<\?xml[^>]*\?>'), '');
  final sb = StringBuffer();
  try {
    final doc = XmlDocument.parse(_sanitizeXml(raw));
    for (final el in doc.descendantElements) {
      final name = el.name.local.toLowerCase();
      if (_insideTitle(el)) continue; // содержимое заголовка выводим целиком, без дублей
      if (name == 'p' || name == 'v' || name == 'text-author' || name == 'cite') {
        final t = el.innerText.trim();
        if (t.isNotEmpty) sb.writeln(t);
        sb.writeln();
      } else if (name == 'title' || name == 'subtitle') {
        // Внутри заголовка бывает несколько p/subtitle — выводим их построчно,
        // иначе получается «Глава перваяНачало».
        final parts = el.children
            .whereType<XmlElement>()
            .map((c) => c.innerText.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (parts.isEmpty) {
          final t = el.innerText.trim();
          if (t.isNotEmpty) {
            sb.writeln(t);
            sb.writeln();
          }
        } else {
          for (final p in parts) {
            sb.writeln(p);
          }
          sb.writeln();
        }
      } else if (name == 'empty-line') {
        sb.writeln();
      }
    }
  } catch (_) {
    // Битый или нестандартный fb2: достаём текст тегами, без XML-разбора.
    // Лучше открыть книгу с лишними пробелами, чем не открыть вовсе.
    return _fb2Fallback(raw);
  }
  final out = sb.toString().trim();
  if (out.isEmpty) return _fb2Fallback(raw);
  return out;
}

bool _insideTitle(XmlElement el) {
  for (final a in el.ancestors.whereType<XmlElement>()) {
    final n = a.name.local.toLowerCase();
    if (n == 'title' || n == 'subtitle') return true;
  }
  return false;
}

/// Чистка под XML: в библиотечных fb2 часто встречаются html-сущности (&nbsp;, &mdash;)
/// и одинокие амперсанды — на них разбор падает с «не удалось прочитать файл».
String _sanitizeXml(String x) {
  var t = x.replaceAll('&nbsp;', '\u00A0').replaceAll('&#160;', '\u00A0');
  t = t.replaceAllMapped(RegExp(r'&([a-zA-Z][a-zA-Z0-9]{1,10});'), (m) {
    final n = m.group(1)!;
    const known = {'amp', 'lt', 'gt', 'quot', 'apos'};
    if (known.contains(n)) return m.group(0)!;
    const named = {
      'mdash': '—', 'ndash': '–', 'hellip': '…', 'laquo': '«', 'raquo': '»',
      'lsquo': '‘', 'rsquo': '’', 'ldquo': '“', 'rdquo': '”', 'copy': '©',
      'reg': '®', 'deg': '°', 'times': '×', 'divide': '÷', 'plusmn': '±',
    };
    return named[n] ?? '';
  });
  t = t.replaceAllMapped(
      RegExp(r'&(?!(#\d+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]{1,10});)'), (m) => '&amp;');
  return t;
}

/// Кодировка fb2: сначала строгий UTF-8 (если проходит — файл действительно utf-8,
/// даже когда в декларации написано другое), иначе Windows-1251.
String _decodeFb2Bytes(List<int> bytes) {
  try {
    var s = utf8.decode(bytes);
    if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) s = s.substring(1);
    return s;
  } on FormatException {
    return cp1251Decode(bytes);
  }
}

String _fb2Fallback(String raw) {
  var t = raw.replaceAll(
      RegExp(r'<binary[\s\S]*?</binary>', caseSensitive: false), ' ');
  t = t.replaceAll(RegExp(r'<empty-line\s*/?>', caseSensitive: false), '\n');
  t = t.replaceAll(
      RegExp(r'</(p|title|subtitle|section|v|stanza|epigraph|poem|cite|annotation|text-author)\s*>',
          caseSensitive: false),
      '\n');
  t = t.replaceAll(RegExp(r'<[^>]*>'), '');
  t = t
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)))
      .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)))
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return (t.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).join('\n')).trim();
}

/// epub = zip с xhtml-главами в META-INF/container.xml -> OPF -> spine.
Future<String> extractEpub(String path) async {
  final bytes = await File(path).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  final container = archive.findFile('META-INF/container.xml');
  if (container == null) throw const FormatException('не epub');
  final containerDoc = XmlDocument.parse(utf8.decode(container.content as List<int>, allowMalformed: true));
  final opfPath = containerDoc
      .findAllElements('rootfile')
      .map((e) => e.getAttribute('full-path') ?? '')
      .firstWhere((s) => s.isNotEmpty, orElse: () => throw const FormatException('нет rootfile'));
  final opfFile = archive.findFile(opfPath);
  if (opfFile == null) throw const FormatException('нет OPF');
  final opfDir = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';
  final opfDoc = XmlDocument.parse(utf8.decode(opfFile.content as List<int>, allowMalformed: true));
  final manifest = <String, String>{};
  for (final item in opfDoc.findAllElements('item')) {
    final id = item.getAttribute('id');
    final href = item.getAttribute('href');
    if (id != null && href != null) manifest[id] = href;
  }
  final sb = StringBuffer();
  for (final ref in opfDoc.findAllElements('itemref')) {
    final idref = ref.getAttribute('idref');
    final href = idref == null ? null : manifest[idref];
    if (href == null) continue;
    final f = archive.findFile('$opfDir$href'.replaceAll('\\', '/'));
    if (f == null) continue;
    final html = utf8.decode(f.content as List<int>, allowMalformed: true);
    sb.writeln(_htmlToText(html));
    sb.writeln();
  }
  return sb.toString();
}

/// docx = zip со word/document.xml; параграф w:p.
Future<String> extractDocx(String path) async {
  final bytes = await File(path).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  final f = archive.findFile('word/document.xml');
  if (f == null) throw const FormatException('не docx');
  final doc = XmlDocument.parse(utf8.decode(f.content as List<int>, allowMalformed: true));
  final sb = StringBuffer();
  for (final p in doc.findAllElements('w:p')) {
    final line = p.findAllElements('w:t').map((t) => t.innerText).join();
    if (line.trim().isNotEmpty) sb.writeln(line);
  }
  return sb.toString();
}

/// PDF: на ПК внешний pdftotext.exe (poppler), иначе dart-пакет (Android и запас).
Future<String> extractPdf(String path) async {
  if (Platform.isWindows) {
    final candidates = [
      '${File(Platform.resolvedExecutable).parent.path}\\pdftotext.exe',
      '${Directory.current.path}\\pdftotext.exe',
    ];
    final exe = candidates.firstWhere((e) => File(e).existsSync(),
        orElse: () => '');
    if (exe.isNotEmpty) {
      final r = await Process.run(exe, ['-enc', 'UTF-8', path, '-'],
          stdoutEncoding: utf8);
      if (r.exitCode == 0) return r.stdout as String;
    }
  }
  final bytes = await File(path).readAsBytes();
  final doc = PdfDocument(inputBytes: bytes);
  try {
    return PdfTextExtractor(doc).extractText();
  } finally {
    doc.dispose();
  }
}

/// ODT: zip, текст из content.xml (абзацы text:p и заголовки text:h).
Future<String> extractOdt(String path) async {
  final bytes = await File(path).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  final f = archive.findFile('content.xml');
  if (f == null) throw const FormatException('не odt');
  final doc = XmlDocument.parse(utf8.decode(f.content as List<int>, allowMalformed: true));
  final sb = StringBuffer();
  for (final el in doc.descendantElements) {
    final name = el.name.local;
    if ((name == 'p' || name == 'h') && el.name.qualified == 'text:$name') {
      final line = el.innerText.trim();
      if (line.isNotEmpty) sb.writeln(line);
    }
  }
  return sb.toString();
}

/// RTF: грубый разбор - управление вон, \par/\line -> абзацы, \'hh и \uN -> текст.
String extractRtf(String path) {
  final s = latin1.decode(File(path).readAsBytesSync());
  final skipGroups = {'fonttbl', 'colortbl', 'stylesheet', 'info', 'pict',
      'header', 'footer', 'generator', 'listtable', 'listoverridetable'};
  final out = StringBuffer();
  var i = 0;
  // Для каждой открытой группы: пропускать ли её содержимое.
  final skip = <bool>[];
  while (i < s.length) {
    final c = s[i];
    if (c == '{') {
      // Решаем по началу группы: {\*\...} или {\fonttbl...} - пропускаем.
      final head = s.substring(i, (i + 40).clamp(0, s.length));
      final m = RegExp(r'^\{\\\*?\\?([a-zA-Z]+)').firstMatch(head);
      final kw = m?.group(1);
      skip.add(skip.isNotEmpty
          ? skip.last || kw != null && (head.startsWith(r'{\*') || skipGroups.contains(kw))
          : kw != null && (head.startsWith(r'{\*') || skipGroups.contains(kw)));
      i++;
    } else if (c == '}') {
      if (skip.isNotEmpty) skip.removeLast();
      i++;
    } else if (skip.isNotEmpty && skip.last) {
      i++;
    } else if (c == '\\') {
      final m = RegExp(r'^\\([a-zA-Z]+)(-?\d+)? ?').firstMatch(s.substring(i));
      if (m != null) {
        final kw = m.group(1)!;
        if (kw == 'par' || kw == 'line') {
          out.write('\n');
        } else if (kw == 'tab') {
          out.write('\t');
        } else if (kw == 'u' && m.group(2) != null) {
          final code = int.parse(m.group(2)!);
          out.writeCharCode(code < 0 ? code + 65536 : code);
          if (s.startsWith('\\', i + m.end)) i++; // ?-завершение суррогата
        }
        i += m.end;
      } else {
        final h = RegExp(r"^\\'([0-9a-fA-F]{2})").firstMatch(s.substring(i));
        if (h != null) {
          // Символ в кодовой странице по умолчанию: почти всегда cp1252; для
          // кириллических RTF cp1251. Байты 0xC0-0xFF совпадают, отличие мелкое.
          final byte = int.parse(h.group(1)!, radix: 16);
          out.write(cp1251Decode([byte]));
          i += h.end;
        } else {
          out.write(s[i + 1]);
          i += 2;
        }
      }
    } else {
      out.write(c);
      i++;
    }
  }
  return out.toString();
}

/// Грубый OLE-ридер: достаёт поток (сейчас WordDocument) из составного файла.
Uint8List? _oleStream(List<int> b, String name) {
  if (b.length < 512) return null;
  final bd = ByteData.sublistView(Uint8List.fromList(b));
  final sectorShift = bd.getUint16(0x1E, Endian.little);
  final ssz = 1 << sectorShift;
  int sectorStart(int s) => 512 + s * ssz;
  // FAT: до 109 секторов в DIFAT шапки (хватает для книг без DIFAT-хвоста).
  final fat = <int>[];
  for (var e = 0; e < 109; e++) {
    final fatSector = bd.getUint32(0x4C + e * 4, Endian.little);
    if (fatSector == 0xFFFFFFFF || fatSector == 0xFFFFFFFE) break;
    final base = sectorStart(fatSector);
    if (base + ssz > b.length) break;
    for (var o = 0; o + 4 <= ssz; o += 4) {
      fat.add(bd.getUint32(base + o, Endian.little));
    }
  }
  List<int> chain(int start) {
    final out = <int>[];
    var s = start;
    final seen = <int>{};
    while (s < 0xFFFFFFFA && !seen.contains(s) && s < fat.length) {
      seen.add(s);
      out.add(s);
      s = fat[s];
    }
    return out;
  }

  // Каталог: цепочка от сектора 0x30.
  int dirType = 0;
  int dirStart = 0;
  int dirSize = 0;
  for (final s in chain(bd.getUint32(0x30, Endian.little))) {
    final base = sectorStart(s);
    for (var o = 0; o + 128 <= ssz; o += 128) {
      final e = base + o;
      if (e + 128 > b.length) break;
      final len = bd.getUint16(e + 64, Endian.little);
      if (len < 2 || len > 64) continue;
      final nm = String.fromCharCodes(
          List.generate((len - 2) ~/ 2, (k) => bd.getUint16(e + k * 2, Endian.little)));
      if (nm == name && b[e + 66] == 2) {
        dirType = 2;
        dirStart = bd.getUint32(e + 116, Endian.little);
        dirSize = bd.getUint32(e + 120, Endian.little);
        break;
      }
    }
    if (dirType == 2) break;
  }
  if (dirType != 2) return null;
  final buf = BytesBuilder();
  for (final s in chain(dirStart)) {
    final st = sectorStart(s);
    final take = (dirSize - buf.length).clamp(0, ssz);
    buf.add(b.sublist(st, st + take));
    if (buf.length >= dirSize) break;
  }
  return buf.toBytes();
}

/// DOC (старый бинарный Word): грубо - FIB fcMin..fcMac из WordDocument,
/// иначе тяга печатных последовательностей cp1251 по всему потоку.
Future<String> extractDoc(String path) async {
  final b = await File(path).readAsBytes();
  final stream = _oleStream(b, 'WordDocument');
  if (stream == null) throw const FormatException('не doc');
  final bd = ByteData.sublistView(stream);
  String decode(List<int> bytes) {
    var zeros = 0;
    for (var i = 1; i < bytes.length; i += 2) {
      if (bytes[i] == 0) zeros++;
    }
    if (zeros * 3 > bytes.length) {
      return String.fromCharCodes([
        for (var i = 0; i + 1 < bytes.length; i += 2)
          bytes[i] | (bytes[i + 1] << 8)
      ]);
    }
    return cp1251Decode(bytes);
  }

  if (stream.length >= 0x20) {
    final fcMin = bd.getUint32(0x18, Endian.little);
    final fcMac = bd.getUint32(0x1C, Endian.little);
    if (fcMac > fcMin && fcMac <= stream.length && fcMac - fcMin > 64) {
      final text = decode(stream.sublist(fcMin, fcMac));
      if (RegExp(r'[а-яА-Яa-zA-Z]').hasMatch(text)) return text;
    }
  }
  // Запас: последовательности печатных символов >= 12 длиной по всему потоку.
  final sb = StringBuffer();
  var run = <int>[];
  for (final byte in stream) {
    final printable = (byte >= 0x20 && byte < 0xFF) || byte == 0x0A;
    if (printable) {
      run.add(byte);
    } else {
      if (run.length >= 12) {
        sb.write(decode(run));
        sb.write('\n');
      }
      run.clear();
    }
  }
  if (run.length >= 12) sb.write(decode(run));
  final text = sb.toString();
  if (text.trim().isEmpty) throw const FormatException('текст в doc не найден');
  return text;
}
/// MOBI/AZW/AZW3/PRC (PalmDOC): грубо - текстовые записи, PalmDoc-распаковка.
/// DRM и HUFF/CDIC не поддерживаются.
Future<String> extractMobi(String path) async {
  final b = await File(path).readAsBytes();
  if (b.length < 132) throw const FormatException('не mobi');
  if (latin1.decode(b.sublist(60, 68)) != 'BOOKMOBI') {
    throw const FormatException('не mobi');
  }
  final bd = ByteData.sublistView(b);
  final numRecords = bd.getUint16(76, Endian.big);
  int recOff(int i) => bd.getUint32(78 + i * 8, Endian.big);
  final r0 = recOff(0);
  final compression = bd.getUint16(r0, Endian.big);
  final recordCount = bd.getUint16(r0 + 8, Endian.big);
  final encryption = bd.getUint16(r0 + 12, Endian.big);
  if (encryption != 0) throw const FormatException('файл с DRM');
  if (compression == 17480) throw const FormatException('HUFF/CDIC не поддерживаю');
  var encoding = 1252;
  if (r0 + 24 <= b.length && latin1.decode(b.sublist(r0 + 16, r0 + 20)) == 'MOBI') {
    encoding = bd.getUint32(r0 + 28, Endian.big);
  }
  final sb = StringBuffer();
  final last = recordCount < numRecords ? recordCount : numRecords - 1;
  for (var r = 1; r <= last; r++) {
    final from = recOff(r);
    final to = r + 1 < numRecords ? recOff(r + 1) : b.length;
    var rec = b.sublist(from, to);
    if (compression == 2) rec = _palmdocDecompress(rec);
    sb.write(encoding == 65001
        ? utf8.decode(rec, allowMalformed: true)
        : cp1251Decode(rec));
  }
  return _htmlToText(sb.toString());
}

Uint8List _palmdocDecompress(List<int> data) {
  final out = <int>[];
  var i = 0;
  while (i < data.length) {
    final c = data[i++];
    if (c >= 1 && c <= 8) {
      for (var j = 0; j < c && i < data.length; j++) {
        out.add(data[i++]);
      }
    } else if (c <= 0x7F) {
      out.add(c);
    } else if (c <= 0xBF) {
      if (i >= data.length) break;
      final pair = (c << 8) | data[i++];
      final dist = (pair >> 3) & 0x7FF;
      final len = (pair & 7) + 3;
      final start = out.length - dist;
      for (var k = 0; k < len; k++) {
        if (start + k >= 0 && start + k < out.length) out.add(out[start + k]);
      }
    } else {
      out.add(32);
      out.add(c & 0x7F);
    }
  }
  return Uint8List.fromList(out);
}


/// Грубое удаление тегов для xhtml-глав epub: <p>, <br> -> абзацы, остальное - вон.
String _htmlToText(String html) {
  final s = html
      .replaceAll(RegExp(r'<(script|style)[\s\S]*?</\1>', caseSensitive: false), '')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  final noTags = s.replaceAll(RegExp(r'<[^>]+>'), '');
  final unescaped = noTags
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ');
  return unescaped.split('\n').map((l) => l.trim()).join('\n');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic> _hist = {'items': <dynamic>[]};

  @override
  void initState() {
    super.initState();
    _hist = loadHistory();
    _controller.addListener(_onTextChanged);
  }

  /// Перерисовка при вводе: кнопка «Читать» активна только когда есть текст.
  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  /// «Продолжить чтение»: свёрнуто в кнопку в нижнем ряду; список - по нажатию.
  Widget _buildHistory(BuildContext context) => const SizedBox.shrink();

  /// Меню «Продолжить чтение»: все книги из памяти, тап - открыть с места.
  /// Крестик убирает книгу из списка, меню остаётся открытым.
  void _showHistorySheet(BuildContext context) {
    final items = ((_hist['items'] as List?) ?? [])
        .whereType<Map>()
        .toList()
        .cast<Map<String, dynamic>>();
    String fmtDate(String? iso) {
      final d = DateTime.tryParse(iso ?? '');
      if (d == null) return '';
      String p2(int v) => v.toString().padLeft(2, '0');
      return '${p2(d.day)}.${p2(d.month)} ${p2(d.hour)}:${p2(d.minute)}';
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => SafeArea(
        child: StatefulBuilder(
          builder: (sheet, setSheet) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Text(tr('continueTitle'),
                    style: TextStyle(
                        color: Color(0xFF8A8A90),
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold)),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(tr('emptyList'),
                      style: TextStyle(color: Color(0xFF8A8A90), fontSize: 13)),
                ),
              for (final e in items)
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0E10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(sheet);
                      _openResume(context, e);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            e['kind'] == 'file'
                                ? Icons.description_outlined
                                : Icons.article_outlined,
                            color: const Color(0xFFC96F4A),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${e['title'] ?? '?'}  ·  ${tr('word')} ${(e['index'] as num?)?.toInt() ?? 0} ${tr('of')} ${(e['total'] as num?)?.toInt() ?? '?'}  ·  ${fmtDate(e['ts'] as String?)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFFC9C9CE), fontSize: 13),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _forget(e);
                              setSheet(() => items.remove(e));
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Text('✕',
                                  style: TextStyle(
                                      color: Color(0xFF8A8A90),
                                      fontSize: 14)),
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFC96F4A);
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E10),
        title: Text(tr('appName')),
      ),
      body: SafeArea(
        child: DropTarget(
        onDragDone: (details) {
          final paths = details.files.map((f) => f.path).whereType<String>().toList();
          if (paths.isNotEmpty) _openPath(context, paths.first);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
          children: [
            _buildHistory(context),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 10,
                maxLines: 20,
                style: const TextStyle(color: Color(0xFFC9C9CE)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  hintText: tr('hint'),
                  hintStyle: const TextStyle(color: Color(0xFF8A8A90)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, box) {
                final hasText = _controller.text.trim().isNotEmpty;
                // Пустое поле: кнопка не «мёртвая Читать», а приглашение -
                // открывает выбор файла/книги. С текстом - обычная «Читать».
                final readBtn = hasText
                    ? FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: accent),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(tr('read')),
                        onPressed: () => _start(context),
                      )
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(
                                color: accent.withValues(alpha: 0.55))),
                        icon: const Icon(Icons.menu_book),
                        label: Text(tr('pickOrPaste')),
                        onPressed: () {
                          if (Platform.isAndroid) {
                            _openLibrary(context);
                          } else {
                            _openFile(context);
                          }
                        },
                      );
                final openBtn = OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: accent),
                  icon: const Icon(Icons.folder_open),
                  label: Text(tr('openFile')),
                  onPressed: () => _openFile(context),
                );
                final libBtn = Platform.isAndroid
                    ? OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: accent),
                        icon: const Icon(Icons.menu_book),
                        label: Text(tr('myBooks')),
                        onPressed: () => _openLibrary(context),
                      )
                    : null;
                final histItems = (_hist['items'] as List?) ?? [];
                final histBtn = histItems.isNotEmpty
                    ? OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: accent),
                        icon: const Icon(Icons.history),
                        label: Text('${tr('resume')} (${histItems.length})'),
                        onPressed: () => _showHistorySheet(context),
                      )
                    : null;
                if (box.maxWidth < 430) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      readBtn,
                      const SizedBox(height: 8),
                      openBtn,
                      if (libBtn != null) const SizedBox(height: 8),
                      if (libBtn != null) libBtn,
                      if (histBtn != null) const SizedBox(height: 8),
                      if (histBtn != null) histBtn,
                      const SizedBox(height: 8),
                      _hint(hasText),
                    ],
                  );
                }
                return Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        readBtn,
                        openBtn,
                        if (libBtn != null) libBtn,
                        if (histBtn != null) histBtn,
                      ],
                    ),
                    const SizedBox(height: 8),
                    _hint(hasText),
                  ],
                );
              },
            ),
          ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Пояснение под кнопками: почему «Читать» неактивна и что делать.
  Widget _hint(bool hasText) => const SizedBox.shrink();

  bool _fileDialogOpen = false;

  Future<void> _openFile(BuildContext context) async {
    // Пока висит диалог выбора файла - повторные клики игнорируем.
    if (_fileDialogOpen) return;
    _fileDialogOpen = true;
    try {
      final files = await FilePicker.pickFiles();
      if (files.isEmpty) return;
      final path = files.first.path;
      if (path == null) return;
      if (!context.mounted) return;
      _openPath(context, path);
    } finally {
      _fileDialogOpen = false;
    }
  }

  Future<void> _openLibrary(BuildContext context) async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const LibraryScreen()),
    );
    if (path == null || path.isEmpty) return;
    if (!context.mounted) return;
    _openPath(context, path);
  }

  Future<void> _openPath(BuildContext context, String path,
      {Map<String, dynamic>? resume}) async {
    // Каждая прочитанная книга оседает на полке Документы/Поток (Android).
    if (Platform.isAndroid && resume == null) {
      final shelf = await androidImportBook(path);
      if (shelf != null && shelf.isNotEmpty) path = shelf;
    }
    final ext = path.split('.').last.toLowerCase();
    String text;
    try {
      switch (ext) {
        case 'txt':
          text = extractTxt(path);
        case 'fb2':
          text = extractFb2(path);
        case 'epub':
          text = await extractEpub(path);
        case 'docx':
          text = await extractDocx(path);
        case 'pdf':
          text = await extractPdf(path);
        case 'rtf':
          text = extractRtf(path);
        case 'odt':
          text = await extractOdt(path);
        case 'doc':
          text = await extractDoc(path);
        case 'mobi' || 'azw' || 'azw3' || 'prc':
          text = await extractMobi(path);
        default:
          text = extractTxt(path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('readError')}: $e')),
        );
      }
      return;
    }
    text = text.trim();
    // Бинарный файл, прочитанный как текст, даёт кашу из управляющих символов.
    final ctl = text.codeUnits.where((c) => c < 9 || (c > 13 && c < 32)).length;
    if (text.isEmpty || ctl * 10 > text.length) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(tr('noText'))),
        );
      }
      return;
    }
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            text: text,
            filePath: path,
            startIndex: (resume?['index'] as num?)?.toInt() ?? 0,
            startWpm: (resume?['wpm'] as num?)?.toDouble(),
            startFontSize: (resume?['fontSize'] as num?)?.toDouble(),
          ),
        ),
      );
      if (mounted) setState(() => _hist = loadHistory());
    }
  }

  /// Открыть запись истории: файл заново извлекается, текст берётся из памяти.
  Future<void> _openResume(BuildContext context, Map<String, dynamic> e) async {
    final kind = e['kind'];
    if (kind == 'file' && e['path'] != null) {
      final f = File(e['path']);
      if (!f.existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${tr('fileNotFound')}: ${e['path']}')));
        }
        return;
      }
      if (!context.mounted) return;
      await _openPath(context, e['path'], resume: e);
    } else {
      final text = (e['text'] as String?) ?? '';
      if (text.trim().isEmpty) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            text: text,
            startIndex: (e['index'] as num?)?.toInt() ?? 0,
            startWpm: (e['wpm'] as num?)?.toDouble(),
            startFontSize: (e['fontSize'] as num?)?.toDouble(),
          ),
        ),
      );
      if (mounted) setState(() => _hist = loadHistory());
    }
  }

  void _forget(Map<String, dynamic> e) {
    final h = loadHistory();
    final items = (h['items'] as List?) ?? [];
    items.removeWhere((x) =>
        x is Map &&
        x['ts'] == e['ts'] &&
        x['title'] == e['title']);
    h['items'] = items;
    saveHistory(h);
    setState(() => _hist = h);
  }

  void _start(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => ReaderScreen(text: text)),
        )
        .then((_) {
          if (mounted) setState(() => _hist = loadHistory());
        });
  }
}

// ---- Экран чтения ----

class ReaderScreen extends StatefulWidget {
  final String text;
  final bool autoplay;
  final String? filePath;
  final int startIndex;
  final double? startWpm;
  final double? startFontSize;
  const ReaderScreen(
      {super.key,
      required this.text,
      this.autoplay = false,
      this.filePath,
      this.startIndex = 0,
      this.startWpm,
      this.startFontSize});
  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late double wpm = widget.startWpm ?? 300;
  late double fontSize = widget.startFontSize ?? 56;
  bool dark = true;

  late final List<Chunk> chunks;
  int index = 0;
  bool playing = false;
  Timer? timer;
  Timer? _autosave;
  String? _seekHint; // подсказка направления при прыжке на 50 слов
  Timer? _seekHintTimer;
  // Шапка книги: название, автор, путь (тап по шапке показывает путь).
  String _bookTitle = '';
  String _bookAuthor = '';
  final Stopwatch _session = Stopwatch();
  int _wordsShown = 0;
  // Щипок двумя пальцами: меняет размер шрифта, слово остаётся на оси ORP.
  final Map<int, Offset> _pinchPointers = {};
  double? _pinchStartDist;
  double? _pinchStartFont;
  DateTime? _pinchEndedAt; // щипок недавно кончился - свайп игнорируем

  void _handlePinchScale() {
    if (_pinchPointers.length != 2 || _pinchStartDist == null) return;
    final pts = _pinchPointers.values.toList();
    final d = (pts[0] - pts[1]).distance;
    if (d < 20) return;
    setState(() {
      fontSize =
          (_pinchStartFont! * d / _pinchStartDist!).clamp(24.0, 140.0);
    });
  }

  @override
  void initState() {
    super.initState();
    chunks = parseText(widget.text, 1);
    index = widget.startIndex.clamp(0, chunks.length - 1);
    if (widget.filePath != null) _loadBookMeta();
    // Демо-режим (запуск с --demo): автостарт через полсекунды.
    if (widget.autoplay) {
      Timer(const Duration(milliseconds: 500), _play);
    } else {
      _remember(); // файл виден в библиотеке сразу после открытия
      _autosave = Timer.periodic(
          const Duration(seconds: 5), (_) {
        if (playing) _remember(); // место живёт, даже если окно закрыли без паузы
      });
    }
  }

  /// Название и автор: метаданные fb2/epub, иначе - имя файла.
  Future<void> _loadBookMeta() async {
    final path = widget.filePath!;
    var title = '';
    var author = '';
    try {
      final ext = path.split('.').last.toLowerCase();
      if (ext == 'fb2') {
        final b = File(path).readAsBytesSync();
        final head = _decodeFb2Bytes(
            b.sublist(0, b.length > 65536 ? 65536 : b.length));
        String? tag(String t) => RegExp('<$t[^>]*>(.*?)</$t>', dotAll: true)
            .firstMatch(head)
            ?.group(1)
            ?.trim();
        title = tag('book-title') ?? '';
        author = [tag('first-name') ?? '', tag('last-name') ?? '']
            .where((s) => s.isNotEmpty)
            .join(' ');
      } else if (ext == 'epub') {
        final archive =
            ZipDecoder().decodeBytes(await File(path).readAsBytes());
        final container = archive.findFile('META-INF/container.xml');
        if (container != null) {
          final cdoc = XmlDocument.parse(
              utf8.decode(container.content as List<int>, allowMalformed: true));
          final opfPath = cdoc
              .findAllElements('rootfile')
              .map((e) => e.getAttribute('full-path') ?? '')
              .firstWhere((s) => s.isNotEmpty, orElse: () => '');
          final opf = archive.findFile(opfPath);
          if (opf != null) {
            final doc = XmlDocument.parse(
                utf8.decode(opf.content as List<int>, allowMalformed: true));
            String? dc(String t) => doc
                .findAllElements(t, namespace: '*')
                .map((e) => e.innerText.trim())
                .firstWhere((s) => s.isNotEmpty, orElse: () => '');
            title = dc('title') ?? '';
            author = dc('creator') ?? '';
          }
        }
      }
      // Кракозябры (не распознали кодировку) - честнее показать имя файла.
      if (title.contains('\uFFFD')) title = '';
      if (author.contains('\uFFFD')) author = '';
    } catch (_) {
      // Нет метаданных - покажем имя файла, это не ошибка чтения.
    }
    if (!mounted) return;
    setState(() {
      _bookTitle = title;
      _bookAuthor = author;
    });
  }

  String get _bookName {
    if (_bookTitle.isNotEmpty) return _bookTitle;
    final p = widget.filePath;
    if (p == null) return tr('pastedText');
    return p.split(Platform.pathSeparator).last;
  }

  void _showBookInfo() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(_bookName, style: const TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_bookAuthor.isNotEmpty) Text('${tr('author')}: $_bookAuthor'),
            const SizedBox(height: 6),
            SelectableText(widget.filePath ?? tr('pathUnavailable'),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(tr('close'))),
        ],
      ),
    );
  }

  /// Запомнить место остановки (файл или вставленный текст).
  void _remember() {    if (widget.autoplay) return; // демо в память не пишем
    rememberProgress(
      kind: widget.filePath == null ? 'text' : 'file',
      path: widget.filePath,
      text: widget.filePath == null ? widget.text : null,
      title: widget.filePath == null
          ? tr('pastedText')
          : widget.filePath!.split(Platform.pathSeparator).last,
      index: index,
      total: chunks.length,
      wpm: wpm,
      fontSize: fontSize,
    );
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _seekHintTimer?.cancel();
    _remember();
    timer?.cancel();
    _session.stop();
    super.dispose();
  }

  Duration get step {
    final ms = (60000 / wpm).round();
    return Duration(milliseconds: (ms * chunks[index].delayFactor).round());
  }

  void _tick() {
    if (index < chunks.length - 1) {
      setState(() {
        index++;
        _wordsShown++;
      });
      timer?.cancel();
      timer = Timer(step, _tick);
    } else {
      _pause();
      _showStats();
    }
  }

  void _play() {
    if (playing) return;
    setState(() => playing = true);
    _session.start();
    timer = Timer(step, _tick);
  }

  void _pause() {
    timer?.cancel();
    _session.stop();
    setState(() => playing = false);
    _remember(); // место сохраняется на каждой паузе
  }

  void _toggle() => playing ? _pause() : _play();

  void _seek(int delta) {
    _jumpTo(index + delta);
    if (delta.abs() >= 10) {
      _seekHint = delta > 0 ? tr('fwd50') : tr('back50');
      _seekHintTimer?.cancel();
      _seekHintTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _seekHint = null);
      });
      setState(() {});
    }
  }

  /// Прыжок к слову i: таймер перезапускается, если читали.
  void _jumpTo(int i) {
    timer?.cancel();
    setState(() => index = i.clamp(0, chunks.length - 1));
    if (playing) timer = Timer(step, _tick);
  }

  void _replaySentence() {
    var i = index;
    while (i > 0 && chunks[i - 1].delayFactor < 2.5) {
      i--;
    }
    timer?.cancel();
    setState(() => index = i);
    if (playing) timer = Timer(step, _tick);
  }

  // ---- Страница-обзор: оглавление (заголовки и подзаголовки) ----

  /// Позиция = индекс слова (chunk) с которого начинается раздел.
  List<({String title, int level, int wordIndex})> _buildOutline() {
    final result = <({String title, int level, int wordIndex})>[];
    final paragraphs = widget.text.split(RegExp(r'\n\s*\n'));
    var wordIndex = 0;
    for (final para in paragraphs) {
      final words =
          para.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final h = _headingOf(para);
      if (h != null) {
        result.add((title: h.$2, level: h.$1, wordIndex: wordIndex));
      }
      wordIndex += words.length;
    }
    return result;
  }

  /// Заголовок абзаца -> (уровень, текст) или null.
  /// Явная разметка (#, ##) или короткая строка-фраза без конечной пунктуации.
  (int, String)? _headingOf(String para) {
    final t = para.trim();
    if (t.isEmpty || t.contains('\n')) return null;
    final md = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(t);
    if (md != null) {
      return (md.group(1)!.length, md.group(2)!.trim());
    }
    if (t.length > 80) return null;
    if (RegExp(r'[.!?:;…,"»]$').hasMatch(t)) return null;
    final words = t.split(RegExp(r'\s+'));
    if (words.length > 12) return null;
    // Подзаголовок - короче и ниже регистром; заголовок - ещё и КАПСОМ/номером.
    final isCaps = t == t.toUpperCase() && RegExp(r'[А-ЯЁA-Z]').hasMatch(t);
    final numbered = RegExp(
        r'^(?:\d+(?:[.)]\d+)*[.)]?\s|глава|часть|раздел)',
        caseSensitive: false)
        .hasMatch(t);
    final level = (isCaps || numbered) ? 1 : 2;
    return (level, t);
  }

  void _openOverview() {
    timer?.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (_) => _OverviewScreen(
            outline: _buildOutline(),
            current: index,
            dark: dark,
            onPick: _jumpTo,
          ),
        ))
        .whenComplete(() {
      // Чтение на фоне поставлено на паузу (таймер погашен, флаг playing не тронут):
      // вернулись без прыжка - продолжаем с того же места, прыжок сам перезапустил.
      if (playing && mounted) timer ??= Timer(step, _tick);
    });
  }

  Future<void> _showStats() async {
    final secs = _session.elapsedMilliseconds / 1000;
    final speed = secs > 0 ? (_wordsShown / secs * 60).round() : 0;
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('sessionDone')),
        content: Text(
            '${tr('wordsRead')}: $_wordsShown\n${tr('time')}: ${secs.toStringAsFixed(0)} ${tr('secShort')}\n${tr('avgSpeed')}: $speed ${tr('wpmUnit')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  String _etaText() {
    var ms = 0.0;
    for (var i = index + 1; i < chunks.length; i++) {
      ms += (60000 / wpm) * chunks[i].delayFactor;
    }
    final s = ms / 1000;
    if (s < 90) return '${s.round()} ${tr('secShort')}';
    return '${(s / 60).round()} ${tr('minShort')}';
  }

  /// Сколько времени уже "пройдено" до текущего слова.
  String _elapsedText() {
    var ms = 0.0;
    for (var i = 0; i < index; i++) {
      ms += (60000 / wpm) * chunks[i].delayFactor;
    }
    final s = ms / 1000;
    if (s < 90) return '${s.round()} ${tr('secShort')}';
    return '${(s / 60).round()} ${tr('minShort')}';
  }

  @override
  Widget build(BuildContext context) {
    // Палитра в духе spreeder.ru: тёмно-синий фон, оранжевый акцент.
    const accent = Color(0xFFC96F4A);
    final bg = dark ? const Color(0xFF0E0E10) : const Color(0xFFF5F7FA);
    final dim = dark ? const Color(0xFFC9C9CE) : const Color(0xFF22314A);
    final guide = dark ? Colors.white24 : Colors.black12;
    final card = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final chunk = chunks[index];
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        switch (event.logicalKey) {
          case LogicalKeyboardKey.space:
            _toggle();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowRight:
            _seek(50);
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowLeft:
            _seek(-50);
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowUp:
            setState(() => wpm = (wpm + 25).clamp(100, 1500).toDouble());
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowDown:
            setState(() => wpm = (wpm - 25).clamp(100, 1500).toDouble());
            return KeyEventResult.handled;
          case LogicalKeyboardKey.keyB:
            _replaySentence();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.equal:
          case LogicalKeyboardKey.numpadAdd:
            if (ctrl) {
              setState(() => fontSize = (fontSize + 4).clamp(24, 140));
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          case LogicalKeyboardKey.minus:
          case LogicalKeyboardKey.numpadSubtract:
            if (ctrl) {
              setState(() => fontSize = (fontSize - 4).clamp(24, 140));
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          case LogicalKeyboardKey.digit0:
          case LogicalKeyboardKey.numpad0:
            if (ctrl) {
              setState(() => fontSize = 56);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerSignal: (event) {
          // Масштаб слова колёсиком при зажатом Ctrl.
          if (event is PointerScrollEvent &&
              HardwareKeyboard.instance.isControlPressed) {
            setState(() => fontSize =
                (fontSize - event.scrollDelta.dy.sign * 3).clamp(24, 140));
          }
        },
        child: Scaffold(
          backgroundColor: bg,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          onHorizontalDragEnd: (d) {
            if (_pinchEndedAt != null &&
                DateTime.now().difference(_pinchEndedAt!) <
                    const Duration(milliseconds: 400)) {
              return; // это был щипок, не свайп
            }
            final v = d.primaryVelocity ?? 0;
            if (v < 0) _seek(1);
            if (v > 0) _seek(-1);
          },
          child: SafeArea(
            child: Column(
              children: [
                // Шапка книги: что читаем. Тап - автор и путь файла.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _showBookInfo,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 6, bottom: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book,
                            size: 15, color: Color(0xFF8A8A90)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _bookAuthor.isEmpty
                                ? _bookName
                                : '$_bookName · $_bookAuthor',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: dim.withValues(alpha: 0.75)),
                          ),
                        ),
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFF8A8A90)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Щипок двумя пальцами = размер шрифта; тап и свайп не трогаем.
                      Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          _pinchPointers[e.pointer] = e.position;
                          if (_pinchPointers.length == 2) {
                            final pts = _pinchPointers.values.toList();
                            _pinchStartDist = (pts[0] - pts[1]).distance;
                            _pinchStartFont = fontSize;
                          }
                        },
                        onPointerMove: (e) {
                          if (!_pinchPointers.containsKey(e.pointer)) return;
                          _pinchPointers[e.pointer] = e.position;
                          _handlePinchScale();
                        },
                        onPointerUp: (e) {
                          if (_pinchPointers.length >= 2) {
                            _pinchEndedAt = DateTime.now();
                          }
                          _pinchPointers.remove(e.pointer);
                          _pinchStartDist = null;
                        },
                        onPointerCancel: (e) {
                          if (_pinchPointers.length >= 2) {
                            _pinchEndedAt = DateTime.now();
                          }
                          _pinchPointers.remove(e.pointer);
                          _pinchStartDist = null;
                        },
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Две горизонтальные черты: чуть выше и чуть ниже слова.
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      height: 1.5,
                                      width: 460,
                                      color: guide.withValues(alpha: 1)),
                                  SizedBox(height: fontSize * 1.5),
                                  Container(
                                      height: 1.5,
                                      width: 460,
                                      color: guide.withValues(alpha: 1)),
                                ],
                              ),
                              _WordView(
                                  chunk: chunk,
                                  fontSize: fontSize,
                                  dim: dim,
                                  accent: accent),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 1,
                          height: 190,
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      // Большая круглая кнопка пуска, как на spreeder.ru.
                      if (!playing)
                        GestureDetector(
                          onTap: _toggle,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.45),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_arrow,
                                size: 64, color: Colors.white),
                          ),
                        ),
                      // Подсказка направления при прыжке на 50 слов.
                      if (_seekHint != null)
                        Positioned(
                          top: 18,
                          child: AnimatedOpacity(
                            opacity: 1,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: card.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _seekHint == tr('fwd50')
                                        ? Icons.fast_forward
                                        : Icons.fast_rewind,
                                    color: accent,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_seekHint!,
                                      style: TextStyle(
                                          color: dim, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Нижняя панель управления в стиле spreeder.ru.
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Полоса прогресса: тянется мышью или пальцем,
                      // по краям таймфрейм (пройдено / осталось).
                      Row(
                        children: [
                          SizedBox(
                            width: 64,
                            child: Text(_elapsedText(),
                                textAlign: TextAlign.right,
                                style: TextStyle(color: dim, fontSize: 12)),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16),
                                trackShape:
                                    const RoundedRectSliderTrackShape(),
                              ),
                              child: Slider(
                                value: chunks.isEmpty
                                    ? 0
                                    : index.toDouble(),
                                max: chunks.isEmpty
                                    ? 1
                                    : (chunks.length - 1).toDouble(),
                                activeColor: accent,
                                inactiveColor: dark
                                    ? Colors.white12
                                    : Colors.black12,
                                onChanged: chunks.isEmpty
                                    ? null
                                    : (v) => _jumpTo(v.round()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text('~${_etaText()}',
                                style: TextStyle(color: dim, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Скорость: минус, число, плюс.
                          Container(
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Минус/плюс текстом: гарантированно видны.
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setState(() =>
                                      wpm = (wpm - 25).clamp(100, 1500).toDouble()),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    child: Text('-',
                                        style: TextStyle(
                                            fontSize: 20,
                                            height: 1.1,
                                            color: dim)),
                                  ),
                                ),
                                SizedBox(
                                  width: 52,
                                  child: Text('${wpm.round()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          color: dim)),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setState(() =>
                                      wpm = (wpm + 25).clamp(100, 1500).toDouble()),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    child: Text('+',
                                        style: TextStyle(
                                            fontSize: 20,
                                            height: 1.1,
                                            color: dim)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(tr('wpmUnit'),
                              style: const TextStyle(
                                  fontSize: 10, letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${index + 1} / ${chunks.length} ${tr('words')}',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: dim.withValues(alpha: 0.85)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          IconButton(
                              tooltip: tr('ttToStart'),
                              onPressed: () => _seek(-1000000),
                              icon: const Icon(Icons.restart_alt)),
                          IconButton(
                              tooltip: tr('ttBack50'),
                              onPressed: () => _seek(-50),
                              icon: const Icon(Icons.skip_previous)),
                          IconButton(
                              tooltip: tr('ttPlay'),
                              onPressed: _toggle,
                              icon: Icon(playing
                                  ? Icons.pause
                                  : Icons.play_arrow)),
                          IconButton(
                              tooltip: tr('ttFwd50'),
                              onPressed: () => _seek(50),
                              icon: const Icon(Icons.skip_next)),
                          IconButton(
                              tooltip: tr('ttOverview'),
                              onPressed: _openOverview,
                              icon: const Icon(Icons.view_agenda_outlined)),
                          IconButton(
                              tooltip: tr('ttReread'),
                              onPressed: _replaySentence,
                              icon: const Icon(Icons.replay)),
                          IconButton(
                              tooltip: tr('ttFont'),
                              onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => StatefulBuilder(
                                      builder: (ctx, setD) => AlertDialog(
                                        title: Text(tr('fontTitle')),
                                        content: Slider(
                                          value: fontSize,
                                          min: 24,
                                          max: 96,
                                          onChanged: (v) {
                                            setD(() => fontSize = v);
                                            setState(() => fontSize = v);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(tr('done')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              icon: const Icon(Icons.settings)),
                          IconButton(
                              tooltip: tr('ttTheme'),
                              onPressed: () => setState(() => dark = !dark),
                              icon: const Icon(Icons.brightness_6_outlined)),
                          IconButton(
                              tooltip: tr('ttExit'),
                              onPressed: () {
                                timer?.cancel();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close)),
                        ],
                      ),
                    ],
                      ),
                    ),
                  ),
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

// ---- Страница-обзор: оглавление (заголовки и подзаголовки) ----

class _OverviewScreen extends StatelessWidget {
  final List<({String title, int level, int wordIndex})> outline;
  final int current;
  final bool dark;
  final ValueChanged<int> onPick;
  const _OverviewScreen({
    required this.outline,
    required this.current,
    required this.dark,
    required this.onPick,
  });

  int _curSection() {
    var lo = -1;
    for (var s = 0; s < outline.length; s++) {
      if (outline[s].wordIndex <= current) {
        lo = s;
      } else {
        break;
      }
    }
    return lo;
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFC96F4A);
    final bg = dark ? const Color(0xFF0E0E10) : const Color(0xFFF5F7FA);
    final textC = dark ? const Color(0xFFC9C9CE) : const Color(0xFF1C1C1E);
    final dimC = dark ? const Color(0xFF8A8A90) : const Color(0xFF6B6B70);
    final cur = _curSection();
    final ctl = ScrollController(
      initialScrollOffset:
          (cur * 48.0 - 120).clamp(0.0, outline.length * 48.0),
    );
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text('${tr('outline')}: ${outline.length} ${tr('sections')}'),
      ),
      body: outline.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  tr('noHeadings'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: dimC, fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              controller: ctl,
              itemExtent: 48,
              itemCount: outline.length,
              itemBuilder: (ctx, s) {
                final e = outline[s];
                final isPast = s < cur;
                final isCur = s == cur;
                return ListTile(
                  dense: true,
                  onTap: () {
                    onPick(e.wordIndex);
                    Navigator.pop(context);
                  },
                  title: Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: e.level == 1 ? 15.5 : 14,
                      fontWeight: isCur
                          ? FontWeight.bold
                          : (e.level == 1 ? FontWeight.w600 : FontWeight.normal),
                      color: isCur ? accent : (isPast ? dimC : textC),
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: e.level == 1 ? 16.0 : 36.0),
                  trailing: isCur
                      ? const Icon(Icons.place, color: accent, size: 18)
                      : null,
                );
              },
            ),
    );
  }
}

class _WordView extends StatelessWidget {
  final Chunk chunk;
  final double fontSize;
  final Color dim;
  final Color accent;
  const _WordView(
      {required this.chunk,
      required this.fontSize,
      required this.dim,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    final w = chunk.word;
    final i = chunk.orpIndex.clamp(0, w.isEmpty ? 0 : w.length - 1);
    final before = w.substring(0, i);
    final focus = w.substring(i, i + 1);
    final after = w.substring(i + 1);
    final style = TextStyle(
        fontSize: fontSize, height: 1.2, color: dim, fontFamily: 'Consolas');
    // Пивот: левая половина прижата к центру справа, правая уходит влево -
    // красная буква всегда ровно на оси прицела, слово не центрируется целиком.
    return Row(
      children: [
        Expanded(
          child: Text(
            before,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: style,
          ),
        ),
        Text(
          focus,
          style: TextStyle(
              fontSize: fontSize,
              height: 1.2,
              color: accent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Consolas'),
        ),
        Expanded(
          child: Text(
            after,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: style,
          ),
        ),
      ],
    );
  }
}

// ---- Библиотека телефона: свой список книг (обход того, что SAF не видит .fb2) ----

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _loading = true;
  bool _access = false;
  List<Map<String, dynamic>> _files = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final access = await androidHasAccess();
    final files = access ? await androidListFiles() : const <Map<String, dynamic>>[];
    if (!mounted) return;
    setState(() {
      _access = access;
      _files = files;
      _loading = false;
    });
  }

  String _size(num bytes) => bytes < 1048576
      ? '${(bytes / 1024).round()} ${tr('kb')}'
      : '${(bytes / 1048576).toStringAsFixed(1)} ${tr('mb')}';

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFC96F4A);
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E10),
        title: Text(tr('myBooks')),
        actions: [
          IconButton(
            tooltip: tr('refresh'),
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : !_access
              ? _noAccess(accent)
              : _files.isEmpty
                  ? _empty(accent)
                  : _list(accent),
    );
  }

  Widget _noAccess(Color accent) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_off_outlined, size: 56, color: Color(0xFF8A8A90)),
              const SizedBox(height: 16),
              Text(
                tr('accessNeeded'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFC9C9CE), height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () async {
                  await androidRequestAccess();
                  // Возвращаемся из настроек - перечитываем список.
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  await _load();
                },
                icon: const Icon(Icons.settings),
                label: Text(tr('grantAccess')),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _load,
                child: Text(tr('checkAgain')),
              ),
            ],
          ),
        ),
      );

  Widget _empty(Color accent) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_outlined, size: 56, color: Color(0xFF8A8A90)),
              const SizedBox(height: 16),
              Text(
                tr('noBooks'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFC9C9CE), height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(tr('refresh')),
              ),
            ],
          ),
        ),
      );

  Widget _list(Color accent) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _files.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF26262A)),
        itemBuilder: (context, i) {
          final f = _files[i];
          final name = '${f['name']}';
          final folder = '${f['folder'] ?? ''}';
          final size = _size((f['size'] as num?) ?? 0);
          final ext = name.contains('.') ? name.split('.').last.toUpperCase() : '';
          return ListTile(
            leading: Icon(
              ext == 'FB2' || ext == 'EPUB'
                  ? Icons.auto_stories_outlined
                  : Icons.description_outlined,
              color: accent,
            ),
            title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('$folder · $size · $ext',
                style: const TextStyle(color: Color(0xFF8A8A90), fontSize: 12)),
            onTap: () => Navigator.pop(context, f['path'] as String?),
          );
        },
      );
}