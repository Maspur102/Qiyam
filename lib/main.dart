import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QiyamApp());
}

class QiyamApp extends StatelessWidget {
  const QiyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiyam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Menggunakan tema gelap minimalis kita
      home: const DashboardPage(), // Halaman utama dashboard
    );
  }
}
