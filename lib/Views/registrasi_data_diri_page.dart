import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';

class RegistrasiDataDiriPage extends StatefulWidget {
  const RegistrasiDataDiriPage({Key? key}) : super(key: key);

  @override
  State<RegistrasiDataDiriPage> createState() =>
      _RegistrasiDataDiriPageState();
}

class _RegistrasiDataDiriPageState extends State<RegistrasiDataDiriPage> {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController noKKController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const Color kHondaRed = Color.fromARGB(255, 228, 5, 33);

  bool _loading = false;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await Get.find<AuthController>().completeProfile(
      nikUser: nikController.text,
      noKKUser: noKKController.text,
      noHpUser: noHpController.text,
      alamatUser: alamatController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      Get.snackbar(
        'Gagal menyimpan',
        error,
        backgroundColor: kHondaRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Data diri kamu sudah lengkap. Sekarang kamu bisa '
          'melanjutkan pembelian.',
      backgroundColor: kHondaRed,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    nikController.dispose();
    noKKController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 246, 246),
        appBar: AppBar(
          title: const Text('Registrasi Data Diri'),
          backgroundColor: kHondaRed,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lengkapi Data Diri',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Data ini diperlukan untuk proses pembelian unit dan '
                  'pengurusan dokumen (BPKB/STNK). Pastikan data yang '
                  'kamu masukkan benar dan sesuai KTP.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),

                /// NIK
                _buildLabel('NIK (16 digit)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nikController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(hint: 'Contoh: 3578xxxxxxxxxxxx'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK wajib diisi';
                    } else if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                      return 'NIK harus 16 digit angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                /// No KK
                _buildLabel('Nomor Kartu Keluarga (16 digit)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noKKController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(hint: 'Contoh: 3578xxxxxxxxxxxx'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor KK wajib diisi';
                    } else if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                      return 'Nomor KK harus 16 digit angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                /// No HP
                _buildLabel('Nomor HP Aktif'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration(hint: 'Contoh: 08123456789'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP wajib diisi';
                    } else if (!RegExp(r'^08[0-9]{8,11}$').hasMatch(value)) {
                      return 'Format nomor HP tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                /// Alamat
                _buildLabel('Alamat Lengkap'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: alamatController,
                  maxLines: 3,
                  decoration: _fieldDecoration(
                    hint: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kota',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat wajib diisi';
                    } else if (value.length < 10) {
                      return 'Alamat terlalu singkat, mohon lebih lengkap';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                /// Catatan keamanan data
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kHondaRed.withOpacity(0.05),
                    border: Border.all(color: kHondaRed.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline, color: kHondaRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data pribadimu dilindungi dan hanya digunakan '
                          'untuk keperluan transaksi dengan dealer resmi Honda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
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
                    onPressed: _loading ? null : _simpan,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Data Diri',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(255, 150, 150, 150)),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color.fromARGB(255, 107, 101, 101)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: kHondaRed, width: 1.5),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color.fromARGB(255, 107, 101, 101)),
      ),
    );
  }
}