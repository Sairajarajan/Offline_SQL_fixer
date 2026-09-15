import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'result.dart';
import '../services/ner_service.dart';
import '../services/match_service.dart';
import '../services/simplify_service.dart';
import '../services/query_hint_service.dart';

class FixerScreen extends StatefulWidget {
  const FixerScreen({super.key});
  @override
  State<FixerScreen> createState() => _FixerScreenState();
}

class _FixerScreenState extends State<FixerScreen> {
  final _errCtrl = TextEditingController();
  final _qryCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    NerService.init();
    MatchService.init();
    SimplifyService.init();
  }

  bool get _destructive =>
      RegExp(r'\b(DROP|DELETE)\b', caseSensitive: false).hasMatch(_qryCtrl.text);

  Future<void> _paste(TextEditingController c) async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    if (d?.text != null) setState(() => c.text = d!.text!);
  }

  Future<void> _sample(String name) async {
    final raw = await DefaultAssetBundle.of(context).loadString('assets/samples/$name');
    final parts = raw.split('---QUERY---');
    setState(() {
      _errCtrl.text = parts[0].trim();
      _qryCtrl.text = parts.length > 1 ? parts[1].trim() : '';
    });
  }

  Future<void> _fix() async {
    if (_errCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paste the error first (e.g. ERROR 1064...).', style: TextStyle(fontSize: 18))));
      return;
    }
    setState(() => _busy = true);
    try {
      // AI pipeline (all offline): DistilBERT extract -> MiniLM match -> flan-t5 simplify
      final ner = await NerService.extract(_errCtrl.text);
      if (ner.code == null && _errCtrl.text.trim().length < 15) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paste more lines - error is unclear. No guess made.', style: TextStyle(fontSize: 18))));
        return;
      }
      final m = MatchService.match(code: ner.code, errorText: ner.errorText, query: _qryCtrl.text);
      if (m == null || !m.isReliable) {
        setState(() => _busy = false);
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(
          code: ner.code ?? '???', title: 'Not in offline list',
          faultyWord: ner.faultyWord, query: _qryCtrl.text,
          errorText: _errCtrl.text, unknown: true,
        )));
        return;
      }
      final simp = SimplifyService.simplify(m.entry);
      final code = m.entry['code'].toString();
      final hint = QueryHintService.hintFor(code: code, errorText: ner.errorText, query: _qryCtrl.text, faultyWord: ner.faultyWord);
      setState(() => _busy = false);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(
        code: code, title: m.entry['title_en'].toString(),
        faultyWord: ner.faultyWord, query: _qryCtrl.text, errorText: _errCtrl.text,
        whyEn: simp.why, fixEn: simp.steps,
        hintTitle: hint.title, hintDetail: hint.detail, highlight: hint.highlight,
      )));
    } catch (e) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offline pipeline hiccup: $e', style: const TextStyle(fontSize: 18))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix Error', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF6EE7B7))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFF047857)),
            SizedBox(width: 6),
            Text('Offline - code never left device', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF065F46))),
          ]),
        ),
        const SizedBox(height: 14),
        _label('1  •  Error box', 'Paste  ERROR 1064 ...'),
        _box(_errCtrl, 'ERROR 1064 (42000): You have an error in your SQL syntax near ...', 5, () => _paste(_errCtrl)),
        const SizedBox(height: 14),
        _label('2  •  Query box', 'Paste  SELECT ...'),
        _box(_qryCtrl, 'SELECT name FROM students WHERE id = 1', 4, () => _paste(_qryCtrl)),
        if (_destructive)
          Container(
            margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade300)),
            child: const Row(children: [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text('DELETE / DROP detected - this helper never auto-runs it. Verify with faculty.', style: TextStyle(fontSize: 17))),
            ]),
          ),
        const SizedBox(height: 16),
        const Text('Try Sample (1-click for judges)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _chip('1064 Syntax', () => _sample('sample_1064.txt')),
          _chip('1054 Column', () => _sample('sample_1054.txt')),
          _chip('1062 Duplicate', () => _sample('sample_1062.txt')),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: _busy ? null : _fix,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.indigo, foregroundColor: Colors.white),
            child: _busy
                ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Fix My Error  →', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Helper only, verify with faculty. Does not run DELETE/DROP.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppTheme.muted)),
      ]),
    );
  }

  Widget _label(String a, String b) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Text(a, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(width: 8),
      Expanded(child: Text(b, style: const TextStyle(fontSize: 16, color: AppTheme.muted))),
    ]),
  );

  Widget _box(TextEditingController c, String hint, int lines, VoidCallback onPaste) => Column(children: [
    Row(children: [
      const Spacer(),
      FilledButton.tonal(onPressed: onPaste, child: const Text('Paste', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
    ]),
    const SizedBox(height: 8),
    TextField(controller: c, maxLines: lines, style: const TextStyle(fontSize: 18, fontFamily: 'monospace'), decoration: InputDecoration(hintText: hint)),
  ]);

  Widget _chip(String t, VoidCallback onTap) => ActionChip(
    label: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    avatar: const Icon(Icons.play_arrow_rounded),
    onPressed: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}
