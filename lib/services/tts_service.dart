import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Voice: flutter_tts OFFLINE only. Speaks Fix steps ONLY (not long explanation).
/// Exposes [speaking] so Speak buttons can toggle to Stop/Pause.
class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _init = false;
  static final ValueNotifier<bool> speaking = ValueNotifier(false);

  static Future<void> init() async {
    if (_init) return;
    _init = true;
    await _tts.setSpeechRate(0.48); // slow, elder-friendly
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() => speaking.value = true);
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
    // Keep offline: never set online-only voice; rely on device engine packs.
  }

  static Future<void> speakFixSteps(List<String> steps) async {
    await init();
    await _tts.stop();
    await _tts.setLanguage('en-IN');
    final text = steps.asMap().entries.map((e) => 'Step ${e.key + 1}. ${e.value}').join(' ');
    speaking.value = true;
    await _tts.speak(text);
  }

  /// Toggle: if speaking -> stop (pause), else speak the steps.
  static Future<void> toggleFixSteps(List<String> steps) async {
    await init();
    if (speaking.value) {
      await stop();
    } else {
      await speakFixSteps(steps);
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
    speaking.value = false;
  }
}
