import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_info.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/app/tile_info_presentation_coordinator.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/animal_asset_service.dart';
import 'package:flutter_app/ui/services/animal_assets_controller.dart';
import 'package:flutter_app/ui/services/tile_info_presentation_service.dart';
import 'package:flutter_app/ui/styles.dart';
import 'package:flutter_app/ui/widgets/action_bar.dart';
import 'package:flutter_app/ui/widgets/legend.dart';
import 'package:flutter_app/ui/widgets/sudoku_board_area.dart';
import 'package:flutter_app/ui/widgets/sudoku_drawer.dart';
import 'package:flutter_app/ui/widgets/top_controls.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({
    super.key,
    required this.controller,
    AnimalAssetService? animalAssetService,
  }) : animalAssetService = animalAssetService ?? const AnimalAssetService();

  final SudokuController controller;
  final AnimalAssetService animalAssetService;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  final TileInfoPresentationCoordinator _tileInfoCoordinator =
      const TileInfoPresentationCoordinator();
  late final AnimalAssetsController _animalAssets;
  late final TileInfoPresentationService _tileInfoPresenter;

  @override
  void initState() {
    super.initState();
    _animalAssets = AnimalAssetsController(widget.animalAssetService);
    _tileInfoPresenter = TileInfoPresentationService();
    _animalAssets.startLoading();
  }

  @override
  void dispose() {
    _tileInfoPresenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _animalAssets]),
      builder: (context, _) {
        final state = widget.controller.state;
        final style = styleForName(state.styleName);
        final waitingForAssets = _animalAssets.isWaitingFor(state);

        if (waitingForAssets) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Please wait...'),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Align(
              alignment: Alignment.centerLeft,
              child: Text(AppInfo.launchTitle),
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
                      animalImages: _animalAssets.imagesFor(state),
                      noteImagesBySize: _animalAssets.noteImagesFor(state),
                      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                      candidateVisible: state.candidateVisible,
                      candidateDigits: state.candidateDigits,
                      selectedNotes: state.candidateSelectedNotes,
                      onDigitSelected: widget.controller.onCandidateDigitPressed,
                      onDigitLongPressed: state.notesMode
                          ? widget.controller.onCandidateDigitLongPressed
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
    final presentation = _tileInfoCoordinator.forLongPress(
      state: state,
      coord: coord,
      butterflyDescriptions: _animalAssets.state.butterflyDescriptions,
    );
    _tileInfoPresenter.present(
      context: context,
      globalPosition: globalPosition,
      presentation: presentation,
      butterflyImages: _animalAssets.butterflyImages(),
    );
  }

  Future<void> _handleCellTap(Coord coord) async {
    final state = widget.controller.state;
    if (state.gameOver) {
      return;
    }
    final cell = state.board.cells[coord.row][coord.col];
    if (cell.given) {
      return;
    }
    if (state.contentMode != 'numbers') {
      await _animalAssets.ensureLoaded();
    }
    if (!mounted) {
      return;
    }
    widget.controller.onBoardCellTapped(coord);
  }

  void _handleCheckOrSolution(UiState state) {
    if (state.gameOver) {
      widget.controller.onShowSolution();
      return;
    }
    widget.controller.onCheckSolution();
  }
}
