import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/local_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _sleepTime = "22:00";
  int _blockDuration = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Memuat data pengaturan dari penyimpanan lokal
  Future<void> _loadSettings() async {
    final sleepTime = await LocalStorage.getSleepTime();
    final duration = await LocalStorage.getBlockDuration();
    setState(() {
      _sleepTime = sleepTime;
      _blockDuration = duration;
    });
  }

  // Fungsi memunculkan jam visual untuk memilih waktu tidur
  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_sleepTime.split(":")[0]),
        minute: int.parse(_sleepTime.split(":")[1]),
      ),
      builder: (context, child) {
        // Menyesuaikan warna jam visual dengan tema aplikasi kita
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: AppTheme.background,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format jam agar selalu 2 digit (contoh: 09:05)
      final formattedTime = 
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      await LocalStorage.saveSleepTime(formattedTime);
      setState(() {
        _sleepTime = formattedTime;
      });
    }
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
          "PENGATURAN",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // BAGIAN 1: JADWAL TIDUR
          const Text(
            "Waktu Istirahat",
            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(CupertinoIcons.moon_stars_fill, color: AppTheme.accent, size: 30),
              title: const Text("Jadwal Tidur", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text("Layar akan dikunci di waktu ini", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              trailing: Text(
                _sleepTime,
                style: const TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              onTap: () => _selectSleepTime(context),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),

          // BAGIAN 2: DURASI KUNCI SHALAT
          const Text(
            "Preferensi Shalat",
            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(CupertinoIcons.lock_shield_fill, color: AppTheme.primary, size: 30),
              title: const Text("Durasi Penguncian", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text("Lama layar tertutup saat adzan", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              trailing: DropdownButton<int>(
                value: _blockDuration,
                dropdownColor: AppTheme.surface,
                underline: const SizedBox(), // Hilangkan garis bawah bawaan
                icon: const Icon(CupertinoIcons.chevron_down, color: AppTheme.textSecondary, size: 16),
                style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                items: [3, 5, 10, 15].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value Menit"),
                  );
                }).toList(),
                onChanged: (int? newValue) async {
                  if (newValue != null) {
                    await LocalStorage.saveBlockDuration(newValue);
                    setState(() {
                      _blockDuration = newValue;
                    });
                  }
                },
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),

          // BAGIAN 3: NADA & NOTIFIKASI
          const Text(
            "Suara & Peringatan",
            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(CupertinoIcons.speaker_3_fill, color: Colors.orangeAccent, size: 30),
              title: const Text("Nada Pengingat", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text("Pilih suara notifikasi", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              trailing: const Icon(CupertinoIcons.chevron_forward, color: AppTheme.textSecondary),
              onTap: () {
                // Nantinya ini akan kita hubungkan dengan plugin pemilih file / nada dering
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur pilih nada akan ditambahkan di versi berikutnya!')),
                );
              },
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
