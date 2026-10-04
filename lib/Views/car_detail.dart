import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/basic_model.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/Views/registrasi_data_diri_page.dart';

class CarDetailPage extends StatelessWidget {
  final Mobil mobil;

  const CarDetailPage({Key? key, required this.mobil}) : super(key: key);

  static const Color kHondaRed = Color.fromARGB(255, 228, 5, 33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mobil.model),
        backgroundColor: kHondaRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey.shade100,
                child: Image.network(
                  mobil.gambar,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.directions_car,
                        size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mobil.model,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mobil.tipe,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatRupiah(mobil.harga),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kHondaRed,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Kartu spesifikasi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: kHondaRed, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spesifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kHondaRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _specRow(Icons.category_outlined, 'Kategori', mobil.kategori),
                        const Divider(height: 20),
                        _specRow(Icons.color_lens_outlined, 'Warna', mobil.warna),
                        const Divider(height: 20),
                        _specRow(Icons.calendar_today_outlined, 'Tahun Pembuatan',
                            mobil.tahunpembuatan.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kHondaRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final auth = Get.find<AuthController>();
                        if(auth.isComplete){
                          // TODO: proses beli / hubungi dealer
                        }else{
                          Get.to(() => const RegistrasiDataDiriPage());
                        }
                      },
                      child: const Text(
                        'Beli Mobil Ini',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kHondaRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }
}