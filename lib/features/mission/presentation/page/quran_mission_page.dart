import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/local_storage.dart';

class QuranMissionPage extends StatefulWidget {
  const QuranMissionPage({super.key});

  @override
  State<QuranMissionPage> createState() => _QuranMissionPageState();
}

class _QuranMissionPageState extends State<QuranMissionPage> {
  // Mode Misi: 0 = Belum Mulai, 1 = Sedang Membaca, 2 = Selesai Membaca (Siap Foto)
  int _missionState = 0; 
  int _remainingSeconds = 300; // 5 menit = 300 detik
  Timer? _timer;
  File? _proofImage;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startReading() {
    setState(() {
      _missionState = 1;
      _remainingSeconds = 300; // Atur ulang ke 5 menit
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _missionState = 2; // Waktu habis, siap minta bukti foto
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _takePhotoProof() async {
    try {
      // Membuka kamera HP
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        setState(() {
          _proofImage = File(image.path);
        });
        _claimReward();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka kamera. Pastikan izin diberikan.')),
      );
    }
  }

  Future<void> _claimReward() async {
    // Memberikan hadiah 20 XP
    int currentXp = await LocalStorage.getXP();
    await LocalStorage.saveXP(currentXp + 20);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Alhamdulillah!", style: TextStyle(color: AppTheme.primary)),
        content: const Text(
          "Bukti berhasil diterima. Kamu mendapatkan +20 XP. Terus istiqomah membaca Al-Quran!",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              setState(() {
                // Reset misi agar bisa dilakukan lagi dari awal
                _missionState = 0; 
                _proofImage = null;
              });
            },
            child: const Text("Kembali", style: TextStyle(color: AppTheme.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "MISI HARIAN",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.book_fill, size: 80, color: AppTheme.primary)
                  .animate(target: _missionState == 1 ? 1 : 0)
                  .scaleXY(begin: 1.0, end: 1.1, duration: 1.seconds, curve: Curves.easeInOut)
                  .then()
                  .scaleXY(begin: 1.1, end: 1.0, duration: 1.seconds, curve: Curves.easeInOut),
              
              const SizedBox(height: 32),

              if (_missionState == 0) ...[
                const Text(
                  "Misi: Baca Al-Quran 5 Menit",
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hadiah: +20 XP",
                  style: TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startReading,
                    child: const Text("Mulai Membaca"),
                  ),
                ),
              ] else if (_missionState == 1) ...[
                const Text(
                  "Sedang Membaca...",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Text(
                  _formattedTime,
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppTheme.primary),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Harap fokus, jangan tutup layar ini.",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ] else if (_missionState == 2) ...[
                const Text(
                  "Waktu Selesai!",
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Silakan ambil foto Al-Quran yang baru saja kamu baca sebagai bukti untuk mengklaim 20 XP.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                    onPressed: _takePhotoProof,
                    icon: const Icon(CupertinoIcons.camera_fill, color: AppTheme.background),
                    label: const Text("Ambil Foto Bukti", style: TextStyle(color: AppTheme.background)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
