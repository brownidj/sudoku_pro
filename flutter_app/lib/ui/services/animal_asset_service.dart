import 'dart:ui' as ui;

import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';

class AnimalAssetBundle {
  final Map<String, Map<int, ui.Image>> animalImages;
  final Map<String, Map<int, Map<int, ui.Image>>> noteImages;
  final Map<int, String> butterflyDescriptions;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;

  const AnimalAssetBundle({
    required this.animalImages,
    required this.noteImages,
    this.butterflyDescriptions = const {},
    this.japaneseKanjiEntries = const {},
  });
}

class AnimalAssetService {
  final JapaneseKanjiService _japaneseKanjiService;

  const AnimalAssetService({
    JapaneseKanjiService japaneseKanjiService = const JapaneseKanjiService(),
  }) : _japaneseKanjiService = japaneseKanjiService;

  Future<AnimalAssetBundle> load() async {
    final images = await AnimalImageCache.loadAll();
    Map<String, Map<int, Map<int, ui.Image>>> notes = const {};
    Map<int, String> butterflyDescriptions = const {};

    try {
      notes = await AnimalImageCache.loadNotesAll();
    } on Exception catch (error) {
      AppDebug.log('Failed to load note icons: $error');
      notes = const {};
    }

    try {
      butterflyDescriptions = await AnimalImageCache.loadButterflyDescriptions();
    } on Exception catch (error) {
      AppDebug.log('Failed to load butterfly descriptions: $error');
      butterflyDescriptions = const {};
    }

    var japaneseKanjiEntries = const <int, JapaneseKanjiEntry>{};
    try {
      japaneseKanjiEntries = await _japaneseKanjiService.load();
    } on Exception catch (error) {
      AppDebug.log('Failed to load Japanese kanji data: $error');
      japaneseKanjiEntries = const {};
    }

    return AnimalAssetBundle(
      animalImages: images,
      noteImages: notes,
      butterflyDescriptions: butterflyDescriptions,
      japaneseKanjiEntries: japaneseKanjiEntries,
    );
  }
}
