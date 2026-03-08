import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/preferences_store.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class RestoredGameSession {
  final History history;
  final Coord? selected;
  final bool gameOver;
  final Grid initialGrid;
  final SettingsState settings;

  const RestoredGameSession({
    required this.history,
    required this.selected,
    required this.gameOver,
    required this.initialGrid,
    required this.settings,
  });
}

class GameSessionService {
  static const int sessionVersion = 1;

  final PreferencesStore _prefs;
  final GridUtils _gridUtils;

  const GameSessionService(this._prefs, this._gridUtils);

  Future<RestoredGameSession?> restore(SettingsState fallback) async {
    final raw = await _prefs.loadGameSession();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (decoded['version'] != sessionVersion) {
        return null;
      }

      final boardRaw = decoded['board'];
      if (boardRaw is! List) {
        return null;
      }

      final restoredBoard = _boardFromJson(boardRaw);
      if (restoredBoard == null) {
        return null;
      }

      final initialGrid =
          _gridFromJson(decoded['initialGrid']) ??
          _gridUtils.gridFromBoard(restoredBoard);
      final settings = _settingsFromJson(decoded['settings'], fallback);

      return RestoredGameSession(
        history: History.initial(GameState(board: restoredBoard)),
        selected: _coordFromJson(decoded['selected']),
        gameOver: decoded['gameOver'] == true,
        initialGrid: initialGrid,
        settings: settings,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  void save({
    required History history,
    required Coord? selected,
    required bool gameOver,
    required Grid? initialGrid,
    required SettingsState settings,
  }) {
    final payload = <String, dynamic>{
      'version': sessionVersion,
      'board': _boardToJson(history.present.board),
      'initialGrid': _gridToJson(initialGrid),
      'selected': _coordToJson(selected),
      'gameOver': gameOver,
      'settings': <String, dynamic>{
        'notesMode': settings.notesMode,
        'difficulty': settings.difficulty,
        'canChangeDifficulty': settings.canChangeDifficulty,
        'canChangePuzzleMode': settings.canChangePuzzleMode,
        'styleName': settings.styleName,
        'contentMode': settings.contentMode,
        'animalStyle': settings.animalStyle,
        'puzzleMode': settings.puzzleMode,
      },
    };
    unawaited(_prefs.saveGameSession(jsonEncode(payload)));
  }

  SettingsState _settingsFromJson(Object? raw, SettingsState fallback) {
    if (raw is! Map<String, dynamic>) {
      return fallback;
    }

    final difficulty = _difficultyOrDefault(raw['difficulty'], fallback);
    var puzzleMode = _puzzleModeOrDefault(raw['puzzleMode'], difficulty);
    if (difficulty == 'hard') {
      puzzleMode = 'unique';
    }

    return fallback.copyWith(
      notesMode: raw['notesMode'] == true,
      difficulty: difficulty,
      canChangeDifficulty: raw['canChangeDifficulty'] != false,
      canChangePuzzleMode: raw['canChangePuzzleMode'] != false,
      styleName: _styleOrDefault(raw['styleName'], fallback),
      contentMode: _contentModeOrDefault(raw['contentMode'], fallback),
      animalStyle: _animalStyleOrDefault(raw['animalStyle'], fallback),
      puzzleMode: puzzleMode,
    );
  }

  List<List<Map<String, dynamic>>> _boardToJson(Board board) {
    return List<List<Map<String, dynamic>>>.generate(9, (r) {
      return List<Map<String, dynamic>>.generate(9, (c) {
        final cell = board.cellAt(r, c);
        final notes = cell.notes.toList()..sort();
        return <String, dynamic>{'v': cell.value, 'g': cell.given, 'n': notes};
      }, growable: false);
    }, growable: false);
  }

  Board? _boardFromJson(List<dynamic> raw) {
    if (raw.length != 9) {
      return null;
    }

    final rows = <List<Cell>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }

      final row = <Cell>[];
      for (var c = 0; c < 9; c += 1) {
        final cellRaw = rowRaw[c];
        if (cellRaw is! Map<String, dynamic>) {
          return null;
        }

        final valueRaw = cellRaw['v'];
        final notesRaw = cellRaw['n'];
        final notes = <int>{};
        if (notesRaw is List) {
          for (final note in notesRaw) {
            if (note is int && note >= 1 && note <= 9) {
              notes.add(note);
            }
          }
        }

        row.add(
          Cell(
            value: valueRaw is int ? valueRaw : null,
            given: cellRaw['g'] == true,
            notes: notes,
          ),
        );
      }
      rows.add(row);
    }
    return Board(cells: rows);
  }

  List<List<int?>>? _gridToJson(Grid? grid) {
    if (grid == null) {
      return null;
    }
    return List<List<int?>>.generate(9, (r) {
      return List<int?>.generate(9, (c) => grid[r][c], growable: false);
    }, growable: false);
  }

  Grid? _gridFromJson(Object? raw) {
    if (raw is! List || raw.length != 9) {
      return null;
    }

    final out = <List<int?>>[];
    for (var r = 0; r < 9; r += 1) {
      final rowRaw = raw[r];
      if (rowRaw is! List || rowRaw.length != 9) {
        return null;
      }

      final row = <int?>[];
      for (var c = 0; c < 9; c += 1) {
        final value = rowRaw[c];
        row.add(value is int ? value : null);
      }
      out.add(row);
    }
    return out;
  }

  Map<String, int>? _coordToJson(Coord? coord) {
    if (coord == null) {
      return null;
    }
    return <String, int>{'row': coord.row, 'col': coord.col};
  }

  Coord? _coordFromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }

    final row = raw['row'];
    final col = raw['col'];
    if (row is! int || col is! int) {
      return null;
    }
    if (row < 0 || row > 8 || col < 0 || col > 8) {
      return null;
    }
    return Coord(row, col);
  }

  String _difficultyOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'easy' || value == 'medium' || value == 'hard') {
      return value;
    }
    return fallback.difficulty;
  }

  String _puzzleModeOrDefault(Object? raw, String difficulty) {
    final value = raw is String ? raw : '';
    if (value == 'unique' || value == 'multi') {
      return value;
    }
    return difficulty == 'easy' ? 'multi' : 'unique';
  }

  String _styleOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'Modern' || value == 'Classic' || value == 'High Contrast') {
      return value;
    }
    return fallback.styleName;
  }

  String _contentModeOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'animals' || value == 'butterflies' || value == 'numbers') {
      return value;
    }
    return fallback.contentMode;
  }

  String _animalStyleOrDefault(Object? raw, SettingsState fallback) {
    final value = raw is String ? raw : '';
    if (value == 'cute' || value == 'simple') {
      return value;
    }
    return fallback.animalStyle;
  }
}
