import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';

/// Penghubung antara halaman Sign Up dan panggung animasinya.
class SignUpStageController extends ChangeNotifier {
  int _filled = 0;
  int _errorTick = 0;
  bool _success = false;

  int get filled => _filled;
  int get errorTick => _errorTick;
  bool get success => _success;

  /// Jumlah kolom yang sudah terisi benar (0 sampai 4).
  void setFilled(int n) {
    final v = n.clamp(0, 4).toInt();
    if (v == _filled) return;
    _filled = v;
    notifyListeners();
  }

  void error() {
    _errorTick++;
    notifyListeners();
  }

  void win() {
    _success = true;
    notifyListeners();
  }
}

class SignUpStage extends StatefulWidget {
  const SignUpStage({super.key, required this.controller});
  final SignUpStageController controller;

  @override
  State<SignUpStage> createState() => _SignUpStageState();
}

class _SignUpStageState extends State<SignUpStage>
    with TickerProviderStateMixin {
  late final AnimationController _loop; // awan bergerak
  late final AnimationController _pos; // posisi mobil 0..1
  late final AnimationController _door; // pintu garasi, 1 = terbuka
  late final AnimationController _shake; // getar saat error
  int _lastErr = 0;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat();
    _pos = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _door = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _lastErr = widget.controller.errorTick;
    widget.controller.addListener(_onChange);
    _onChange();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _loop.dispose();
    _pos.dispose();
    _door.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onChange() {
    final c = widget.controller;

    if (c.errorTick != _lastErr) {
      _lastErr = c.errorTick;
      _shake.forward(from: 0);
    }

    if (c.success) {
      if (_won) return;
      _won = true;
      _door.animateTo(1, duration: const Duration(milliseconds: 400));
      _pos
          .animateTo(1,
              duration: const Duration(milliseconds: 1300),
              curve: Curves.easeInOut)
          .whenComplete(() {
        if (mounted) {
          _door.animateTo(0, duration: const Duration(milliseconds: 700));
        }
      });
      return;
    }

    // Maksimum 0.45 = berhenti tepat di depan pintu garasi.
    final target = c.filled / 4 * 0.45;
    _pos.animateTo(target,
        duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    _door.animateTo(c.filled >= 4 ? 1 : 0,
        duration: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _pos, _door, _shake, widget.controller]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _SignUpPainter(
            loop: _loop.value,
            pos: _pos.value,
            door: _door.value,
            shake: _shake.value,
            filled: widget.controller.filled,
            success: widget.controller.success,
          ),
        ),
      ),
    );
  }
}

class _SignUpPainter extends CustomPainter {
  _SignUpPainter({
    required this.loop,
    required this.pos,
    required this.door,
    required this.shake,
    required this.filled,
    required this.success,
  });

  final double loop, pos, door, shake;
  final int filled;
  final bool success;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = math.min(w, h * 1.3);

    final roadTop = h * 0.70;
    final roadH = h * 0.14;
    final floor = roadTop + roadH * 0.82; // alas garasi = dasar roda mobil

    // --- awan ---
    _cloud(canvas, ((loop + 0.1) % 1.0) * (w + 160) - 80, h * 0.24, s * 0.035);
    _cloud(canvas, ((loop * 2 + 0.55) % 1.0) * (w + 160) - 80, h * 0.38, s * 0.025);

    // --- indikator langkah (4 titik) ---
    for (var i = 0; i < 4; i++) {
      final lit = success || i < filled;
      canvas.drawCircle(
        Offset(w / 2 + (i - 1.5) * 20, h * 0.09),
        6,
        Paint()..color = lit ? kShirt : kLine,
      );
    }

