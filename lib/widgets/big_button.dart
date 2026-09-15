import 'package:flutter/material.dart';

/// Premium big action button: gradient, icon in glass chip, 22sp+ label.
class BigButton extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  const BigButton({super.key, required this.label, required this.sub, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(26), boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 12)),
        ]),
        child: Row(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.35))),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text(sub, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85), height: 1.3)),
              ]),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
