import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:potok/main.dart';

void main() {
  final dir = Directory.systemTemp.createTempSync('potok-test');

  test('txt utf-8', () {
    final p = '${dir.path}\\a.txt';
    File(p).writeAsStringSync('Привет мир. Второе предложение.', encoding: utf8);
    expect(extractTxt(p), contains('Привет мир'));
  });

  test('txt cp1251', () {
    final p = '${dir.path}\\b.txt';
    final bytes = const Cp1251Encoder().convert('Тест кодировки 1251.');    File(p).writeAsBytesSync(bytes);
    expect(extractTxt(p), contains('Тест кодировки'));
  });

  test('fb2', () {
    final p = '${dir.path}\\c.fb2';
    File(p).writeAsStringSync(
        '<?xml version="1.0" encoding="utf-8"?><FictionBook><body><p>Первый абзац.</p><p>Второй абзац.</p></body></FictionBook>',
        encoding: utf8);
    final t = extractFb2(p);
    expect(t, contains('Первый абзац.'));
    expect(t, contains('Второй абзац.'));
  });

  test('docx', () async {
    final p = '${dir.path}\\d.docx';
    final docXml =
        '<?xml version="1.0"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>Строка из документа</w:t></w:r></w:p><w:p><w:r><w:t>Вторая строка</w:t></w:r></w:p></w:body></w:document>';
    final encoder = ZipFileEncoder();
    encoder.create(p);
    encoder.addArchiveFile(ArchiveFile.string(
        'word/document.xml', docXml));
    encoder.close();
    final t = await extractDocx(p);
    expect(t, contains('Строка из документа'));
    expect(t, contains('Вторая строка'));
  });

  test('epub', () async {
    final p = '${dir.path}\\e.epub';
    final containerXml =
        '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>';
    final opf =
        '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0"><manifest><item id="c1" href="ch1.xhtml" media-type="application/xhtml+xml"/></manifest><spine><itemref idref="c1"/></spine></package>';
    final ch1 =
        '<?xml version="1.0"?><html><body><p>Глава первая про всё.</p><p>Второй абзац главы.</p></body></html>';
    final encoder = ZipFileEncoder();
    encoder.create(p);
    encoder.addArchiveFile(
        ArchiveFile.string('META-INF/container.xml', containerXml));
    encoder.addArchiveFile(ArchiveFile.string('OEBPS/content.opf', opf));
    encoder.addArchiveFile(ArchiveFile.string('OEBPS/ch1.xhtml', ch1));
    encoder.close();
    final t = await extractEpub(p);
    expect(t, contains('Глава первая'));
    expect(t, contains('Второй абзац главы'));
  });

  test('pdf', () async {
    final t = await extractPdf('C:\\Tools\\test.pdf');
    expect(t, contains('Скорочтение это навык'));
  });
}

/// Минимальный кодировщик cp1251 для теста (обратный к cp1251Decode).
class Cp1251Encoder {
  const Cp1251Encoder();
  List<int> convert(String s) {
    final out = <int>[];
    for (final rune in s.codeUnits) {
      if (rune < 0x80) {
        out.add(rune);
      } else if (rune >= 0x0410 && rune <= 0x044F) {
        out.add(0xC0 + (rune - 0x0410));
      } else {
        out.add(0x3F); // ?
      }
    }
    return out;
  }
}
