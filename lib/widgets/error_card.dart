import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Elegant error summary card with code pill + faulty-word highlight.
/// [highlight] is a substring of [query] to bold (from QueryHintService).
class ErrorCard extends StatelessWidget {
  final String code;
  final String title;
  final String faultyWord;
  final String query;
  final String highlight;
  const ErrorCard({super.key, required this.code, required this.title, required this.faultyWord, required this.query, this.highlight = ''});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(999)),
              child: Text('ERROR $code', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 14),
          if (faultyWord.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.gold)),
              child: RichText(text: TextSpan(style: const TextStyle(fontSize: 18, color: AppTheme.ink), children: [
                const TextSpan(text: 'Check this word: ', style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: faultyWord, style: const TextStyle(backgroundColor: Color(0xFFFEF08A), fontWeight: FontWeight.w800)),
              ])),
            ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
              child: _highlightedQuery(),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _highlightedQuery() {
    const base = TextStyle(fontFamily: 'monospace', fontSize: 16, height: 1.5, color: AppTheme.ink);
    if (highlight.isEmpty || !query.contains(highlight)) {
      return Text(query, style: base);
    }
    final parts = query.split(highlight);
    return RichText(
      text: TextSpan(style: base, children: [
        for (var i = 0; i < parts.length; i++) ...[
          TextSpan(text: parts[i]),
          if (i < parts.length - 1)
            TextSpan(text: highlight, style: base.copyWith(backgroundColor: const Color(0xFFFCA5A5), fontWeight: FontWeight.w800)),
        ],
      ]),
    );
  }
}
