import 'dart:ui' as ui;

import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/ui/animal_cache.dart';

class AnimalAssetBundle {
  final Map<String, Map<int, ui.Image>> animalImages;
  final Map<String, Map<int, Map<int, ui.Image>>> noteImages;
  final Map<int, String> butterflyDescriptions;

  const AnimalAssetBundle({
    required this.animalImages,
    required this.noteImages,
    this.butterflyDescriptions = const {},
  });
}

class AnimalAssetService {
  const AnimalAssetService();

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

    return AnimalAssetBundle(
      animalImages: images,
      noteImages: notes,
      butterflyDescriptions: butterflyDescriptions,
    );
  }
}
