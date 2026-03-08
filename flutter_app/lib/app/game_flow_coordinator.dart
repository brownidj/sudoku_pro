import 'package:flutter_app/app/game_session_models.dart';
import 'package:flutter_app/app/gameplay_session_state.dart';
import 'package:flutter_app/app/settings_state.dart';
import 'package:flutter_app/app/solution_check_coordinator.dart';
import 'package:flutter_app/application/game_service.dart';
import 'package:flutter_app/application/puzzles.dart' as puzzles;
import 'package:flutter_app/application/results.dart';
import 'package:flutter_app/domain/types.dart';

class GameFlowResult {
  final GameplaySessionState session;
  final String statusMessage;
  final bool unlockDifficulty;
  final bool unlockPuzzleMode;

  const GameFlowResult({
    required this.session,
    required this.statusMessage,
    required this.unlockDifficulty,
    required this.unlockPuzzleMode,
  });
}

class GameFlowCoordinator {
  final GameService _gameService;
  final SolutionCheckCoordinator _solutionCoordinator;

  const GameFlowCoordinator(this._gameService, this._solutionCoordinator);

  GameplaySessionState restoreSession({
    required RestoredGameSession restoredSession,
    required bool hadSavedSessionAtLaunch,
  }) {
    return GameplaySessionState(
      history: restoredSession.history,
      selected: restoredSession.selected,
      conflicts: const {},
      gameOver: restoredSession.gameOver,
      incorrectCells: const {},
      solutionAddedCells: const {},
      correctCells: const {},
      solutionGrid: null,
      initialGrid: restoredSession.initialGrid,
      hadSavedSessionAtLaunch: hadSavedSessionAtLaunch,
    );
  }

  GameFlowResult startNewPuzzle({
    required GameplaySessionState session,
    required SettingsState settings,
  }) {
    final puzzle = puzzles.generatePuzzle(
      settings.difficulty,
      mode: settings.puzzleMode,
    );
    final result = _gameService.newGameFromGrid(puzzle.grid);
    final nextSession = GameplaySessionState(
      history: result.history,
      selected: null,
      conflicts: result.conflicts,
      gameOver: false,
      incorrectCells: const {},
      solutionAddedCells: const {},
      correctCells: const {},
      solutionGrid: null,
      initialGrid: List<List<Digit?>>.generate(9, (r) {
        return List<Digit?>.generate(
          9,
          (c) => puzzle.grid[r][c],
          growable: false,
        );
      }, growable: false),
      hadSavedSessionAtLaunch: session.hadSavedSessionAtLaunch,
    );

    return GameFlowResult(
      session: nextSession,
      statusMessage: 'New game (${puzzle.difficulty}): ${puzzle.puzzleId}',
      unlockDifficulty: true,
      unlockPuzzleMode: true,
    );
  }

  GameFlowResult checkSolution({
    required GameplaySessionState session,
  }) {
    final result = _solutionCoordinator.check(
      history: session.history,
      initialGrid: session.initialGrid,
      givens: _givenCoords(session.history.present.board),
    );
    final nextSession = session.copyWith(
      incorrectCells: result.incorrect,
      correctCells: result.correct,
      solutionAddedCells: const {},
      clearSolutionGrid: true,
      clearSelected: true,
      gameOver: true,
    );
    return GameFlowResult(
      session: nextSession,
      statusMessage: 'Check complete',
      unlockDifficulty: false,
      unlockPuzzleMode: true,
    );
  }

  GameFlowResult showSolution({
    required GameplaySessionState session,
  }) {
    final result = _solutionCoordinator.showSolution(
      history: session.history,
      initialGrid: session.initialGrid,
      givens: _givenCoords(session.history.present.board),
    );
    final nextSession = session.copyWith(
      incorrectCells: result.incorrect,
      correctCells: result.correct,
      solutionAddedCells: result.solutionAdded,
      solutionGrid: result.solutionGrid,
      clearSelected: true,
      gameOver: true,
    );
    return GameFlowResult(
      session: nextSession,
      statusMessage: 'Solution',
      unlockDifficulty: false,
      unlockPuzzleMode: true,
    );
  }

  GameplaySessionState applyMoveResult({
    required GameplaySessionState session,
    required MoveResult result,
  }) {
    return session.copyWith(
      history: result.history,
      conflicts: result.conflicts,
    );
  }

  Set<Coord> _givenCoords(Board board) {
    final givens = <Coord>{};
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        if (board.cellAt(r, c).given) {
          givens.add(Coord(r, c));
        }
      }
    }
    return givens;
  }
}
