import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  // Wajib dipanggil untuk inisialisasi yang aman
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
      home: const WelcomePermissionPage(), // Arahkan ke halaman selamat datang
    );
  }
}

// --- HALAMAN SELAMAT DATANG & IZIN ---
class WelcomePermissionPage extends StatefulWidget {
  const WelcomePermissionPage({super.key});

  @override
  State<WelcomePermissionPage> createState() => _WelcomePermissionPageState();
}

class _WelcomePermissionPageState extends State<WelcomePermissionPage> {
  bool _isLoading = false;

  Future<void> _requestPermissionsAndStart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Meminta izin Kamera
      if (!await Permission.camera.isGranted) {
        await Permission.camera.request();
      }

      // 2. Meminta izin Overlay (Tampil di Atas Aplikasi Lain)
      // Menggunakan delay agar sistem Android tidak kaget
      await Future.delayed(const Duration(milliseconds: 500));
      if (!await Permission.systemAlertWindow.isGranted) {
        await Permission.systemAlertWindow.request();
      }
    } catch (e) {
      debugPrint("Gagal meminta izin: $e");
    }

    // 3. Pindah ke Dashboard setelah proses selesai
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.shield_lefthalf_fill, size: 100, color: AppTheme.primary),
              const SizedBox(height: 32),
              const Text(
                "Selamat Datang di Qiyam",
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Agar fitur pengunci layar jadwal shalat dan tidur berfungsi maksimal, aplikasi membutuhkan izin khusus.",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              _isLoading 
                ? const CircularProgressIndicator(color: AppTheme.primary)
                : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _requestPermissionsAndStart,
                      child: const Text("Berikan Izin & Mulai", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
