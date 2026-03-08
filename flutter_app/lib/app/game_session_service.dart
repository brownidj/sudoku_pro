import 'dart:async';
import 'package:flutter_app/app/game_session_codec.dart';
import 'package:flutter_app/app/game_session_models.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class GameSessionService {
  final PreferencesStore _prefs;
  final GameSessionCodec _codec;

  GameSessionService(PreferencesStore prefs, GridUtils gridUtils)
    : _prefs = prefs,
      _codec = GameSessionCodec(gridUtils);

  Future<RestoredGameSession?> restore(SettingsState fallback) async {
    final raw = await _prefs.loadGameSession();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return _codec.decode(raw, fallback);
  }

  void save({
    required History history,
    required Coord? selected,
    required bool gameOver,
    required Grid? initialGrid,
    required SettingsState settings,
  }) {
    unawaited(
      _prefs.saveGameSession(
        _codec.encode(
          history: history,
          selected: selected,
          gameOver: gameOver,
          initialGrid: initialGrid,
          settings: settings,
        ),
      ),
    );
  }
}
