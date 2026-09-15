import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/big_button.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: AppTheme.heroGradient,
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(999)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Offline • code never left device', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.25))),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/logo/app_icon.png', width: 58, height: 58, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Offline SQL Fixer', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                    Text('CS Labs • Simple English • 100% on-device', style: TextStyle(fontSize: 16, color: Color(0xFFC7D2FE))),
                  ])),
                ]),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.18))),
                  child: const Row(children: [
                    Icon(Icons.verified_user_outlined, color: Color(0xFFFDE68A), size: 28),
                    SizedBox(width: 12),
                    Expanded(child: Text('Helper only, verify with faculty. Does not run DELETE / DROP.', style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4))),
                  ]),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            sliver: SliverList.list(children: [
              BigButton(
                label: 'Fix Error',
                sub: 'Paste error + query • 1-tap sample',
                icon: Icons.bolt_rounded,
                gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                onTap: () => Navigator.pushNamed(context, '/fix'),
              ),
              const SizedBox(height: 16),
              BigButton(
                label: 'My Fixes',
                sub: 'Saved offline • no login, no cloud',
                icon: Icons.bookmark_rounded,
                gradient: const LinearGradient(colors: [Color(0xFF0EA5A0), Color(0xFF0284C7)]),
                onTap: () => Navigator.pushNamed(context, '/saved'),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: TtsService.speaking,
                builder: (_, isSpeaking, __) => BigButton(
                  label: isSpeaking ? 'Stop' : 'Speak',
                  sub: isSpeaking ? 'Tap to stop the voice' : 'Hear last fix steps aloud',
                  icon: isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                  gradient: isSpeaking
                      ? const LinearGradient(colors: [Color(0xFF475569), Color(0xFF1E293B)])
                      : const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                  onTap: () => _speakLast(context),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('Small models only • ≤500M • onnxruntime + tflite', style: TextStyle(fontSize: 14, color: AppTheme.muted))),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _speakLast(BuildContext context) async {
    if (TtsService.speaking.value) {
      await TtsService.stop();
      return;
    }
    final all = StorageService.all();
    if (all.isEmpty) {
      await TtsService.speakFixSteps(['Open Fix Error, try sample 1064, then save it to hear it here.']);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No saved fix yet - speaking demo hint. Tap Stop to pause.', style: TextStyle(fontSize: 18))));
      }
      return;
    }
    final last = all.first;
    final steps = ((last['fixEn'] ?? []) as List).map((e) => e.toString()).toList();
    await TtsService.speakFixSteps(steps);
  }
}
