import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';
import 'package:flutter_app/ui/widgets/sudoku_board.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardArea extends StatelessWidget {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;
  final bool candidateVisible;
  final List<int> candidateDigits;
  final Set<int> selectedNotes;
  final ValueChanged<int> onDigitSelected;
  final ValueChanged<int>? onDigitLongPressed;
  final ValueChanged<Coord> onTapCell;
  final void Function(Offset, Coord) onLongPressCell;

  const SudokuBoardArea({
    super.key,
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
    required this.candidateVisible,
    required this.candidateDigits,
    required this.selectedNotes,
    required this.onDigitSelected,
    required this.onDigitLongPressed,
    required this.onTapCell,
    required this.onLongPressCell,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final isTablet = media.size.shortestSide >= 600;
        final reservedHeight = isTablet
            ? (candidateVisible ? 15 + 68 : 0)
            : 0.0;
        final maxBoard = isTablet
            ? (constraints.maxHeight - reservedHeight)
            : constraints.maxHeight;
        final boardWidth = isTablet
            ? max(0.0, min(constraints.maxWidth, maxBoard))
            : constraints.maxWidth;
        final cellWidth = boardWidth / 9.0;
        AppDebug.log(
          'Board: ${boardWidth.toStringAsFixed(2)} lp, '
          'Cell: ${cellWidth.toStringAsFixed(2)} lp '
          '(${(cellWidth * devicePixelRatio).toStringAsFixed(0)} px @ dpr=$devicePixelRatio)',
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: boardWidth,
              height: boardWidth,
              child: SudokuBoard(
                state: state,
                style: style,
                animalImages: animalImages,
                noteImagesBySize: noteImagesBySize,
                devicePixelRatio: devicePixelRatio,
                onTapCell: onTapCell,
                onLongPressCell: onLongPressCell,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: boardWidth,
              child: Row(
                children: [
                  Text(
                    state.puzzleMode.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    state.difficulty.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CandidatePanel(
              visible: candidateVisible,
              candidateDigits: candidateDigits,
              showImages: state.contentMode != 'numbers',
              contentMode: state.contentMode,
              notesMode: state.notesMode,
              selectedNotes: selectedNotes,
              animalImages: animalImages,
              onDigitSelected: onDigitSelected,
              onDigitLongPressed: onDigitLongPressed,
            ),
          ],
        );
      },
    );
  }
}
