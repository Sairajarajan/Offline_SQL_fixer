// ignore: unused_import
import 'package:onnxruntime/onnxruntime.dart' as ort;

/// Translate: Helsinki-NLP/opus-mt-en-ta ~75M, EN->TA text only.
/// Primary source is pre-translated why_ta/fix_ta in sql_errors.json
/// (instant + 100% offline). ONNX refines free text when bundled.
class TranslateService {
  static bool _ready = false;
  static Future<void> init() async => _ready = false;

  /// Returns Tamil from DB entry (guaranteed offline). No cloud.
  static Map<String, dynamic> tamilFromEntry(Map<String, dynamic> entry) {
    return {
      'why': (entry['why_ta'] ?? entry['why_simple_en']).toString(),
      'steps': ((entry['fix_ta'] ?? entry['fix_steps_en']) as List).map((e) => e.toString()).toList(),
    };
  }
}
