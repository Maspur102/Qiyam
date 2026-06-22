import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  /// Mengambil jadwal shalat hari ini berdasarkan nama kota dan negara.
  /// Secara default, parameter diisi dengan 'Bandung' dan 'Indonesia'.
  static Future<Map<String, dynamic>?> getPrayerTimes({
    String city = 'Bandung',
    String country = 'Indonesia',
  }) async {
    try {
      // 1. Menentukan URL endpoint API (menggunakan metode kalkulasi 11 untuk standar umum)
      final Uri url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=11'
      );

      // 2. Melakukan request HTTP GET ke server
      final http.Response response = await http.get(url);

      // 3. Mengecek apakah server memberikan respon sukses (Status Code: 200)
      if (response.statusCode == 200) {
        // 4. Menerjemahkan data JSON string menjadi objek Map Dart
        final Map<String, dynamic> data = json.decode(response.body);
        
        // 5. Mengembalikan bagian 'timings' yang spesifik berisi jadwal waktu (Subuh, Dzuhur, dll)
        return data['data']['timings'];
      } else {
        // Jika status tidak 200 (misal kota tidak ditemukan atau server sibuk)
        print('Gagal mengambil jadwal shalat. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Menangkap error lain, seperti HP tidak ada koneksi internet
      print('Terjadi kesalahan jaringan atau API: $e');
      return null;
    }
  }
}
