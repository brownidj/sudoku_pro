import 'package:flutter_app/app/ui_state.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/animal_cache.dart';

abstract class TileInfoPresentation {
  const TileInfoPresentation();
}

class NoTileInfoPresentation extends TileInfoPresentation {
  const NoTileInfoPresentation();
}

class TooltipTileInfoPresentation extends TileInfoPresentation {
  final String text;

  const TooltipTileInfoPresentation(this.text);
}

class ButterflyDialogPresentation extends TileInfoPresentation {
  final int digit;
  final String description;

  const ButterflyDialogPresentation({
    required this.digit,
    required this.description,
  });
}

class ImageDialogPresentation extends TileInfoPresentation {
  final int digit;

  const ImageDialogPresentation({required this.digit});
}

class TileInfoPresentationCoordinator {
  const TileInfoPresentationCoordinator();

  TileInfoPresentation forLongPress({
    required UiState state,
    required Coord coord,
    required Map<int, String> butterflyDescriptions,
  }) {
    if (state.contentMode == 'numbers' || state.contentMode == 'japanese') {
      return const NoTileInfoPresentation();
    }

    final cell = state.board.cells[coord.row][coord.col];
    final value = cell.value;
    if (value == null) {
      return const NoTileInfoPresentation();
    }

    if (state.contentMode == 'butterflies') {
      return ButterflyDialogPresentation(
        digit: value,
        description: butterflyDescriptions[value] ?? 'Description unavailable.',
      );
    }

    if (state.contentMode == 'ocean') {
      return ImageDialogPresentation(digit: value);
    }

    return TooltipTileInfoPresentation(
      AnimalImageCache.displayNameForDigit(state.contentMode, value),
    );
  }
}
