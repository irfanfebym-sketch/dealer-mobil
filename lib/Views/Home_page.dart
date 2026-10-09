import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/models/basic_model.dart';
import 'package:flutter_application_1/models/list_mobil_model.dart';
import 'package:flutter_application_1/Views/about_me_page.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/Views/login_page.dart';
import 'package:flutter_application_1/Views/car_detail.dart';
import 'package:flutter_application_1/Views/registrasi_data_diri_page.dart';
import 'package:flutter_application_1/Views/checkout_page.dart';
import 'package:flutter_application_1/style/style_desain.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _CarHomePageState();
}

class _CarHomePageState extends State<HomePage> {
  bool _isNavOpen = false;
  static const double _navWidth = 240;

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  final List<Map<String, String>> banners = [
    {
      'image':
          'https://imgcdn.oto.com/large/gallery/exterior/38/1798/toyota-vios-front-angle-low-view-360231.jpg?tr=w-1200,h-600',
      'headline': 'Setiap Perjalanan,\nPunya Alasan',
      'subtitle': 'Temukan unit Honda yang sesuai kebutuhanmu',
    },
    {
      'image':
          'https://asset.honda-indonesia.com/media-library/f0018fcd-3f9e-496c-a8cc-1a3e241af1c0/bannermodel02b__1680104724056.jpg',
      'headline': 'Performa yang\nBisa Diandalkan',
      'subtitle': 'Teknologi hybrid terbaru, siap jelajahi jalananmu',
    },
  ];

  final List<String> _menuItems = const [
    'Home',
    'Mobil Baru',
    'Promosi',
    'Test Drive',
    'Simulasi Kredit',
    'About Me',
    'Tentang Kami',
    'Hubungi Kami',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || banners.isEmpty) return;
      _currentBanner = (_currentBanner + 1) % banners.length;
      _bannerController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _toggleNav() => setState(() => _isNavOpen = !_isNavOpen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              width: _isNavOpen ? _navWidth : 0,
              color: AppColors.ink,
              child: _isNavOpen
                  ? ClipRect(
                      child: OverflowBox(
                        maxWidth: _navWidth,
                        minWidth: _navWidth,
                        alignment: Alignment.centerLeft,
                        child: _buildSideNav(),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBanner(),
                          _buildCarSection(),
                        ],
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      color: AppColors.hondaRed,
      child: Row(
        children: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                _isNavOpen ? Icons.close : Icons.menu,
                key: ValueKey(_isNavOpen),
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: _toggleNav,
          ),
          const SizedBox(width: 8),
          // Logo mark sederhana: kotak putih + huruf H merah, lalu wordmark.
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'H',
              style: GoogleFonts.barlow(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.hondaRed,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('Honda', style: AppText.logoMark()),
          const SizedBox(width: 4),
          Text('Dealer', style: AppText.logoMark(color: Colors.white70)),
          const Spacer(),
          Obx(() {
            final auth = Get.find<AuthController>();
            if (auth.isGuest) {
              return IconButton(
                tooltip: 'Masuk',
                icon: const Icon(Icons.login, color: Colors.white),
                onPressed: () => Get.to(() => const LoginView()),
              );
            }
            return PopupMenuButton<String>(
              tooltip: 'Akun',
              icon: const Icon(Icons.account_circle,
                  color: Colors.white, size: 28),
              onSelected: (value) async {
                if (value == 'logout') {
                  await auth.logout();
                  Get.snackbar('Keluar', 'Kamu sudah keluar dari akun.');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    auth.nama.value.isEmpty ? auth.email.value : auth.nama.value,
                    style: AppText.body(),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Keluar'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSideNav() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 28),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text('Menu', style: AppText.label(color: Colors.white38)),
        ),
        const SizedBox(height: 4),
        ..._menuItems.map(
          (item) => ListTile(
            title: Text(item, style: AppText.body(color: Colors.white)),
            onTap: () {
              _toggleNav();
              if (item == 'About Me') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutMePage()),
                );
              }
              // TODO: navigasi ke halaman lain sesuai item
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 2.1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _currentBanner = i),
                itemBuilder: (context, index) {
                  return Image.network(
                    banners[index]['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.ink,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 48, color: Colors.white38),
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC15171C),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
              // Aksen merah diagonal di pojok kanan atas, isyarat "sporty"
              Positioned(
                top: -20,
                right: -20,
                child: Transform.rotate(
                  angle: 0.785,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: AppColors.hondaRed.withOpacity(0.85),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 36, height: 4, color: AppColors.hondaRed),
                    const SizedBox(height: 10),
                    Text(
                      banners[_currentBanner]['headline']!,
                      style: AppText.display(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banners[_currentBanner]['subtitle']!,
                      style: AppText.subtitle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        banners.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentBanner == i ? 20 : 6,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: _currentBanner == i
                                ? AppColors.hondaRed
                                : Colors.white38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 20, color: AppColors.hondaRed),
              const SizedBox(width: 10),
              Text('Pilihan Mobil', style: AppText.headline()),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 900 ? 3 : (width > 550 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daftarMobil.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) => _buildCarCard(daftarMobil[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Mobil mobil) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: Container(
                  color: const Color(0xFFF5F5F3),
                  child: Image.network(
                    mobil.gambar,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.directions_car,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // Badge kategori — isi ruang kosong + info tambahan + aksen merah
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.hondaRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mobil.kategori,
                    style: AppText.label(color: Colors.white)
                        .copyWith(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mobil.model,
                      style: AppText.cardTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(mobil.tipe,
                      style: AppText.label(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Text('harga mulai', style: AppText.label()),
                  Text(_formatRupiah(mobil.harga), style: AppText.price()),
                  const Spacer(),
                  Container(height: 1, color: AppColors.line),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.hondaRed,
                              side: const BorderSide(color: AppColors.hondaRed),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final auth = Get.find<AuthController>();
                              if (auth.isRegistered) {
                                Get.to(() => CarDetailPage(mobil: mobil));
                              } else {
                                Get.to(() => const LoginView());
                              }
                            },
                            child: Text('Detail',
                                style:
                                    AppText.label(color: AppColors.hondaRed)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.hondaRed,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              final auth = Get.find<AuthController>();
                              if (auth.isComplete) {
                                Get.to(() => CheckoutPage(mobil: mobil));
                              } else if (auth.isGuest) {
                                Get.snackbar(
                                  'Login dulu',
                                  'Silakan masuk atau daftar akun sebelum membeli.',
                                );
                                Get.to(() => const LoginView());
                              } else {
                                Get.to(() => const RegistrasiDataDiriPage());
                              }
                            },
                            child: Text('Beli',
                                style: AppText.label(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Aksen penutup di bagian paling bawah kartu
          Container(height: 4, color: AppColors.hondaRed),
        ],
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