    // --- jalan + marka yang bergeser saat mobil maju ---
    canvas.drawRect(
      Rect.fromLTWH(0, roadTop, w, roadH),
      Paint()..color = const Color(0xFF3A3F55),
    );
    final period = s * 0.14;
    final dashW = s * 0.07;
    final shift = (-pos * w * 1.3) % period;
    final dashPaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (double x = shift - period; x < w + period; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, roadTop + roadH * 0.50, dashW, 3),
        dashPaint,
      );
    }

    // --- garasi ---
    final gw = s * 0.40, gh = s * 0.32;
    final gx = w - gw - w * 0.03;
    final gTop = floor - gh;

    final roof = Path()
      ..moveTo(gx - gw * 0.06, gTop)
      ..lineTo(gx + gw / 2, gTop - gh * 0.28)
      ..lineTo(gx + gw * 1.06, gTop)
      ..close();
    canvas.drawPath(roof, Paint()..color = kInk);

    canvas.drawRect(
      Rect.fromLTWH(gx, gTop, gw, gh),
      Paint()..color = Colors.white,
    );

    final ow = gw * 0.86, oh = gh * 0.74;
    final ox = gx + (gw - ow) / 2;
    final oy = floor - oh;
    canvas.drawRect(
      Rect.fromLTWH(ox, oy, ow, oh),
      Paint()..color = const Color(0xFF2A2E40),
    );

    // papan nama kecil di atas pintu
    final tp = TextPainter(
      text: const TextSpan(
        text: 'GARASI',
        style: TextStyle(
          color: kMuted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(gx + (gw - tp.width) / 2, gTop + (oy - gTop - tp.height) / 2));

    // --- mobil ---
    final carW = s * 0.26;
    final xStart = w * 0.04;
    final xEnd = gx + (gw - carW) / 2;
    final left = xStart + (xEnd - xStart) * pos;
    final dx = math.sin(shake * math.pi * 10) * (1 - shake) * 9;
    final spin = pos * (xEnd - xStart) / (carW * 0.11);

    canvas.save();
    canvas.translate(dx, 0);
    _car(canvas, left, floor - 1, carW, spin);
    canvas.restore();

    // --- pintu garasi (menutup mobil bila door = 0) ---
    final dh = oh * (1 - door);
    if (dh > 0.5) {
      canvas.drawRect(
        Rect.fromLTWH(ox, oy, ow, dh),
        Paint()..color = const Color(0xFFE9ECF5),
      );
      final slat = Paint()
        ..color = kLine
        ..strokeWidth = 2;
      for (double y = oy + oh / 6; y < oy + dh; y += oh / 6) {
        canvas.drawLine(Offset(ox, y), Offset(ox + ow, y), slat);
      }
    }
  }

  void _cloud(Canvas c, double x, double y, double r) {
    final p = Paint()..color = Colors.white.withOpacity(0.75);
    c.drawCircle(Offset(x, y), r, p);
    c.drawCircle(Offset(x + r * 1.1, y - r * 0.3), r * 1.2, p);
    c.drawCircle(Offset(x + r * 2.3, y), r * 0.9, p);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - r, y, r * 4.2, r),
        Radius.circular(r * 0.5),
      ),
      p,
    );
  }

  void _car(Canvas c, double left, double bottom, double carW, double spin) {
    final wheelR = carW * 0.11;
    final bodyH = carW * 0.20;
    final bodyBottom = bottom - wheelR * 0.9;
    final bodyTop = bodyBottom - bodyH;
    final cabinTop = bodyTop - carW * 0.17;

    // bayangan
    c.drawOval(
      Rect.fromLTWH(left + carW * 0.05, bottom - 3, carW * 0.9, 6),
      Paint()..color = Colors.black.withOpacity(0.18),
    );

    // kabin
    final cabin = Path()
      ..moveTo(left + carW * 0.18, bodyTop)
      ..lineTo(left + carW * 0.30, cabinTop)
      ..lineTo(left + carW * 0.66, cabinTop)
      ..lineTo(left + carW * 0.82, bodyTop)
      ..close();
    c.drawPath(cabin, Paint()..color = kShirtDark);

    // kaca
    final glass = Path()
      ..moveTo(left + carW * 0.23, bodyTop - 1)
      ..lineTo(left + carW * 0.33, cabinTop + carW * 0.025)
      ..lineTo(left + carW * 0.63, cabinTop + carW * 0.025)
      ..lineTo(left + carW * 0.76, bodyTop - 1)
      ..close();
    c.drawPath(glass, Paint()..color = const Color(0xFFCFE6F5));
    c.drawLine(
      Offset(left + carW * 0.48, cabinTop + carW * 0.025),
      Offset(left + carW * 0.48, bodyTop - 1),
      Paint()
        ..color = kShirtDark
        ..strokeWidth = 2,
    );

    // bodi
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, bodyTop, carW, bodyH),
        Radius.circular(carW * 0.05),
      ),
      Paint()..color = kShirt,
    );

    // lampu depan & belakang
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + carW * 0.93, bodyTop + bodyH * 0.2, carW * 0.07, bodyH * 0.3),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFE08A),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, bodyTop + bodyH * 0.2, carW * 0.04, bodyH * 0.3),
        const Radius.circular(2),
      ),
      Paint()..color = kShirtDark,
    );

    // roda
    _wheel(c, Offset(left + carW * 0.25, bottom - wheelR), wheelR, spin);
    _wheel(c, Offset(left + carW * 0.75, bottom - wheelR), wheelR, spin);
  }

  void _wheel(Canvas c, Offset ctr, double r, double angle) {
    c.drawCircle(ctr, r, Paint()..color = kInk);
    c.drawCircle(ctr, r * 0.55, Paint()..color = const Color(0xFFB8BED2));
    final spoke = Paint()
      ..color = kInk
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      c.drawLine(ctr, ctr + Offset(math.cos(a), math.sin(a)) * (r * 0.5), spoke);
    }
  }

  @override
  bool shouldRepaint(covariant _SignUpPainter old) => true;
}