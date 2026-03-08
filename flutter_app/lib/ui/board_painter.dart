import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/ui/board_layout.dart';
import 'package:flutter_app/ui/board_theme.dart';
import 'package:flutter_app/ui/note_layout.dart';
import 'package:flutter_app/ui/styles.dart';

class SudokuBoardPainter extends CustomPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  SudokuBoardPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
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

    final boardPaint = Paint()..color = style.boardBg;
    canvas.drawRect(boardRect, boardPaint);

    _BoardCellsPainter(
      state: state,
      style: style,
      animalImages: animalImages,
      noteImagesBySize: noteImagesBySize,
      devicePixelRatio: devicePixelRatio,
    ).paint(canvas, layout, BoardTheme(style));
    _BoardGridPainter(style: style).paint(canvas, layout);
    // Notes badge removed; notes mode is indicated via the UI toggle.
  }

  // Notes badge removed.

  @override
  bool shouldRepaint(covariant SudokuBoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.style != style ||
        oldDelegate.animalImages != animalImages ||
        oldDelegate.noteImagesBySize != noteImagesBySize;
  }
}

class _BoardCellsPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  const _BoardCellsPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, BoardLayout layout, BoardTheme theme) {
    final selected = state.selected;
    final selRow = selected?.row;
    final selCol = selected?.col;
    final selBoxRow = selRow == null ? null : selRow ~/ 3;
    final selBoxCol = selCol == null ? null : selCol ~/ 3;
    final cellSize = layout.cellSize;
    final contentPainter = _BoardContentPainter(
      state: state,
      style: style,
      animalImages: animalImages,
      noteImagesBySize: noteImagesBySize,
      devicePixelRatio: devicePixelRatio,
    );

    for (var r = 0; r < 9; r += 1) {
      final row = state.board.cells[r];
      for (var c = 0; c < 9; c += 1) {
        final cell = row[c];
        final rect = Rect.fromLTWH(
          layout.originX + c * cellSize,
          layout.originY + r * cellSize,
          cellSize,
          cellSize,
        );

        final model = theme.cellModel(
          cell: cell,
          gameOver: state.gameOver,
          peerRowCol:
              selRow != null && selCol != null && (r == selRow || c == selCol),
          peerBox:
              selBoxRow != null &&
              selBoxCol != null &&
              (r ~/ 3 == selBoxRow) &&
              (c ~/ 3 == selBoxCol),
        );

        final hasImageValue =
            cell.value != null && animalImages.containsKey(cell.value);
        final background =
            state.contentMode == 'butterflies' && hasImageValue
            ? Colors.white
            : model.background;
        canvas.drawRect(rect, Paint()..color = background);
        _paintOverlay(canvas, rect, model);
        contentPainter.paint(canvas, rect, cell, cellSize);
      }
    }
  }

  void _paintOverlay(Canvas canvas, Rect rect, dynamic model) {
    if (state.gameOver) {
      Color? highlight;
      if (model.showIncorrect) {
        highlight = style.highlightIncorrect;
      } else if (model.showSolution) {
        highlight = style.highlightSolution;
      } else if (model.showGiven) {
        highlight = style.highlightGiven;
      } else if (model.showCorrect) {
        highlight = style.highlightCorrect;
      }
      if (highlight != null) {
        canvas.drawRect(rect, Paint()..color = highlight);
      }
      return;
    }
    if (model.showSelection) {
      _drawOutline(canvas, rect, style.outlineSelected, 3);
    } else if (model.showConflict) {
      _drawOutline(canvas, rect, style.outlineConflict, 3);
    }
  }

  void _drawOutline(Canvas canvas, Rect rect, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawRect(rect, paint);
  }
}

