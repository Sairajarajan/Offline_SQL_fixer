import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/error_card.dart';
import '../widgets/fix_steps.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';

class ResultScreen extends StatelessWidget {
  final String code, title, faultyWord, query, errorText;
  final String? whyEn; final List<String>? fixEn;
  final String hintTitle, hintDetail, highlight;
  final bool unknown;
  const ResultScreen({super.key,
    required this.code, required this.title, required this.faultyWord,
    required this.query, required this.errorText,
    this.whyEn, this.fixEn,
    this.hintTitle = '', this.hintDetail = '', this.highlight = '',
    this.unknown = false});

  List<String> get _steps => fixEn ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Why + Fix', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
        ErrorCard(code: code, title: title, faultyWord: faultyWord, query: query, highlight: highlight),
        const SizedBox(height: 16),
        if (unknown) ...[
          const Card(child: Padding(padding: EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Not in offline list - ask faculty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Honest answer beats a wrong fix. Paste more lines of the error, or ask your lab faculty. Nothing was guessed.', style: TextStyle(fontSize: 19, height: 1.5)),
          ]))),
        ] else ...[
          // Query-specific spot (deterministic, not AI-generated SQL)
          if (hintTitle.isNotEmpty)
            Card(
              color: const Color(0xFFEFF6FF),
              child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [
                  Icon(Icons.location_on_rounded, color: AppTheme.indigo, size: 28),
                  SizedBox(width: 8),
                  Expanded(child: Text('In YOUR query', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 8),
                Text(hintTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(hintDetail, style: const TextStyle(fontSize: 19, height: 1.5)),
              ])),
            ),
          if (hintTitle.isNotEmpty) const SizedBox(height: 16),
          Card(
            child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.lightbulb_rounded, color: AppTheme.gold, size: 28),
                SizedBox(width: 8),
                Text('Why this happened', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Text(whyEn ?? '', style: const TextStyle(fontSize: 20, height: 1.5)),
            ])),
          ),
          const SizedBox(height: 16),
          const Text('Fix it in 3 steps', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          FixSteps(steps: _steps),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: SizedBox(height: 62, child: ElevatedButton.icon(onPressed: () => _copy(context), icon: const Icon(Icons.copy_rounded), label: const Text('Copy Fix', style: TextStyle(fontSize: 21)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navy, foregroundColor: Colors.white)))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(
              height: 62,
              child: ValueListenableBuilder<bool>(
                valueListenable: TtsService.speaking,
                builder: (_, isSpeaking, __) => ElevatedButton.icon(
                  onPressed: () => TtsService.toggleFixSteps(_steps),
                  icon: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
                  label: Text(isSpeaking ? 'Stop' : 'Speak', style: const TextStyle(fontSize: 21)),
                  style: ElevatedButton.styleFrom(backgroundColor: isSpeaking ? const Color(0xFF475569) : AppTheme.teal, foregroundColor: Colors.white),
                ),
              ),
            )),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 62, child: OutlinedButton.icon(onPressed: () => _save(context), icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save to My Fixes (offline)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))),
        ],
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))), child: const Text('Helper only, verify with faculty. Does not run DELETE/DROP.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))),
      ]),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final hintPart = hintTitle.isNotEmpty ? '\nIn YOUR query - $hintTitle: $hintDetail\n' : '';
    final t = 'Why: ${whyEn ?? ''}$hintPart\nFix:\n${_steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}';
    await Clipboard.setData(ClipboardData(text: t));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fix copied.', style: TextStyle(fontSize: 18))));
  }

  Future<void> _save(BuildContext context) async {
    await StorageService.save({
      'code': code, 'title': title,
      'errorText': errorText, 'query': query,
      'faulty': faultyWord,
      'whyEn': whyEn ?? '', 'fixEn': fixEn ?? [],
      'hint': hintTitle.isNotEmpty ? '$hintTitle: $hintDetail' : '',
    });
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved offline in My Fixes.', style: TextStyle(fontSize: 18))));
  }
}
