import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/game_session_service.dart';
import 'package:flutter_app/app/grid_utils.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/application/game_service.dart';

import 'support/sudoku_controller_test_support.dart';

void main() {
  test('restore normalizes hard difficulty puzzle mode to unique', () async {
    final prefs = FakePreferencesStore(
      savedSession: jsonEncode({
        'version': 1,
        'board': List.generate(
          9,
          (_) => List.generate(9, (_) => {'v': null, 'g': false, 'n': []}),
        ),
        'initialGrid': List.generate(9, (_) => List<int?>.filled(9, null)),
        'selected': {'row': 0, 'col': 0},
        'gameOver': false,
        'settings': {
          'notesMode': false,
          'difficulty': 'hard',
          'canChangeDifficulty': true,
          'canChangePuzzleMode': true,
          'styleName': 'Classic',
          'contentMode': 'butterflies',
          'animalStyle': 'simple',
          'puzzleMode': 'multi',
        },
      }),
    );
    final service = GameSessionService(prefs, GridUtils());

    final restored = await service.restore(
      const SettingsState(
        notesMode: false,
        difficulty: 'easy',
        canChangeDifficulty: true,
        canChangePuzzleMode: true,
        styleName: 'Modern',
        contentMode: 'numbers',
        animalStyle: 'cute',
        puzzleMode: 'multi',
      ),
    );

    expect(restored, isNotNull);
    expect(restored!.settings.difficulty, 'hard');
    expect(restored.settings.puzzleMode, 'unique');
    expect(restored.settings.contentMode, 'butterflies');
  });

  test('save encodes selected coord and settings into session JSON', () async {
    final prefs = FakePreferencesStore();
    final service = GameSessionService(prefs, GridUtils());
    final gameService = GameService();
    final history = gameService.initialHistory();

    service.save(
      history: history,
      selected: null,
      gameOver: false,
      initialGrid: null,
      settings: const SettingsState(
        notesMode: true,
        difficulty: 'medium',
        canChangeDifficulty: false,
        canChangePuzzleMode: false,
        styleName: 'Classic',
        contentMode: 'animals',
        animalStyle: 'simple',
        puzzleMode: 'unique',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final sessionJson = jsonDecode(prefs.savedSession!);
    expect(sessionJson['version'], 1);
    expect(sessionJson['selected'], isNull);
    expect(sessionJson['settings']['notesMode'], isTrue);
    expect(sessionJson['settings']['difficulty'], 'medium');
    expect(sessionJson['settings']['styleName'], 'Classic');
    expect(sessionJson['settings']['animalStyle'], 'simple');
    expect(sessionJson['settings']['puzzleMode'], 'unique');
  });
}
