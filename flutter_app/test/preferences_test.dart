import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('controller loads persisted preferences', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'animal_style': 'simple',
      'content_mode': 'numbers',
      'style_name': 'Classic',
      'difficulty': 'hard',
    });

    final controller = SudokuController();
    await Future<void>.delayed(Duration.zero);

    final state = controller.state;
    expect(state.animalStyle, 'simple');
    expect(state.contentMode, 'numbers');
    expect(state.styleName, 'Classic');
    expect(state.difficulty, 'hard');
  });

  test('controller loads persisted butterflies content mode', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'animal_style': 'simple',
      'content_mode': 'butterflies',
      'style_name': 'Classic',
      'difficulty': 'hard',
    });

    final controller = SudokuController();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.contentMode, 'butterflies');
  });
}
