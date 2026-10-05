import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/basic_model.dart';

class CheckoutPage extends StatefulWidget {
  final Mobil mobil;

  const CheckoutPage({Key? key, required this.mobil}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color kHondaRed = Color.fromARGB(255, 228, 5, 33);

  /// Prefix kode bank simulasi (bukan kode VA resmi bank sungguhan,
  /// hanya untuk ilustrasi format Virtual Account).
  final Map<String, String> bankPrefix = {
    'BRI': '88810',
    'Mandiri': '88908',
    'BCA': '88888',
    'Jatim': '88907',
  };

  String? selectedBank;
  String? nomorVA;

  /// Status transaksi: belum_bayar -> pending -> lunas
  String status = 'belum_bayar';

  void _buatVirtualAccount() {
    if (selectedBank == null) return;
    final random = Random();
    // 9 digit acak sebagai "identifier" unik transaksi ini,
    // meniru cara kerja VA dari payment gateway sungguhan.
    final uniqueDigits = (100000000 + random.nextInt(899999999)).toString();
    setState(() {
      nomorVA = '${bankPrefix[selectedBank]}$uniqueDigits';
      status = 'pending';
    });
  }

  void _simulasikanPembayaranBerhasil() {
    setState(() {
      status = 'lunas';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout Pembelian'),
        backgroundColor: kHondaRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRingkasanMobil(),
            const SizedBox(height: 24),
            if (status == 'belum_bayar') _buildPilihBank(),
            if (status == 'pending') _buildInstruksiPembayaran(),
            if (status == 'lunas') _buildSukses(),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanMobil() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.mobil.gambar,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: const Icon(Icons.directions_car, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mobil.model,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  widget.mobil.tipe,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(widget.mobil.harga),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kHondaRed,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihBank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Bank Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistem akan membuatkan nomor Virtual Account (VA) khusus '
          'untuk transaksi ini.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ...bankPrefix.keys.map(
          (bank) => RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(bank),
            value: bank,
            groupValue: selectedBank,
            activeColor: kHondaRed,
            onChanged: (value) {
              setState(() => selectedBank = value);
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kHondaRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: selectedBank == null ? null : _buatVirtualAccount,
            child: const Text(
              'Buat Virtual Account',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstruksiPembayaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kHondaRed.withOpacity(0.05),
            border: Border.all(color: kHondaRed.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.hourglass_top, color: kHondaRed, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Menunggu Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, color: kHondaRed),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Transfer ke Virtual Account $selectedBank',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              SelectableText(
                nomorVA ?? '-',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Jumlah transfer',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                _formatRupiah(widget.mobil.harga),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kHondaRed,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mode simulasi: belum terhubung ke bank sungguhan. '
                  'Tombol di bawah menggantikan proses otomatis yang '
                  'nantinya dilakukan sistem bank.',
                  style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: kHondaRed,
              side: const BorderSide(color: kHondaRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _simulasikanPembayaranBerhasil,
            child: const Text('Simulasikan Pembayaran Berhasil'),
          ),
        ),
      ],
    );
  }

  Widget _buildSukses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Pembayaran Berhasil Diterima',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Transaksi untuk ${widget.mobil.model} sudah lunas. Admin akan '
          'mengurus dokumen (BPKB/STNK) dan pengiriman unit.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kHondaRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // TODO: Get.to(() => const AdminChatPage());
            },
            child: const Text(
              'Lanjut ke Admin Chat',
              style: TextStyle(color: Colors.white),
            ),
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