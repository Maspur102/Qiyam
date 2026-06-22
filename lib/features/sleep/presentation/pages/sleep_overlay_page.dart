import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/local_storage.dart';

class SleepOverlayPage extends StatefulWidget {
  const SleepOverlayPage({super.key});

  @override
  State<SleepOverlayPage> createState() => _SleepOverlayPageState();
}

class _SleepOverlayPageState extends State<SleepOverlayPage> {
  int _currentXp = 0;

  @override
  void initState() {
    super.initState();
    _loadXp();
  }

  // Mengambil data XP terbaru dari penyimpanan HP
  Future<void> _loadXp() async {
    final xp = await LocalStorage.getXP();
    setState(() {
      _currentXp = xp;
    });
  }

  // Fungsi untuk menggunakan XP demi membuka kunci (Darurat)
  void _triggerEmergencyBypass() {
    if (_currentXp >= 50) {
      setState(() {
        _currentXp -= 50;
      });
      LocalStorage.saveXP(_currentXp);
      
      // Menutup layar pengunci tidur
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Darurat Digunakan! Layar dibuka, 50 XP dipotong.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text("XP Tidak Cukup", style: TextStyle(color: AppTheme.textPrimary)),
          content: const Text(
            "Kamu memerlukan minimal 50 XP untuk menggunakan akses darurat. Istirahatlah sekarang.",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Mengerti", style: TextStyle(color: AppTheme.textSecondary)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope memblokir tombol kembali (back) bawaan Android
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikon Bulan Bintang
                const Icon(
                  CupertinoIcons.moon_stars_fill,
                  size: 100,
                  color: AppTheme.accent,
                ).animate().slideY(begin: -0.2, end: 0, duration: 800.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                Text(
                  "Waktunya Istirahat",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  "Tinggalkan sejenak dunia digitalmu.\nTubuhmu memiliki hak untuk beristirahat.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 64),
                
                // Tombol utama (hanya mengarah ke Qiyam)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tetaplah berada di aplikasi Qiyam dan tidurlah...")),
                      );
                    },
                    child: const Text(
                      "Buka Aplikasi Qiyam",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),

                const SizedBox(height: 16),

                // Tombol Akses Darurat (Pakai XP)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: _currentXp >= 50 ? Colors.redAccent : AppTheme.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _currentXp >= 50 ? Colors.redAccent.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                    ),
                    onPressed: _triggerEmergencyBypass,
                    child: Text(
                      "Akses Darurat (Potong 50 XP)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _currentXp >= 50 ? Colors.redAccent : AppTheme.textSecondary),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
