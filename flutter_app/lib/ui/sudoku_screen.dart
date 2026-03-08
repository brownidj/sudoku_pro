import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';
import 'package:flutter_app/ui/candidate_selection_controller.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/tooltip_overlay_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key, required this.controller});

  final SudokuController controller;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final Map<String, Map<int, ui.Image>> _animalImages = {};
  final Map<String, Map<int, Map<int, ui.Image>>> _noteImages = {};
  final AnimalAssetService _animalAssetService = const AnimalAssetService();
  final TooltipOverlayService _tooltipService = TooltipOverlayService();
  Future<void>? _animalLoad;
  late final CandidateSelectionController _candidateController;

  @override
  void initState() {
    super.initState();
    _animalLoad = _loadAnimalImages();
    _candidateController = CandidateSelectionController()
      ..addListener(_onCandidateChanged);
  }

  @override
  void dispose() {
    _candidateController.removeListener(_onCandidateChanged);
    _candidateController.dispose();
    _tooltipService.dispose();
    super.dispose();
  }

  void _onCandidateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAnimalImages() async {
    final bundle = await _animalAssetService.load();
    _animalImages
      ..clear()
      ..addAll(bundle.animalImages);
    _noteImages
      ..clear()
      ..addAll(bundle.noteImages);
    if (mounted) {
      setState(() {});
    }
  }

  String _imageVariantKey(UiState state) {
    if (state.contentMode == 'butterflies') {
      return 'butterflies';
    }
    return state.animalStyle;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final style = styleForName(state.styleName);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Align(
              alignment: Alignment.centerLeft,
              child: Text('ZuDoKu 0.4.4'),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                ),
              ),
            ],
          ),
          drawer: SudokuDrawer(
            state: state,
            onPuzzleModeChanged: widget.controller.onPuzzleModeChanged,
            onSetDifficulty: widget.controller.onSetDifficulty,
            onAnimalStyleChanged: widget.controller.onAnimalStyleChanged,
            onStyleChanged: widget.controller.onStyleChanged,
          ),
          body: SafeArea(
            child: Column(
              children: [
                TopControls(
                  state: state,
                  onNewGame: widget.controller.onNewGame,
                  onContentModeChanged: widget.controller.onContentModeChanged,
                  onSetDifficulty: widget.controller.onSetDifficulty,
                  onStyleChanged: widget.controller.onStyleChanged,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SudokuBoardArea(
                      state: state,
                      style: style,
                      animalImages:
                          _animalImages[_imageVariantKey(state)] ?? const {},
                      noteImagesBySize:
                          _noteImages[_imageVariantKey(state)] ?? const {},
                      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                      candidateVisible:
                          _candidateController.visible &&
                          _candidateController.candidateCoord != null &&
                          !state.gameOver,
                      candidateDigits: _candidateController.candidateDigits,
                      selectedNotes: _selectedNotes(state),
                      onDigitSelected: (digit) {
                        if (digit == 0) {
                          widget.controller.onClearPressed();
                        } else {
                          widget.controller.onDigitPressed(digit);
                        }
                        if (!state.notesMode || digit == 0) {
                          _candidateController.hide();
                        } else {
                          _candidateController.refresh();
                        }
                      },
                      onDigitLongPressed: state.notesMode
                          ? (digit) {
                              if (digit == 0) {
                                return;
                              }
                              widget.controller.onPlaceDigit(digit);
                              _candidateController.hide();
                            }
                          : null,
                      onTapCell: _handleCellTap,
                      onLongPressCell: _handleCellLongPress,
                    ),
                  ),
                ),
                if (state.gameOver) Legend(style: style),
                ActionBar(
                  state: state,
                  onToggleNotesMode: widget.controller.onToggleNotesMode,
                  onClear: widget.controller.onClearPressed,
                  onCheckOrSolution: () => _handleCheckOrSolution(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCellLongPress(Offset globalPosition, Coord coord) {
    final state = widget.controller.state;
    if (state.contentMode == 'numbers') {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    final value = cell.value;
    if (value == null) {
      return;
    }
    final name = AnimalImageCache.displayNameForDigit(state.contentMode, value);
    _tooltipService.show(
      context: context,
      globalPosition: globalPosition,
      text: name,
    );
  }

  Future<void> _handleCellTap(Coord coord) async {
    widget.controller.onCellTapped(coord);
    final state = widget.controller.state;
    if (state.gameOver) {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    if (cell.given) {
      return;
    }
    if (cell.notes.isNotEmpty && !state.notesMode) {
      widget.controller.setNotesMode(true);
    }
    if (state.contentMode != 'numbers' && _animalLoad != null) {
      await _animalLoad;
    }
    final candidates = _possibleDigits(state, coord);
    final withClear = [...candidates, 0];
    if (!mounted) {
      return;
    }
    _candidateController.show(coord, withClear);
  }

  List<int> _possibleDigits(UiState state, Coord coord) {
    final used = <int>{};
    final boxRow = (coord.row ~/ 3) * 3;
    final boxCol = (coord.col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r += 1) {
      for (var c = boxCol; c < boxCol + 3; c += 1) {
        final value = state.board.cells[r][c].value;
        if (value != null) {
          used.add(value);
        }
      }
    }
    final candidates = <int>[];
    for (var d = 1; d <= 9; d += 1) {
      if (!used.contains(d)) {
        candidates.add(d);
      }
    }
    return candidates;
  }

  void _handleCheckOrSolution(UiState state) {
    _candidateController.hide();
    if (state.gameOver) {
      widget.controller.onShowSolution();
      return;
    }
    widget.controller.onCheckSolution();
  }

  Set<int> _selectedNotes(UiState state) {
    final coord = _candidateController.candidateCoord;
    if (coord == null) {
      return {};
    }
    return state.board.cells[coord.row][coord.col].notes.toSet();
  }
}
