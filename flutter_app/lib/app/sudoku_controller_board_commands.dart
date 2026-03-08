part of 'sudoku_controller.dart';

extension SudokuControllerBoardCommands on SudokuController {
  void onCellTapped(Coord coord) {
    if (_session.gameOver) {
      return;
    }
    final cell = _session.history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    _session = _session.copyWith(selected: coord);
    _render('Cell selected');
  }

  void onBoardCellTapped(Coord coord) {
    if (_session.gameOver) {
      return;
    }
    final cell = _session.history.present.board.cellAtCoord(coord);
    if (cell.given) {
      return;
    }
    onCellTapped(coord);
    if (cell.notes.isNotEmpty && !_settings.state.notesMode) {
      setNotesMode(true);
    }
    _candidatePanel = _candidatePanelCoordinator.show(
      board: _session.history.present.board,
      coord: coord,
    );
    _render('Candidate panel updated');
  }

  void onDigitPressed(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onDigitPressed(
        gameOver: _session.gameOver,
        selected: _session.selected,
        notesMode: _settings.state.notesMode,
        history: _session.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onPlaceDigit(Digit digit) {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onPlaceDigit(
        gameOver: _session.gameOver,
        selected: _session.selected,
        history: _session.history,
        digit: digit,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onClearPressed() {
    _applyBoardEditOutcome(
      _boardEditCoordinator.onClearPressed(
        gameOver: _session.gameOver,
        selected: _session.selected,
        notesMode: _settings.state.notesMode,
        history: _session.history,
        canChangeDifficulty: _settings.state.canChangeDifficulty,
        canChangePuzzleMode: _settings.state.canChangePuzzleMode,
      ),
    );
  }

  void onToggleNotesMode() {
    if (_session.gameOver) {
      return;
    }
    _settings.toggleNotesMode();
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void setNotesMode(bool enabled) {
    if (_session.gameOver) {
      return;
    }
    _settings.setNotesMode(enabled);
    _render(_settings.state.notesMode ? 'Notes mode on' : 'Notes mode off');
  }

  void onCandidateDigitPressed(int digit) {
    if (digit == 0) {
      onClearPressed();
    } else {
      onDigitPressed(digit);
    }
    if (!_settings.state.notesMode || digit == 0) {
      _candidatePanel = const CandidatePanelState.hidden();
      _render('Candidate panel hidden');
      return;
    }
    _candidatePanel = _candidatePanelCoordinator.refresh(
      board: _session.history.present.board,
      current: _candidatePanel,
    );
    _render('Candidate panel updated');
  }

  void onCandidateDigitLongPressed(int digit) {
    if (!_settings.state.notesMode || digit == 0) {
      return;
    }
    onPlaceDigit(digit);
    _candidatePanel = const CandidatePanelState.hidden();
    _render('Candidate panel hidden');
  }

  void _applyBoardEditOutcome(BoardEditOutcome outcome) {
    if (outcome.statusMessage != null) {
      _render(outcome.statusMessage!);
      return;
    }
    if (outcome.result == null) {
      return;
    }

    _applyResult(outcome.result!);
    var settingsChanged = false;
    if (outcome.lockDifficulty) {
      _settings.setDifficultyLocked(true);
      settingsChanged = true;
    }
    if (outcome.lockPuzzleMode) {
      _settings.setPuzzleModeLocked(true);
      settingsChanged = true;
    }
    if (settingsChanged) {
      _saveGameSession();
    }
  }

  void _applyResult(MoveResult res, {String? statusOverride}) {
    _session = _gameFlowCoordinator.applyMoveResult(
      session: _session,
      result: res,
    );
    _saveGameSession();
    _render(statusOverride ?? res.message);
  }
}
