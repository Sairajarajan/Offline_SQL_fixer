import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium numbered fix-steps timeline.
class FixSteps extends StatelessWidget {
  final List<String> steps;
  const FixSteps({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key, s = e.value;
        return Padding(
          padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.indigo, Color(0xFF7C3AED)]), shape: BoxShape.circle),
              child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Text(s, style: const TextStyle(fontSize: 19, height: 1.45)),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }
}
