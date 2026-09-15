import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() => setState(() => _items = StorageService.all());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Fixes (offline)', style: TextStyle(fontWeight: FontWeight.w800))),
      body: _items.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No saved fixes yet.\nFix an error, then tap Save.', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, height: 1.5))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final f = _items[i];
                return Dismissible(
                  key: ValueKey(f['id']),
                  background: Container(decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_rounded, color: Colors.white, size: 30)),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async { await StorageService.remove(f['id']); _reload(); },
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      leading: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(12)), child: Text('${f['code']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
                      title: Text('${f['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${(f['whyEn'] ?? '').toString()}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17))),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 28), onPressed: () async { await StorageService.remove(f['id']); _reload(); }),
                      onTap: () => _view(f),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _view(Map<String, dynamic> f) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (_) {
      final steps = ((f['fixEn'] ?? []) as List).map((e) => e.toString()).toList();
      return DraggableScrollableSheet(expand: false, initialChildSize: 0.75, builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
        Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(99)))),
        const SizedBox(height: 16),
        Text('ERROR ${f['code']} • ${f['title']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text('${f['whyEn']}', style: const TextStyle(fontSize: 20, height: 1.5)),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 16, backgroundColor: AppTheme.indigo, child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Text(e.value, style: const TextStyle(fontSize: 19))),
        ]))),
        if ((f['query'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)), child: Text('${f['query']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 16))),
        ],
      ]));
    });
  }
}
