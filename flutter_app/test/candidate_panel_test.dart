import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ui/widgets/candidate_panel.dart';

void main() {
  testWidgets('image mode does not fall back to digit text when image is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CandidatePanel(
            visible: true,
            candidateDigits: const [1],
            showImages: true,
            contentMode: 'animals',
            notesMode: false,
            selectedNotes: const {},
            animalImages: const {},
            onDigitSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('1'), findsNothing);
  });
}
