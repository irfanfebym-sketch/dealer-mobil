import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';

enum ResetPhase { idle, typing, sending, sent, error }

/// Penghubung antara halaman Reset Password dan panggung animasinya.
class ResetStageController extends ChangeNotifier {
  ResetPhase _phase = ResetPhase.idle;
  int _tick = 0;

  ResetPhase get phase => _phase;
  int get tick => _tick;

  void setPhase(ResetPhase p) {
    _phase = p;
    _tick++;
    notifyListeners();
  }
}

class ResetStage extends StatefulWidget {
  const ResetStage({super.key, required this.controller});
  final ResetStageController controller;

  @override
  State<ResetStage> createState() => _ResetStageState();
}

class _ResetStageState extends State<ResetStage>
    with TickerProviderStateMixin {
  late final AnimationController _loop; // goyang pelan
  late final AnimationController _open; // gembok terbuka
  late final AnimationController _key; // kunci mendekat
  late final AnimationController _turn; // kunci diputar
  late final AnimationController _shake; // getar saat error
  late final AnimationController _mail; // amplop terbang

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _key = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _mail = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _loop.dispose();
    _open.dispose();
    _key.dispose();
    _turn.dispose();
    _shake.dispose();
    _mail.dispose();
    super.dispose();
  }

  void _reset() {
    _open.animateTo(0, duration: const Duration(milliseconds: 350));
    _key.animateTo(0, duration: const Duration(milliseconds: 350));
    _turn.animateTo(0, duration: const Duration(milliseconds: 250));
    _mail.stop();
    _mail.value = 0;
  }

  void _onChange() {
    final c = widget.controller;
    switch (c.phase) {
      case ResetPhase.idle:
      case ResetPhase.typing:
        _reset();
        break;
      case ResetPhase.sending:
        _key.animateTo(1,
            duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic);
        break;
      case ResetPhase.sent:
        _playSent();
        break;
      case ResetPhase.error:
        _reset();
        _shake.forward(from: 0);
        break;
    }
  }

  Future<void> _playSent() async {
    bool batal() => !mounted || widget.controller.phase != ResetPhase.sent;
    await _key.animateTo(1, duration: const Duration(milliseconds: 300));
    if (batal()) return;
    await _turn.animateTo(1, duration: const Duration(milliseconds: 450));
    if (batal()) return;
    await _open.animateTo(1,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack);
    if (batal()) return;
    _mail.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_loop, _open, _key, _turn, _shake, _mail, widget.controller]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ResetPainter(
            loop: _loop.value,
            open: _open.value,
            keyT: _key.value,
            turn: _turn.value,
            shake: _shake.value,
            mail: _mail.value,
            phase: widget.controller.phase,
          ),
        ),
      ),
    );
  }
}

class _ResetPainter extends CustomPainter {
  _ResetPainter({
    required this.loop,
    required this.open,
    required this.keyT,
    required this.turn,
    required this.shake,
    required this.mail,
    required this.phase,
  });

  final double loop, open, keyT, turn, shake, mail;
  final ResetPhase phase;

