import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/basic_model.dart';
import 'package:flutter_application_1/models/list_mobil_model.dart';

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

  final List<String> bannerImages = [
    'https://imgcdn.oto.com/large/gallery/exterior/38/1798/toyota-vios-front-angle-low-view-360231.jpg?tr=w-1200,h-600',
    'https://asset.honda-indonesia.com/media-library/f0018fcd-3f9e-496c-a8cc-1a3e241af1c0/bannermodel02b__1680104724056.jpg',
  ];

  final List<String> _menuItems = const [
    'Home',
    'Mobil Baru',
    'Promosi',
    'Test Drive',
    'Simulasi Kredit',
    'Tentang Kami',
    'Hubungi Kami',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || bannerImages.isEmpty) return;
      _currentBanner = (_currentBanner + 1) % bannerImages.length;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
              width: _isNavOpen ? _navWidth : 0,
              color: const Color(0xFF1A1A2E),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
              child: Icon(
                _isNavOpen ? Icons.close : Icons.menu,
                key: ValueKey(_isNavOpen),
                size: 28,
              ),
            ),
            onPressed: _toggleNav,
          ),
          const SizedBox(width: 8),
          const Text(
            'DEALER MOBIL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNav() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'MENU',
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
          ),
        ),
        ..._menuItems.map(
          (item) => ListTile(
            title: Text(item, style: const TextStyle(color: Colors.white)),
            onTap: () {
              _toggleNav();
              // TODO: navigasi ke halaman sesuai item
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 2,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: bannerImages.length,
                onPageChanged: (i) => setState(() => _currentBanner = i),
                itemBuilder: (context, index) {
                  return Image.network(
                    bannerImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerImages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBanner == i ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentBanner == i ? Colors.red : Colors.white70,
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilihan Mobil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
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
                  childAspectRatio: 0.78,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              mobil.gambar,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.directions_car, size: 48, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 8),
          Text(mobil.model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(mobil.tipe, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 6),
          Text('harga mulai', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Text(
            _formatRupiah(mobil.harga),
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () {
                    // TODO: navigasi ke halaman detail mobil
                  },
                  child: const Text('Detail'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // TODO: proses beli / hubungi dealer
                  },
                  child: const Text('Beli'),
                ),
              ),
            ],
          ),
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