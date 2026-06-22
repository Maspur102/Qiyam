import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';

class PrayerOverlayPage extends StatefulWidget {
  final String prayerName;
  final int durationInMinutes;

  const PrayerOverlayPage({
    super.key,
    this.prayerName = "Shalat",
    this.durationInMinutes = 5, // Default terkunci selama 5 menit
  });

  @override
  State<PrayerOverlayPage> createState() => _PrayerOverlayPageState();
}

class _PrayerOverlayPageState extends State<PrayerOverlayPage> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mengubah menit menjadi detik saat halaman pertama kali dibuka
    _remainingSeconds = widget.durationInMinutes * 60;
    _startTimer();
  }

  // Fungsi untuk menjalankan hitung mundur setiap 1 detik
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Otomatis menutup layar pengunci jika waktunya sudah habis
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // Pastikan timer dihentikan agar tidak membuat memori HP bocor (memory leak)
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi untuk memformat detik menjadi tampilan jam yang rapi (MM:SS)
  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // PopScope digunakan agar tombol "Back" bawaan sistem Android tidak berfungsi
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
                // Ikon masjid dengan animasi membesar
                const Icon(
                  Icons.mosque,
                  size: 80,
                  color: AppTheme.primary,
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 24),
                
                // Judul Shalat
                Text(
                  "Waktunya ${widget.prayerName}",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 16),
                
                // Pesan instruksi
                Text(
                  "Tinggalkan sejenak aktivitasmu. Layar dikunci selama:",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 32),
                
                // Kotak Timer (Hitung Mundur) dengan animasi efek menyala (shimmer)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accent,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().shimmer(delay: 600.ms, duration: 2.seconds, curve: Curves.easeInOut),
                
                const SizedBox(height: 48),
                
                // Tombol satu-satunya yang mengarahkan fokus kembali ke aplikasi Qiyam
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
                      // Jika pengguna menekan tombol ini, kita hanya memberi notifikasi
                      // Karena secara hierarki, mereka sebenarnya "sudah" berada di dalam aplikasi Qiyam.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fokuskan dirimu pada ibadah...")),
                      );
                    },
                    child: const Text(
                      "Buka Aplikasi Qiyam",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
