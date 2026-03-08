import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/animal_cache.dart';

class CandidatePanel extends StatelessWidget {
  final bool visible;
  final List<int> candidateDigits;
  final bool showImages;
  final String contentMode;
  final bool notesMode;
  final Set<int> selectedNotes;
  final Map<int, ui.Image> animalImages;
  final ValueChanged<int> onDigitSelected;
  final ValueChanged<int>? onDigitLongPressed;

  const CandidatePanel({
    super.key,
    required this.visible,
    required this.candidateDigits,
    required this.showImages,
    required this.contentMode,
    required this.notesMode,
    required this.selectedNotes,
    required this.animalImages,
    required this.onDigitSelected,
    this.onDigitLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final digit in candidateDigits)
            Builder(
              builder: (context) {
                final tooltipKey = GlobalKey<TooltipState>();
                return SizedBox(
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onLongPressStart: showImages
                        ? (_) => tooltipKey.currentState?.ensureTooltipVisible()
                        : null,
                    onLongPress: onDigitLongPressed == null
                        ? null
                        : () => onDigitLongPressed!(digit),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            notesMode && selectedNotes.contains(digit)
                            ? const Color(0xFFF6BABA)
                            : (showImages ? Colors.white : null),
                      ),
                      onPressed: () => onDigitSelected(digit),
                      child: showImages
                          ? _animalOption(digit, tooltipKey)
                          : (digit == 0
                                ? const Icon(Icons.clear)
                                : Text('$digit')),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _animalOption(int digit, GlobalKey<TooltipState> tooltipKey) {
    if (digit == 0) {
      return const Icon(Icons.clear);
    }
    final image = animalImages[digit];
    if (image == null) {
      return Text('$digit');
    }
    final name = AnimalImageCache.displayNameForDigit(contentMode, digit);
    return Tooltip(
      key: tooltipKey,
      message: name,
      triggerMode: TooltipTriggerMode.manual,
      child: SizedBox(
        width: 32,
        height: 32,
        child: FittedBox(
          fit: BoxFit.contain,
          child: RawImage(image: image),
        ),
      ),
    );
  }
}
