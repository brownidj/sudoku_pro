class Coord {
  final int row;
  final int col;

  const Coord(this.row, this.col);

  @override
  bool operator ==(Object other) {
    return other is Coord && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

typedef Digit = int;

typedef Grid = List<List<Digit?>>;

bool isValidDigit(Digit digit) => digit >= 1 && digit <= 9;

bool isValidCoord(Coord coord) {
  return coord.row >= 0 && coord.row <= 8 && coord.col >= 0 && coord.col <= 8;
}

class Cell {
  final Digit? value;
  final bool given;
  final Set<Digit> notes;

  Cell({required this.value, required this.given, required Set<Digit> notes})
      : notes = Set.unmodifiable(notes) {
    if (value != null && !isValidDigit(value!)) {
      throw ArgumentError('Cell value must be null or 1..9');
    }
    for (final note in this.notes) {
      if (!isValidDigit(note)) {
        throw ArgumentError('Cell notes must contain only digits 1..9');
      }
    }
    if (value != null && this.notes.isNotEmpty) {
      throw ArgumentError('Cell cannot have notes when a value is set');
    }
    if (given && value == null) {
      throw ArgumentError('Given cells must have a value');
    }
  }
}

class Board {
  final List<List<Cell>> cells;

  Board({required List<List<Cell>> cells}) : cells = _freezeCells(cells) {
    if (this.cells.length != 9) {
      throw ArgumentError('Board must have exactly 9 rows');
    }
    for (final row in this.cells) {
      if (row.length != 9) {
        throw ArgumentError('Each board row must have exactly 9 cells');
      }
    }
  }

  Cell cellAt(int row, int col) => cells[row][col];

  Cell cellAtCoord(Coord coord) {
    if (!isValidCoord(coord)) {
      throw ArgumentError('Coord must be within 0..8, 0..8');
    }
    return cellAt(coord.row, coord.col);
  }

  Board withCell(Coord coord, Cell newCell) {
    if (!isValidCoord(coord)) {
      throw ArgumentError('Coord must be within 0..8, 0..8');
    }
    final newCells = cells
        .map((row) => row.map((cell) => cell).toList(growable: false))
        .toList(growable: false);
    newCells[coord.row][coord.col] = newCell;
    return Board(cells: newCells);
  }

  static Board empty() {
    final row = List<Cell>.generate(
      9,
      (_) => Cell(value: null, given: false, notes: const {}),
      growable: false,
    );
    final rows = List<List<Cell>>.generate(
      9,
      (_) => List<Cell>.from(row, growable: false),
      growable: false,
    );
    return Board(cells: rows);
  }

  static Board fromGrid(Grid values, {bool givens = true}) {
    if (values.length != 9) {
      throw ArgumentError('values must be a 9x9 grid');
    }
    final rows = <List<Cell>>[];
    for (var r = 0; r < 9; r += 1) {
      final row = values[r];
      if (row.length != 9) {
        throw ArgumentError('values must be a 9x9 grid');
      }
      final cells = <Cell>[];
      for (var c = 0; c < 9; c += 1) {
        final value = row[c];
        if (value != null && !isValidDigit(value)) {
          throw ArgumentError('values must contain only null or digits 1..9');
        }
        final isGiven = givens && value != null;
        cells.add(Cell(value: value, given: isGiven, notes: const {}));
      }
      rows.add(List<Cell>.unmodifiable(cells));
    }
    return Board(cells: rows);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Board) {
      return false;
    }
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final a = cells[r][c];
        final b = other.cells[r][c];
        if (a.value != b.value || a.given != b.given) {
          return false;
        }
        if (a.notes.length != b.notes.length) {
          return false;
        }
        for (final note in a.notes) {
          if (!b.notes.contains(note)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var hash = 17;
    for (var r = 0; r < 9; r += 1) {
      for (var c = 0; c < 9; c += 1) {
        final cell = cells[r][c];
        hash = 37 * hash + (cell.value ?? 0);
        hash = 37 * hash + (cell.given ? 1 : 0);
        for (final note in cell.notes) {
          hash = 37 * hash + note;
        }
      }
    }
    return hash;
  }
}

List<List<Cell>> _freezeCells(List<List<Cell>> cells) {
  return List<List<Cell>>.unmodifiable(
    cells.map((row) => List<Cell>.unmodifiable(row)),
  );
}
