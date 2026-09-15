// ignore: unused_import
import 'package:onnxruntime/onnxruntime.dart' as ort;

/// Simplify: google/flan-t5-small 80M.
/// It ONLY rewrites the matched DB entry into simple Why + Fix 1-2-3.
/// It NEVER invents a new SQL fix (hallucination guard).
class Simplified {
  final String why;
  final List<String> steps;
  Simplified({required this.why, required this.steps});
}

class SimplifyService {
  static bool _ready = false;
  static Future<void> init() async {
    // Probe only; real ORT session created lazily when file exists.
    _ready = false; // set true when assets/models/flan_t5_small.onnx bundled
  }

  static Simplified simplify(Map<String, dynamic> entry) {
    // Template simplifier = deterministic stand-in for flan-t5-small prompt:
    // "Rewrite this DB help in very simple English, short sentences, steps 1-2-3:"
    final why = (entry['why_simple_en'] as String).trim();
    final steps = (entry['fix_steps_en'] as List).map((e) => e.toString().trim()).toList();
    return Simplified(why: _simple(why), steps: steps.map(_simple).toList());
  }

  static String _simple(String s) {
    // Keep short, junior/elder friendly. No new facts added.
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.length > 140) {
      final cut = s.lastIndexOf('.', 120);
      if (cut > 40) s = s.substring(0, cut + 1);
    }
    return s;
  }
}
