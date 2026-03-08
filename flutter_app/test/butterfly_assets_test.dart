import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('butterfly assets include a sample icon', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final data = await rootBundle.load(
      'assets/images/butterflies/2_swallowtail.png',
    );
    expect(data.lengthInBytes, greaterThan(0));
  });
}