  double _c01(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = math.min(w, h * 1.2);

    _bubbles(canvas, w, h);

    final cx = w / 2;
    final bw = s * 0.36, bh = bw * 0.8;
    final cy = h * 0.54;
    final bodyTop = cy - bh * 0.35;
    final pivot = Offset(cx, bodyTop + bh / 2);

    final typing = phase == ResetPhase.typing;
    final sway = math.sin(loop * 2 * math.pi * (typing ? 3 : 1)) * (typing ? 0.05 : 0.025);
    final dx = phase == ResetPhase.error
        ? math.sin(shake * math.pi * 10) * (1 - shake) * 12
        : 0.0;

    final errAmt = phase == ResetPhase.error ? 1.0 : 0.0;
    final bodyColor = Color.lerp(Color.lerp(kInk, kOk, open)!, kErr, errAmt)!;

    canvas.save();
    canvas.translate(dx, 0);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(sway);
    canvas.translate(-pivot.dx, -pivot.dy);

    // --- gagang (digambar sebelum badan supaya kaki gagang tertutup badan) ---
    final legL = cx - bw * 0.26;
    final shackleH = bh * 0.42;
    canvas.save();
    canvas.translate(legL, bodyTop + 2);
    canvas.rotate(-open * 0.5);
    canvas.translate(0, -open * bh * 0.18);
    final shackle = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -shackleH)
      ..arcToPoint(
        Offset(bw * 0.52, -shackleH),
        radius: Radius.circular(bw * 0.26),
        clockwise: true,
      )
      ..lineTo(bw * 0.52, 0);
    canvas.drawPath(
      shackle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bw * 0.10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFB8BED2),
    );
    canvas.restore();

    // --- badan gembok ---
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - bw / 2, bodyTop, bw, bh),
      Radius.circular(bw * 0.12),
    );
    canvas.drawRRect(body, Paint()..color = bodyColor);

    // lubang kunci
    final ky = bodyTop + bh * 0.46;
    final hole = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(Offset(cx, ky), bw * 0.06, hole);
    canvas.drawRect(
      Rect.fromLTWH(cx - bw * 0.02, ky, bw * 0.04, bw * 0.12),
      hole,
    );

    // --- kunci ---
    if (keyT > 0.001) {
      final kl = bw * 0.55;
      final kr = bw * 0.11;
      final start = Offset(cx - kl - s * 0.28, ky - s * 0.14);
      final target = Offset(cx - kl, ky);
      final e = Curves.easeOutCubic.transform(_c01(keyT));
      final head = Offset.lerp(start, target, e)!;
      final tip = head + Offset(kl, 0);

      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(turn * 0.9);
      canvas.translate(-tip.dx, -tip.dy);

      final gold = Paint()..color = const Color(0xFFE5B53C);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(head.dx, head.dy - kr * 0.22, kl, kr * 0.44),
          Radius.circular(kr * 0.2),
        ),
        gold,
      );
      canvas.drawRect(
        Rect.fromLTWH(head.dx + kl * 0.70, head.dy, kr * 0.35, kr * 0.75),
        gold,
      );
      canvas.drawRect(
        Rect.fromLTWH(head.dx + kl * 0.88, head.dy, kr * 0.35, kr * 0.55),
        gold,
      );
      canvas.drawCircle(head, kr, gold);
      canvas.drawCircle(head, kr * 0.42, Paint()..color = kStageBg);
      canvas.restore();
    }

    canvas.restore();

    // --- amplop terbang setelah gembok terbuka ---
    if (mail > 0.001) {
      final ex = cx + mail * s * 0.18;
      final ey = bodyTop - bh * 0.1 - mail * s * 0.38;
      final sc = 0.6 + 0.4 * mail;
      final op = mail < 0.8 ? 1.0 : _c01((1 - mail) / 0.2);
      final ew = s * 0.17 * sc, eh = s * 0.115 * sc;
      final rect = Rect.fromCenter(center: Offset(ex, ey), width: ew, height: eh);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = Colors.white.withOpacity(op),
      );
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kInk.withOpacity(op);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        line,
      );
      final flap = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.center.dx, rect.center.dy + eh * 0.05)
        ..lineTo(rect.right, rect.top);
      canvas.drawPath(flap, line);
    }
  }

  void _bubbles(Canvas canvas, double w, double h) {
    final p = Paint()..color = Colors.white.withOpacity(0.35);
    final spots = <List<double>>[
      [0.18, 0.20, 0.06],
      [0.82, 0.30, 0.045],
      [0.25, 0.82, 0.05],
      [0.78, 0.78, 0.07],
    ];
    final base = math.min(w, h);
    for (var i = 0; i < spots.length; i++) {
      final bob = math.sin(loop * 2 * math.pi + i * 1.7) * 6;
      canvas.drawCircle(
        Offset(w * spots[i][0], h * spots[i][1] + bob),
        base * spots[i][2],
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ResetPainter old) => true;
}