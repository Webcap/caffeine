// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml_events.dart';

void main() {
  test('Rigorous SVG validation', () {
    final dir = Directory('assets');
    final svgFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.svg'));

    int count = 0;
    for (final file in svgFiles) {
      count++;
      try {
        final content = file.readAsStringSync();
        parseEvents(content).toList();
      } catch (e) {
        fail('Malformed SVG found in ${file.path}:\n$e');
      }
    }
    print('Validated $count SVG files.');
  });
}
