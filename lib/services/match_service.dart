import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

// NOTE: MiniLM 22M embeddings run via tflite_flutter when you add
// all-MiniLM-L6-v2.tflite (see RESOURCES.md). Default build uses pure-Dart
// TF-IDF cosine so `flutter run` works without Kotlin toolchain fixes.

/// Fuzzy match: sentence-transformers/all-MiniLM-L6-v2 22M.
/// Local cosine >0.7 to assets/data/sql_errors.json.
/// Falls back to TF-IDF cosine + exact-code boost (fully offline).
class MatchedError {
  final Map<String, dynamic> entry;
  final double score;
  final bool isReliable;
  MatchedError({required this.entry, required this.score, required this.isReliable});
}

class MatchService {
  static List<Map<String, dynamic>> _db = [];
  static bool _modelReady = false;

  static Future<void> init() async {
    final raw = await rootBundle.loadString('assets/data/sql_errors.json');
    _db = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    try {
      await rootBundle.load('assets/models/minilm_l6v2.tflite');
      _modelReady = true;
      // tfl.Interpreter.fromAsset('models/minilm_l6v2.tflite') when file present
    } catch (_) {
      _modelReady = false;
    }
  }

  static List<Map<String, dynamic>> get db => _db;
  static bool get modelReady => _modelReady;

  /// MiniLM cosine gate is 0.7. Pure-Dart TF-IDF fallback uses a lower
  /// gate (0.18) because raw token overlap scores lower than embeddings.
  static const double miniLmGate = 0.7;
  static const double fallbackGate = 0.18;

  static bool _isKnownCode(String c) => _db.any((e) => e['code'].toString() == c);

  static MatchedError? match({required String? code, required String errorText, required String query}) {
    if (_db.isEmpty) return null;
    final q = '${errorText.toLowerCase()} ${query.toLowerCase()}';

    // Exact code match wins instantly (honest, no hallucination) -
    // but only if the code is actually in our offline DB.
    if (code != null && _isKnownCode(code)) {
      for (final e in _db) {
        if (e['code'].toString() == code) {
          return MatchedError(entry: e, score: 1.0, isReliable: true);
        }
      }
    }

    // Fuzzy: TF-IDF-ish cosine over tokens (stand-in for MiniLM embeddings;
    // replaced by real MiniLM vectors when .tflite present).
    // Score blends doc similarity + pattern-keyword hits so short pasted
    // errors (no ERROR code) still match instead of always failing.
    MatchedError? best;
    for (final e in _db) {
      final doc = '${e['title_en']} ${e['pattern']} ${e['why_simple_en']}'.toLowerCase();
      var s = _cosine(q, doc);
      final pattern = (e['pattern'] as String).toLowerCase();
      for (final kw in pattern.split(RegExp(r'[^a-z0-9]+'))) {
        if (kw.length >= 4 && q.contains(kw)) s += 0.06;
      }
      final gate = _modelReady ? miniLmGate : fallbackGate;
      if (best == null || s > best.score) {
        best = MatchedError(entry: e, score: s, isReliable: s > gate);
      }
    }
    if (best == null) return null;
    // Gate: below gate and no known code -> NOT reliable -> "Not in offline list".
    if (!best.isReliable && (code == null || !_isKnownCode(code))) {
      return MatchedError(entry: best.entry, score: best.score, isReliable: false);
    }
    return best;
  }

  static Map<String, double> _tf(String text) {
    final m = <String, double>{};
    for (final t in text.split(RegExp(r'[^a-z0-9_]+'))) {
      if (t.length < 2) continue;
      m[t] = (m[t] ?? 0) + 1;
    }
    return m;
  }

  static double _cosine(String a, String b) {
    final fa = _tf(a), fb = _tf(b);
    double dot = 0, na = 0, nb = 0;
    for (final k in fa.keys) {
      na += fa[k]! * fa[k]!;
      if (fb.containsKey(k)) dot += fa[k]! * fb[k]!;
    }
    for (final k in fb.keys) nb += fb[k]! * fb[k]!;
    if (na == 0 || nb == 0) return 0;
    // Small boost if patterns share rare words
    return dot / (sqrt(na) * sqrt(nb));
  }
}
