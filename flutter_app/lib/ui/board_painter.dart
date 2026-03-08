import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_painting/board_cells_painter.dart';
import 'package:flutter_app/ui/board_painting/board_grid_painter.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardPainter extends CustomPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;
  final double devicePixelRatio;

  SudokuBoardPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.japaneseKanjiEntries,
    required this.devicePixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final layout = layoutForSize(size);
    final boardRect = Rect.fromLTWH(
      layout.originX,
      layout.originY,
      layout.boardSize,
      layout.boardSize,
    );

    canvas.drawRect(boardRect, Paint()..color = style.boardBg);

    BoardCellsPainter(
      state: state,
      style: style,
      animalImages: animalImages,
      noteImagesBySize: noteImagesBySize,
      japaneseKanjiEntries: japaneseKanjiEntries,
      devicePixelRatio: devicePixelRatio,
    ).paint(canvas, layout, BoardTheme(style));
    BoardGridPainter(style: style).paint(canvas, layout);
  }

  @override
  bool shouldRepaint(covariant SudokuBoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.style != style ||
        oldDelegate.animalImages != animalImages ||
        oldDelegate.noteImagesBySize != noteImagesBySize ||
        oldDelegate.japaneseKanjiEntries != japaneseKanjiEntries ||
        oldDelegate.devicePixelRatio != devicePixelRatio;
  }
}
