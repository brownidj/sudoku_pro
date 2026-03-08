import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_painting/board_content_painter.dart';
import 'package:flutter_app/ui/board_painting/board_paint_constants.dart';
import 'package:flutter_app/ui/board_painting/board_selection_info.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/services/japanese_kanji_service.dart';
import 'package:flutter_app/ui/styles.dart';

class BoardCellsPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final Map<int, JapaneseKanjiEntry> japaneseKanjiEntries;
  final double devicePixelRatio;

  const BoardCellsPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.japaneseKanjiEntries,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, BoardLayout layout, BoardTheme theme) {
    final selection = BoardSelectionInfo.from(state.selected);
    final contentPainter = BoardContentPainter(
      state: state,
      style: style,
      animalImages: animalImages,
      noteImagesBySize: noteImagesBySize,
      japaneseKanjiEntries: japaneseKanjiEntries,
      devicePixelRatio: devicePixelRatio,
    );

    for (var rowIndex = 0; rowIndex < boardGridDimension; rowIndex += 1) {
      final row = state.board.cells[rowIndex];
      for (var colIndex = 0; colIndex < boardGridDimension; colIndex += 1) {
        final cell = row[colIndex];
        final rect = Rect.fromLTWH(
          layout.originX + colIndex * layout.cellSize,
          layout.originY + rowIndex * layout.cellSize,
          layout.cellSize,
          layout.cellSize,
        );

        final model = theme.cellModel(
          cell: cell,
          gameOver: state.gameOver,
          peerRowCol: selection.isPeerRowOrColumn(rowIndex, colIndex),
          peerBox: selection.isPeerBox(rowIndex, colIndex),
        );

        canvas.drawRect(
          rect,
          Paint()..color = _resolveBackground(cell, model.background),
        );
        _paintOverlay(canvas, rect, model);
        contentPainter.paint(canvas, rect, cell, layout.cellSize);
      }
    }
  }

  Color _resolveBackground(CellVm cell, Color defaultBackground) {
    final hasImageValue =
        cell.value != null && animalImages.containsKey(cell.value);
    if (state.contentMode == 'butterflies' && hasImageValue) {
      return Colors.white;
    }
    return defaultBackground;
  }

  void _paintOverlay(Canvas canvas, Rect rect, CellRenderModel model) {
    if (state.gameOver) {
      final highlight = _gameOverHighlight(model);
      if (highlight != null) {
        canvas.drawRect(rect, Paint()..color = highlight);
      }
      return;
    }

    if (model.showSelection) {
      _drawOutline(canvas, rect, style.outlineSelected);
      return;
    }

    if (model.showConflict) {
      _drawOutline(canvas, rect, style.outlineConflict);
    }
  }

  Color? _gameOverHighlight(CellRenderModel model) {
    if (model.showIncorrect) {
      return style.highlightIncorrect;
    }
    if (model.showSolution) {
      return style.highlightSolution;
    }
    if (model.showGiven) {
      return style.highlightGiven;
    }
    if (model.showCorrect) {
      return style.highlightCorrect;
    }
    return null;
  }

  void _drawOutline(Canvas canvas, Rect rect, Color color) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectionOutlineWidth,
    );
  }
}
