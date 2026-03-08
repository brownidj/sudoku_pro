import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AnimalImageCache {
  static Future<Map<String, Map<int, ui.Image>>>? _future;
  static Future<Map<String, Map<int, Map<int, ui.Image>>>>? _notesFuture;
  static Map<String, Map<int, Map<int, ui.Image>>>? _notesCache;

  static Future<Map<String, Map<int, ui.Image>>> loadAll() {
    _future ??= _loadAll();
    return _future!;
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>> loadNotesAll() {
    _notesFuture ??= _loadNotesAll();
    return _notesFuture!;
  }

  static Future<Map<int, ui.Image>> loadVariant(String variant) async {
    final all = await loadAll();
    return all[variant] ?? all['simple'] ?? <int, ui.Image>{};
  }

  static Future<Map<String, Map<int, ui.Image>>> _loadAll() async {
    final simple = await _loadImages(variant: 'simple');
    final cute = await _loadImages(variant: 'cute');
    final butterflies = await _loadButterflyImages();
    return {'simple': simple, 'cute': cute, 'butterflies': butterflies};
  }

  static Future<Map<String, Map<int, Map<int, ui.Image>>>>
  _loadNotesAll() async {
    final sizes = [16, 20, 24, 32];
    final simple = <int, Map<int, ui.Image>>{};
    final cute = <int, Map<int, ui.Image>>{};
    final butterflies = <int, Map<int, ui.Image>>{};
    final simpleNotes = await _loadNotesImages(variant: 'simple');
    final cuteNotes = await _loadNotesImages(variant: 'cute');
    final butterflyNotes = await _loadButterflyImages();
    for (final size in sizes) {
      simple[size] = Map<int, ui.Image>.from(simpleNotes);
      cute[size] = Map<int, ui.Image>.from(cuteNotes);
      butterflies[size] = Map<int, ui.Image>.from(butterflyNotes);
    }
    _notesCache = {'simple': simple, 'cute': cute, 'butterflies': butterflies};
    return _notesCache!;
  }

  static Future<Map<int, ui.Image>> _loadImages({
    required String variant,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data = await rootBundle.load(
        'assets/images/animals/${d}_${prefix}$name.png',
      );
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Future<Map<int, ui.Image>> _loadNotesImages({
    required String variant,
  }) async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _animalName(d);
      final prefix = variant == 'cute' ? 'cartoon_' : '';
      final data = await rootBundle.load(
        'assets/images/animals/${d}_${prefix}${name}_notes.png',
      );
      final image = await _decodeImage(data.buffer.asUint8List());
      images[d] = image;
    }
    return images;
  }

  static Future<Map<int, ui.Image>> _loadButterflyImages() async {
    final images = <int, ui.Image>{};
    for (var d = 1; d <= 9; d += 1) {
      final name = _butterflyName(d);
      try {
        final data = await rootBundle.load(
          'assets/images/butterflies/${d}_${name}.png',
        );
        final image = await _decodeImage(data.buffer.asUint8List());
        images[d] = image;
      } on FlutterError {
        // Missing butterfly assets remain placeholders for now.
      }
    }
    return images;
  }

  static Map<int, ui.Image> notesFor(String variant, int size) {
    return _notesCache?[variant]?[size] ?? <int, ui.Image>{};
  }

  static String _animalName(int digit) {
    switch (digit) {
      case 1:
        return 'ape';
      case 2:
        return 'buffalo';
      case 3:
        return 'camel';
      case 4:
        return 'dolphin';
      case 5:
        return 'elephant';
      case 6:
        return 'frog';
      case 7:
        return 'giraffe';
      case 8:
        return 'hippo';
      case 9:
        return 'iguana';
      default:
        return 'ape';
    }
  }

  static String _butterflyName(int digit) {
    switch (digit) {
      case 1:
        return 'monarch';
      case 2:
        return 'swallowtail';
      case 3:
        return 'blue_morpho';
      case 4:
        return 'glasswing';
      case 5:
        return 'peacock_butterfly';
      case 6:
        return 'zebra_longwing';
      case 7:
        return 'sulphur_butterfly';
      case 8:
        return 'leaf_butterfly';
      case 9:
        return 'metalmark_butterfly';
      default:
        return 'monarch';
    }
  }

  static String nameForDigit(int digit) {
    return _animalName(digit);
  }

  static String displayNameForDigit(String contentMode, int digit) {
    if (contentMode == 'butterflies') {
      return _butterflyName(digit).replaceAll('_', ' ');
    }
    return _animalName(digit);
  }

  static String initialForDigit(int digit) {
    final name = _animalName(digit);
    if (name.isEmpty) {
      return '';
    }
    return name[0].toUpperCase();
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
