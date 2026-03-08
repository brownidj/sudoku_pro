import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class JapaneseKanjiEntry {
  final String kanji;
  final String commonReading;

  const JapaneseKanjiEntry({
    required this.kanji,
    required this.commonReading,
  });
}

class JapaneseKanjiService {
  static const String _assetPath = 'assets/data/languages/japanese_kanji.yaml';

  static const Map<int, JapaneseKanjiEntry> _defaultEntries = {
    1: JapaneseKanjiEntry(kanji: '－', commonReading: 'いち（ichi）'),
    2: JapaneseKanjiEntry(kanji: '二', commonReading: 'に（ni）'),
    3: JapaneseKanjiEntry(kanji: '三', commonReading: 'さん（san）'),
    4: JapaneseKanjiEntry(kanji: '四', commonReading: 'し（shi）／よん（yon）'),
    5: JapaneseKanjiEntry(kanji: '五', commonReading: 'ご（go）'),
    6: JapaneseKanjiEntry(kanji: '六', commonReading: 'ろく（roku）'),
    7: JapaneseKanjiEntry(
      kanji: '七',
      commonReading: 'しち（shichi）／なな（nana）',
    ),
    8: JapaneseKanjiEntry(kanji: '八', commonReading: 'はち（hachi）'),
    9: JapaneseKanjiEntry(kanji: '九', commonReading: 'きゅう（kyū）／く（ku）'),
  };

  const JapaneseKanjiService();

  Future<Map<int, JapaneseKanjiEntry>> load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final yaml = loadYaml(raw);
      if (yaml is! YamlMap) {
        return _defaultEntries;
      }
      final out = <int, JapaneseKanjiEntry>{};
      for (final entry in yaml.entries) {
        final keyRaw = entry.key;
        final digit = keyRaw is int
            ? keyRaw
            : int.tryParse(keyRaw?.toString() ?? '');
        if (digit == null || digit < 1 || digit > 9) {
          continue;
        }
        final value = entry.value;
        if (value is! YamlMap) {
          continue;
        }
        final kanji = value['kanji']?.toString() ?? '';
        final commonReading = value['common_reading']?.toString() ?? '';
        if (kanji.isEmpty || commonReading.isEmpty) {
          continue;
        }
        out[digit] = JapaneseKanjiEntry(
          kanji: kanji,
          commonReading: commonReading,
        );
      }
      if (out.length == 9) {
        return out;
      }
    } catch (_) {
      // Fall back to defaults on load or parse issues.
    }
    return _defaultEntries;
  }
}