class _BoardContentPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, ui.Image> animalImages;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  const _BoardContentPainter({
    required this.state,
    required this.style,
    required this.animalImages,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, Rect rect, CellVm cell, double cellSize) {
    if (cell.value != null) {
      if (state.contentMode == 'numbers') {
        _drawValue(canvas, rect, cell.value!, cell.given, cellSize);
      } else if (animalImages.containsKey(cell.value)) {
        _drawAnimal(canvas, rect, animalImages[cell.value]!, cellSize);
      }
      return;
    }
    if (cell.notes.isNotEmpty) {
      _BoardNotesPainter(
        state: state,
        style: style,
        noteImagesBySize: noteImagesBySize,
        devicePixelRatio: devicePixelRatio,
      ).paint(canvas, rect, cell.notes);
    }
  }

  void _drawValue(
    Canvas canvas,
    Rect rect,
    int value,
    bool given,
    double cellSize,
  ) {
    final fontSize = cellSize * 0.6;
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          color: given ? style.givenColor : style.valueColor,
          fontWeight: given ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawAnimal(Canvas canvas, Rect rect, ui.Image image, double cellSize) {
    final targetSize = state.contentMode == 'butterflies'
        ? cellSize * 0.9
        : cellSize * 0.7;
    final target = Rect.fromLTWH(
      rect.left + (rect.width - targetSize) / 2,
      rect.top + (rect.height - targetSize) / 2,
      targetSize,
      targetSize,
    );
    paintImage(canvas: canvas, rect: target, image: image, fit: BoxFit.contain);
  }
}

class _BoardNotesPainter {
  final UiState state;
  final BoardStyle style;
  final Map<int, Map<int, ui.Image>> noteImagesBySize;
  final double devicePixelRatio;

  const _BoardNotesPainter({
    required this.state,
    required this.style,
    required this.noteImagesBySize,
    required this.devicePixelRatio,
  });

  void paint(Canvas canvas, Rect rect, List<int> notes) {
    final notesSorted = List<int>.from(notes)..sort();
    if (notesSorted.isEmpty) {
      return;
    }
    final gridSize = noteGridSize(notesSorted.length);
    final subCellSize = rect.width / gridSize;
    if (state.contentMode == 'numbers') {
      _drawNumberNotes(canvas, rect, notesSorted, gridSize, subCellSize);
      return;
    }

    final logicalSize = subCellSize * 0.95;
    final sizePx = bestNoteSize(
      logicalSize * devicePixelRatio,
      noteImagesBySize.keys,
    );
    if (sizePx == 0 || !noteImagesBySize.containsKey(sizePx)) {
      return;
    }

    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final cellRect = Rect.fromLTWH(
        rect.left + col * subCellSize,
        rect.top + row * subCellSize,
        subCellSize,
        subCellSize,
      );
      final image = noteImagesBySize[sizePx]?[digit];
      if (image == null) {
        _drawNoteDigit(canvas, cellRect, digit);
        continue;
      }
      final target = Rect.fromLTWH(
        cellRect.left + (subCellSize - logicalSize) / 2,
        cellRect.top + (subCellSize - logicalSize) / 2,
        logicalSize,
        logicalSize,
      );
      paintImage(canvas: canvas, rect: target, image: image, fit: BoxFit.contain);
    }
  }

  void _drawNumberNotes(
    Canvas canvas,
    Rect rect,
    List<int> notesSorted,
    int gridSize,
    double subCellSize,
  ) {
    final maxNotes = gridSize * gridSize;
    for (var i = 0; i < notesSorted.length && i < maxNotes; i += 1) {
      final digit = notesSorted[i];
      _drawNoteDigit(
        canvas,
        Rect.fromLTWH(
          rect.left + (i % gridSize) * subCellSize,
          rect.top + (i ~/ gridSize) * subCellSize,
          subCellSize,
          subCellSize,
        ),
        digit,
      );
    }
  }

  void _drawNoteDigit(Canvas canvas, Rect rect, int digit) {
    final fontSize = rect.width * 0.6;
    final textPainter = TextPainter(
      text: TextSpan(
        text: digit.toString(),
        style: TextStyle(
          color: style.valueColor.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: rect.width);

    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }
}

class _BoardGridPainter {
  final BoardStyle style;

  const _BoardGridPainter({required this.style});

  void paint(Canvas canvas, BoardLayout layout) {
    final thinPaint = Paint()
      ..color = style.gridThin
      ..strokeWidth = 1.0;
    final thickPaint = Paint()
      ..color = style.gridThick
      ..strokeWidth = 3.0;

    for (var i = 1; i < 9; i += 1) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thinPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thinPaint,
      );
    }

    for (var i = 0; i <= 9; i += 3) {
      final x = layout.originX + i * layout.cellSize;
      final y = layout.originY + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.originX, y),
        Offset(layout.originX + layout.boardSize, y),
        thickPaint,
      );
      canvas.drawLine(
        Offset(x, layout.originY),
        Offset(x, layout.originY + layout.boardSize),
        thickPaint,
      );
    }
  }
}
