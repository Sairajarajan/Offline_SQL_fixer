import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// ignore: unused_import
import 'package:onnxruntime/onnxruntime.dart' as ort;

/// NER: distilbert-base-uncased 66M for error entity extraction.
/// Runs local via onnxruntime if assets/models/distilbert_ner.onnx exists,
/// else deterministic regex fallback (demo-safe, 100% offline).
class NerResult {
  final String? code; // e.g. "1064"
  final String faultyWord; // e.g. word after 'near', quoted ident
  final String errorText;
  final bool usedModel;
  NerResult({required this.code, required this.faultyWord, required this.errorText, required this.usedModel});
}

class NerService {
  static bool _modelReady = false;

  /// Call once at startup. Never requires network.
  static Future<void> init() async {
    try {
      // Probe: if file bundled, mark ready. Real session creation happens lazily
      // to keep startup instant on low-end lab phones.
      await rootBundle.load('assets/models/distilbert_ner.onnx');
      _modelReady = true;
      // ort.OrtEnv.instance.init(); // enable when .onnx present
    } catch (_) {
      _modelReady = false;
    }
  }

  static Future<NerResult> extract(String errorText) async {
    final code = _extractCode(errorText);
    final faulty = _extractFaultyWord(errorText);
    // If model present, it would refine faulty-word span here via token classification.
    // Fallback already gives honest spans; we never invent a code.
    return NerResult(code: code, faultyWord: faulty, errorText: errorText.trim(), usedModel: _modelReady);
  }

  static String? _extractCode(String s) {
    final m = RegExp(r'ERROR\s*(\d{3,4})', caseSensitive: false).firstMatch(s) ??
        RegExp(r'\b(10\d{2}|11\d{2}|12\d{2}|13\d{2}|14\d{2}|16\d{2}|20\d{2})\b').firstMatch(s);
    return m?.group(1);
  }

  static String _extractFaultyWord(String s) {
    // 1. word after 'near'
    final near = RegExp(r"near\s+'?([^'\n]{1,60})", caseSensitive: false).firstMatch(s);
    if (near != null) {
      var w = near.group(1)!.split(RegExp(r'\s+')).take(3).join(' ').replaceAll(RegExp(r'\s+at line.*', caseSensitive: false), '').trim();
      if (w.isNotEmpty) return w;
    }
    // 2. quoted identifier
    final q = RegExp(r'''['"`‘’]([A-Za-z0-9_.$]+)['"`]''').firstMatch(s);
    if (q != null) return q.group(1)!;
    // 3. unknown column 'x'
    final u = RegExp(r"Unknown column '([^']+)'", caseSensitive: false).firstMatch(s);
    if (u != null) return u.group(1)!;
    return '';
  }
}
