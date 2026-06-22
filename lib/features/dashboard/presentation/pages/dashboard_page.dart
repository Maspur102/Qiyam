import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../prayer/presentation/pages/prayer_overlay_page.dart'; 
import '../../../settings/presentation/pages/settings_page.dart';
// Tambahan Import: Halaman Overlay Tidur
import '../../../sleep/presentation/pages/sleep_overlay_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentXp = 0;
  bool _isSystemActive = true;
  String _sleepTime = "22:00"; // Variabel baru untuk menampung jam tidur
  
  String _nextPrayerName = "Memuat...";
  String _nextPrayerTime = "--:--";
  bool _isLoadingApi = true;

  Timer? _clockWatcher;
  bool _isOverlayOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAppState();
    _loadPrayerTimes().then((_) {
      _startClockWatcher();
    });
  }

  @override
  void dispose() {
    _clockWatcher?.cancel();
    super.dispose();
  }

  Future<void> _loadAppState() async {
    final xp = await LocalStorage.getXP();
    final systemStatus = await LocalStorage.isSystemActive();
    final sleepTime = await LocalStorage.getSleepTime(); // Mengambil jam tidur
    setState(() {
      _currentXp = xp;
      _isSystemActive = systemStatus;
      _sleepTime = sleepTime;
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoadingApi = true);
    final timings = await ApiClient.getPrayerTimes();
    
    if (timings != null) {
      _calculateNextPrayer(timings);
    } else {
      setState(() {
        _nextPrayerName = "Offline";
        _nextPrayerTime = "--:--";
        _isLoadingApi = false;
      });
    }
  }

  void _calculateNextPrayer(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final currentTimeInMinutes = (now.hour * 60) + now.minute;

    final prayerList = [
      {"name": "Subuh", "key": "Fajr"},
      {"name": "Dzuhur", "key": "Dhuhr"},
      {"name": "Ashar", "key": "Asr"},
      {"name": "Maghrib", "key": "Maghrib"},
      {"name": "Isya", "key": "Isha"},
    ];

    String nextName = "Subuh";
    String nextTime = timings["Fajr"] ?? "04:30";

    for (var prayer in prayerList) {
      final timeString = timings[prayer["key"]];
      if (timeString != null) {
        final parts = timeString.toString().split(':');
        final prayerTimeInMinutes = (int.parse(parts[0]) * 60) + int.parse(parts[1]);

        if (prayerTimeInMinutes > currentTimeInMinutes) {
          nextName = prayer["name"]!;
          nextTime = timeString;
          break;
        }
      }
    }

    setState(() {
      _nextPrayerName = nextName;
      _nextPrayerTime = nextTime;
      _isLoadingApi = false;
    });
  }

  // LOGIKA PEMANTAU WAKTU DIPERBARUI
  void _startClockWatcher() {
    _clockWatcher = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSystemActive) return; 

      final now = DateTime.now();
      final currentFormattedTime = 
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Mengecek Waktu Shalat
      if (currentFormattedTime == _nextPrayerTime && !_isOverlayOpen) {
        _triggerPrayerLock();
      }
      
      // Mengecek Waktu Tidur
      if (currentFormattedTime == _sleepTime && !_isOverlayOpen) {
        _triggerSleepLock();
      }
    });
  }

  void _triggerPrayerLock() async {
    setState(() {
      _isOverlayOpen = true; 
    });

    final lockDuration = await LocalStorage.getBlockDuration();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrayerOverlayPage(
          prayerName: _nextPrayerName,
          durationInMinutes: lockDuration, 
        ),
      ),
    ).then((_) {
      setState(() {
        _isOverlayOpen = false;
      });
      _loadPrayerTimes();
    });
  }

  // Fungsi Baru: Memunculkan layar tidur
  void _triggerSleepLock() {
    setState(() {
      _isOverlayOpen = true; 
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SleepOverlayPage(),
      ),
    ).then((_) {
      // Dijalankan saat layar tidur berhasil dibuka paksa (pakai XP)
      setState(() {
        _isOverlayOpen = false;
      });
      _loadAppState(); // Refresh XP
    });
  }

  Future<void> _toggleSystemStatus(bool value) async {
    await LocalStorage.setSystemStatus(value);
    setState(() {
      _isSystemActive = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Sistem Qiyam Diaktifkan' : 'Sistem Qiyam Dinonaktifkan'),
        duration: const Duration(seconds: 2),
        backgroundColor: value ? AppTheme.primary : Colors.redAccent,
      ),
    );
  }

  void _triggerEmergencyBypass() {
    if (_currentXp >= 50) {
      setState(() {
        _currentXp -= 50;
      });
      LocalStorage.saveXP(_currentXp);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text("Akses Darurat", style: TextStyle(color: AppTheme.textPrimary)),
          content: const Text(
            "Kunci layar ditangguhkan. Sisa XP Anda telah dikurangi 50 poin.",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: AppTheme.primary)),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text("XP Tidak Cukup", style: TextStyle(color: AppTheme.textPrimary)),
          content: const Text(
            "Kamu memerlukan minimal 50 XP untuk menggunakan akses darurat.",
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "QIYAM",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ).then((_) {
                _loadAppState(); // Refresh jam tidur jika diubah di pengaturan
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Poin Darurat Tersedia",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic, 
                    children: [
                      Text(
                        "$_currentXp",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "XP",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Proteksi Layar Aktif",
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSystemActive ? "Sistem berjalan di latar belakang" : "Sistem mati sementara",
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    activeColor: AppTheme.primary,
                    value: _isSystemActive,
                    onChanged: _toggleSystemStatus,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isLoadingApi
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jadwal Shalat Berikutnya",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _nextPrayerName,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Layar akan terkunci di waktu ini.",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          _nextPrayerTime,
                          style: const TextStyle(color: AppTheme.accent, fontSize: 36, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentXp >= 50 ? Colors.redAccent.withOpacity(0.2) : AppTheme.surface,
                  foregroundColor: _currentXp >= 50 ? Colors.redAccent : AppTheme.textSecondary,
                  side: BorderSide(
                    color: _currentXp >= 50 ? Colors.redAccent : Colors.transparent,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _triggerEmergencyBypass,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle, 
                      color: _currentXp >= 50 ? Colors.redAccent : AppTheme.textSecondary
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Gunakan Akses Darurat (50 XP)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
