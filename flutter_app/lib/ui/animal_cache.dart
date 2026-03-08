import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AnimalImageCache {
  static Future<Map<String, Map<int, ui.Image>>>? _future;
  static Future<Map<String, Map<int, Map<int, ui.Image>>>>? _notesFuture;
  static Map<String, Map<int, Map<int, ui.Image>>>? _notesCache;
  static Future<Map<int, String>>? _butterflyDescriptionsFuture;
  static Map<int, String>? _butterflyDescriptionsCache;
  static const Map<int, String> _defaultButterflyDescriptions = {
    1:
        'The Monarch butterfly is famous for orange wings veined in black and remarkable migrations. It is found across North America, breeding in Canada and the United States, then wintering in central Mexico and coastal California groves. Monarchs favor milkweed habitats, open fields, roadsides, and sunny meadows with blooming nectar plants.',
    2:
        'The Swallowtail butterfly displays elegant tails, bold yellow and black markings, and strong gliding flight. It is found across Europe, Asia, North America, and parts of Africa, depending on species. Swallowtails thrive in gardens, river valleys, wood edges, and grasslands where host plants and nectar flowers are plentiful year-round locally.',
    3:
        'The Blue Morpho butterfly dazzles with iridescent blue upper wings and brown undersides marked with eye spots. It is found in tropical forests of Central and South America, especially Brazil, Costa Rica, and Peru. Blue Morphos glide along forest edges, feeding on fermenting fruit, tree sap, and moist patches frequently.',
    4:
        'The Glasswing butterfly is known for transparent wings edged in brown and delicate, floating flight. It is found from Mexico through Central America into northern South America, including Colombia and Ecuador. Glasswings inhabit humid tropical forests, where adults visit flowers for nectar and contribute importantly to pollination cycles locally daily.',
    5:
        'The Peacock butterfly has rich reddish wings with striking eye spots that startle predators effectively. It is found across Europe and temperate Asia, including the United Kingdom, Scandinavia, and Japan. Peacock butterflies frequent woodland clearings, hedgerows, gardens, and parks, feeding on nectar and overwintering in sheltered buildings or tree hollows.',
    6:
        'The Zebra Longwing butterfly features long narrow wings striped in black and yellow, flying slowly and gracefully. It is found in the southern United States, Mexico, Central America, and parts of South America. Zebra Longwings inhabit subtropical hammocks, forest edges, and gardens, feeding on nectar and pollen throughout seasons year-round.',
    7:
        'The Sulphur butterfly is typically bright yellow or orange, with quick fluttering flight over open ground. It is found widely across North and South America, especially in warm grasslands, fields, and roadsides. Sulphurs rely on legume host plants, and adults visit clover, asters, and other common nectar flowers daily nearby.',
    8:
        'The Leaf butterfly resembles a dead leaf when wings are closed, providing remarkable camouflage from predators. It is found in South and Southeast Asia, including India, Sri Lanka, Thailand, and Indonesia. Leaf butterflies inhabit forest understories and shaded trails, where they feed on fruit juices and tree sap regularly nearby.',
    9:
        'The Metalmark butterfly is generally small, with metallic-looking spots and intricate wing patterns. It is found in the Americas, especially from the southwestern United States through Mexico to South America, depending on species. Metalmarks occupy chaparral, deserts, dry scrub, and tropical habitats, using specialized host plants and sunny perches regularly.',
  };

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

  static Future<Map<int, String>> loadButterflyDescriptions() {
    _butterflyDescriptionsFuture ??= _loadButterflyDescriptions();
    return _butterflyDescriptionsFuture!;
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

  static Future<Map<int, String>> _loadButterflyDescriptions() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/images/butterflies/description/descriptions.txt',
      );
      final parts = raw
          .split(RegExp(r'\n\s*\n'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final descriptions = <int, String>{};
      for (var i = 0; i < parts.length && i < 9; i += 1) {
        descriptions[i + 1] = parts[i];
      }
      if (descriptions.length == 9) {
        _butterflyDescriptionsCache = descriptions;
        return _butterflyDescriptionsCache!;
      }
    } catch (_) {
      // Fallback to built-in descriptions.
    }
    _butterflyDescriptionsCache = Map<int, String>.from(
      _defaultButterflyDescriptions,
    );
    return _butterflyDescriptionsCache!;
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
