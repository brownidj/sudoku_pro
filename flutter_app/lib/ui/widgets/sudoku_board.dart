import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_painter.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoard extends StatelessWidget {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;
  final double devicePixelRatio;
  final ValueChanged<Coord> onTapCell;
  final void Function(Offset, Coord) onLongPressCell;

  const SudokuBoard({
    super.key,
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.japaneseKanjiEntries,
    required this.devicePixelRatio,
    required this.onTapCell,
    required this.onLongPressCell,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = min(constraints.maxWidth, constraints.maxHeight);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: GestureDetector(
              onTapDown: (details) {
                final local = details.localPosition;
                final layout = layoutForSize(Size(boardSize, boardSize));
                final coord = coordFromOffset(layout, local);
                if (coord != null) {
                  onTapCell(coord);
                }
              },
              onLongPressStart: (details) {
                final local = details.localPosition;
                final layout = layoutForSize(Size(boardSize, boardSize));
                final coord = coordFromOffset(layout, local);
                if (coord != null) {
                  onLongPressCell(details.globalPosition, coord);
                }
              },
              child: CustomPaint(
                painter: SudokuBoardPainter(
                  state: state,
                  style: style,
                  animalImages: animalImages,
                  noteImagesBySize: noteImagesBySize,
                  japaneseKanjiEntries: japaneseKanjiEntries,
                  devicePixelRatio: devicePixelRatio,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
