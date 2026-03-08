import 'package:flutter_app/application/state.dart';
import 'package:flutter_app/domain/types.dart';

class GameplaySessionState {
  final History history;
  final Coord? selected;
  final Set<Coord> conflicts;
  final bool gameOver;
  final Set<Coord> incorrectCells;
  final Set<Coord> solutionAddedCells;
  final Set<Coord> correctCells;
  final Grid? solutionGrid;
  final Grid? initialGrid;
  final bool hadSavedSessionAtLaunch;

  const GameplaySessionState({
    required this.history,
    required this.selected,
    required this.conflicts,
    required this.gameOver,
    required this.incorrectCells,
    required this.solutionAddedCells,
    required this.correctCells,
    required this.solutionGrid,
    required this.initialGrid,
    required this.hadSavedSessionAtLaunch,
  });

  factory GameplaySessionState.initial(History history) {
    return GameplaySessionState(
      history: history,
      selected: null,
      conflicts: const {},
      gameOver: false,
      incorrectCells: const {},
      solutionAddedCells: const {},
      correctCells: const {},
      solutionGrid: null,
      initialGrid: null,
      hadSavedSessionAtLaunch: false,
    );
  }

  GameplaySessionState copyWith({
    History? history,
    Coord? selected,
    bool clearSelected = false,
    Set<Coord>? conflicts,
    bool? gameOver,
    Set<Coord>? incorrectCells,
    Set<Coord>? solutionAddedCells,
    Set<Coord>? correctCells,
    Grid? solutionGrid,
    bool clearSolutionGrid = false,
    Grid? initialGrid,
    bool clearInitialGrid = false,
    bool? hadSavedSessionAtLaunch,
  }) {
    return GameplaySessionState(
      history: history ?? this.history,
      selected: clearSelected ? null : (selected ?? this.selected),
      conflicts: Set.unmodifiable(conflicts ?? this.conflicts),
      gameOver: gameOver ?? this.gameOver,
      incorrectCells: Set.unmodifiable(incorrectCells ?? this.incorrectCells),
      solutionAddedCells: Set.unmodifiable(
        solutionAddedCells ?? this.solutionAddedCells,
      ),
      correctCells: Set.unmodifiable(correctCells ?? this.correctCells),
      solutionGrid: clearSolutionGrid ? null : (solutionGrid ?? this.solutionGrid),
      initialGrid: clearInitialGrid ? null : (initialGrid ?? this.initialGrid),
      hadSavedSessionAtLaunch:
          hadSavedSessionAtLaunch ?? this.hadSavedSessionAtLaunch,
    );
  }
}
