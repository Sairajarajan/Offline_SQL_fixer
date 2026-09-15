import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/home.dart';
import 'screens/fixer.dart';
import 'screens/saved.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.init();
  runApp(const OfflineSqlFixerApp());
}

class OfflineSqlFixerApp extends StatelessWidget {
  const OfflineSqlFixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline SQL Fixer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (c) => const HomeScreen(),
        '/fix': (c) => const FixerScreen(),
        '/saved': (c) => const SavedScreen(),
      },
    );
  }
}
