import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';

class AnimalAssetsState {
  final bool ready;
  final Map<String, Map<int, ui.Image>> animalImages;
  final Map<String, Map<int, Map<int, ui.Image>>> noteImages;
  final Map<int, String> butterflyDescriptions;

  const AnimalAssetsState({
    required this.ready,
    required this.animalImages,
    required this.noteImages,
    required this.butterflyDescriptions,
  });

  const AnimalAssetsState.initial()
    : ready = false,
      animalImages = const {},
      noteImages = const {},
      butterflyDescriptions = const {};
}

class AnimalAssetsController extends ChangeNotifier {
  final AnimalAssetService _service;

  AnimalAssetsState _state = const AnimalAssetsState.initial();
  Future<void>? _loadFuture;

  AnimalAssetsController(this._service);

  AnimalAssetsState get state => _state;

  void startLoading() {
    _loadFuture ??= _load();
  }

  Future<void> ensureLoaded() async {
    startLoading();
    await _loadFuture;
  }

  bool isWaitingFor(UiState state) {
    return state.contentMode != 'numbers' && !_state.ready;
  }

  Map<int, ui.Image> imagesFor(UiState state) {
    return _state.animalImages[_variantKeyFor(state)] ?? const {};
  }

  Map<int, Map<int, ui.Image>> noteImagesFor(UiState state) {
    return _state.noteImages[_variantKeyFor(state)] ?? const {};
  }

  String? butterflyDescriptionFor(int digit) {
    return _state.butterflyDescriptions[digit];
  }

  Map<int, ui.Image> butterflyImages() {
    return _state.animalImages['butterflies'] ?? const {};
  }

  String _variantKeyFor(UiState state) {
    if (state.contentMode == 'butterflies') {
      return 'butterflies';
    }
    return state.animalStyle;
  }

  Future<void> _load() async {
    try {
      final bundle = await _service.load();
      _state = AnimalAssetsState(
        ready: true,
        animalImages: bundle.animalImages,
        noteImages: bundle.noteImages,
        butterflyDescriptions: bundle.butterflyDescriptions,
      );
    } catch (_) {
      _state = const AnimalAssetsState(
        ready: true,
        animalImages: {},
        noteImages: {},
        butterflyDescriptions: {},
      );
    }
    notifyListeners();
  }
}
