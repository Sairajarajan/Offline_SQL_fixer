import 'package:hive/hive.dart';

/// Offline storage: Hive box 'my_fixes', no login, no cloud.
class StorageService {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('my_fixes');
  }

  static Future<void> save(Map<String, dynamic> fix) async {
    fix['id'] ??= DateTime.now().millisecondsSinceEpoch.toString();
    fix['ts'] ??= DateTime.now().toIso8601String();
    await _box.put(fix['id'], fix);
  }

  static List<Map<String, dynamic>> all() {
    return _box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      ..sort((a, b) => (b['ts'] ?? '').compareTo(a['ts'] ?? ''));
  }

  static Future<void> remove(String id) => _box.delete(id);
  static Future<void> clear() => _box.clear();
}
