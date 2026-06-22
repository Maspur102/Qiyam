import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  // Wajib ditambahkan jika main() menggunakan async
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
      theme: AppTheme.darkTheme,
      // Kita arahkan ke halaman pengecekan izin terlebih dahulu
      home: const PermissionHandlerPage(),
    );
  }
}

// --- HALAMAN PENGECEKAN IZIN (LOADING SCREEN) ---
class PermissionHandlerPage extends StatefulWidget {
  const PermissionHandlerPage({super.key});

  @override
  State<PermissionHandlerPage> createState() => _PermissionHandlerPageState();
}

class _PermissionHandlerPageState extends State<PermissionHandlerPage> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // 1. Cek izin Overlay (SYSTEM_ALERT_WINDOW)
    var overlayStatus = await Permission.systemAlertWindow.status;
    
    if (!overlayStatus.isGranted) {
      // Jika belum diizinkan, minta sistem memunculkan halaman pengaturan ke pengguna
      await Permission.systemAlertWindow.request();
    }

    // 2. Cek izin Kamera untuk Misi Al-Quran
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    // Setelah semua izin beres, baru arahkan paksa ke Dashboard Utama
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 20),
            Text(
              "Mempersiapkan Qiyam...",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Mohon izinkan 'Tampil di atas aplikasi lain' saat diminta.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
