import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/models/basic_model.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/Views/registrasi_data_diri_page.dart';
import 'package:flutter_application_1/Views/checkout_page.dart';
import 'package:flutter_application_1/style/style_desain.dart';

class CarDetailPage extends StatelessWidget {
  final Mobil mobil;

  const CarDetailPage({Key? key, required this.mobil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildHeroImage(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleBlock(),
                        const SizedBox(height: 20),
                        _buildQuickSpecRow(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Spesifikasi Lengkap'),
                        const SizedBox(height: 10),
                        _buildSpecTable(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Fitur Unggulan'),
                        const SizedBox(height: 10),
                        _buildFiturChips(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Tentang Unit Ini'),
                        const SizedBox(height: 10),
                        Text(mobil.deskripsi, style: AppText.body()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildStickyBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.hondaRed,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              mobil.model,
              style: AppText.cardTitle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    final bool pakaiAsetLokal = mobil.gambarDetailRaw != null;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F3),
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: pakaiAsetLokal
            ? Image.asset(
                mobil.gambarUntukDetail,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.directions_car, size: 80, color: Colors.grey),
                ),
              )
            : Image.network(
                mobil.gambarUntukDetail,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.directions_car, size: 80, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.hondaRed,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            mobil.kategori,
            style: AppText.label(color: Colors.white).copyWith(fontSize: 11),
          ),
        ),
        const SizedBox(height: 10),
        Text(mobil.model, style: AppText.headline().copyWith(fontSize: 26)),
        const SizedBox(height: 2),
        Text(mobil.tipe, style: AppText.subtitle()),
        const SizedBox(height: 10),
        Text(_formatRupiah(mobil.harga), style: AppText.price().copyWith(fontSize: 26)),
      ],
    );
  }

  Widget _buildQuickSpecRow() {
    return Row(
      children: [
        Expanded(
          child: _quickSpecItem(Icons.settings_outlined, 'Transmisi', mobil.transmisi),
        ),
        Container(width: 1, height: 40, color: AppColors.line),
        Expanded(
          child: _quickSpecItem(
              Icons.local_gas_station_outlined, 'Bahan Bakar', mobil.bahanBakar),
        ),
        Container(width: 1, height: 40, color: AppColors.line),
        Expanded(
          child: _quickSpecItem(Icons.event_seat_outlined, 'Kapasitas',
              '${mobil.kapasitasPenumpang} Orang'),
        ),
      ],
    );
  }

  Widget _quickSpecItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.hondaRed, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.cardTitle().copyWith(fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: AppText.label().copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.hondaRed),
        const SizedBox(width: 8),
        Text(title, style: AppText.cardTitle().copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildSpecTable() {
    final rows = [
      ('Kategori', mobil.kategori),
      ('Warna', mobil.warna),
      ('Tahun Pembuatan', mobil.tahunpembuatan.toString()),
      ('Transmisi', mobil.transmisi),
      ('Bahan Bakar', mobil.bahanBakar),
      ('Kapasitas Penumpang', '${mobil.kapasitasPenumpang} Orang'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(rows.length, (i) {
          final (label, value) = rows[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: i.isEven ? Colors.white : const Color(0xFFFAFAF9),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(label, style: AppText.label().copyWith(fontSize: 13)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(value, style: AppText.body().copyWith(
                      fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFiturChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: mobil.fiturUnggulan.map((fitur) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.hondaRed.withOpacity(0.06),
            border: Border.all(color: AppColors.hondaRed.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.hondaRed, size: 14),
              const SizedBox(width: 6),
              Text(fitur, style: AppText.body().copyWith(fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.hondaRed,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            final auth = Get.find<AuthController>();
            if (auth.isComplete) {
              Get.to(() => CheckoutPage(mobil: mobil));
            } else {
              Get.to(() => const RegistrasiDataDiriPage());
            }
          },
          child: Text('Beli Mobil Ini', style: AppText.cardTitle(color: Colors.white)),
        ),
      ),
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