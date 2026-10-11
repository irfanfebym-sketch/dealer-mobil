import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';

enum StageMode { idle, email, pass, peek, error, ok }

enum Mouth { neutral, smile, sad, o }
enum Intro { fall, rope, slideSide, slideTop }
enum React { none, startle, jump, faint }

class CharSpec {
  CharSpec({
    required this.color,
    required this.shape,
    required this.face,
    required this.pivot,
    required this.gap,
    required this.my,
    required this.follow,
    required this.passLean,
    required this.idle,
    required this.intro,
    required this.react,
    required this.delay,
    required this.shirtTop,
    required this.shirtL,
    required this.shirtR,
    required this.sleeve,
    required this.buttons,
    required this.logo,
    required this.logoSize,
    this.light = false,
  });

  final Intro intro;
  final React react;
  final double delay; // jeda (detik) sebelum karakter mulai muncul
  final double shirtTop; // garis bahu: baju mulai dari y ini ke bawah
  final double shirtL, shirtR; // tepi kiri/kanan badan di garis bahu
  final double sleeve; // ukuran lengan baju (1.0 = normal)
  final int buttons; // jumlah kancing
  final Offset logo; // titik tengah logo "H" di dada (koordinat kanvas virtual)
  final double logoSize; // ukuran lencana logo
  late final Rect bounds = shape.getBounds();

  final Color color;
  final Path shape;
  final Offset face; // titik tengah wajah (antara dua mata)
  final Offset pivot; // titik putar saat badan miring (dasar karakter)
  final double gap; // jarak mata ke tengah wajah
  final double my; // posisi mulut di bawah wajah
  final double follow; // seberapa kuat badan ikut miring ke kursor
  final double passLean; // kemiringan (derajat) saat password diketik
  final Mouth idle;
  final bool light; // true = gambar mulut berwarna putih
}

// Kanvas virtual berukuran 420 x 360, lalu diskalakan agar pas.
final List<CharSpec> kSpecs = [
  CharSpec(
    color: const Color(0xFF1FA39A),
    shape: Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(90, 90, 110, 270), const Radius.circular(6))),
    face: const Offset(145, 140),
    pivot: const Offset(145, 360),
    gap: 18, my: 26, follow: 1.0, passLean: -12, idle: Mouth.neutral,
    intro: Intro.rope, react: React.startle, delay: 0.2,
    shirtTop: 186, shirtL: 90, shirtR: 200, sleeve: 1.0, buttons: 4,
    logo: const Offset(115, 238), logoSize: 22,
  ),
  CharSpec(
    color: kInk,
    shape: Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(190, 190, 70, 170), const Radius.circular(6))),
    face: const Offset(225, 226),
    pivot: const Offset(225, 360),
    gap: 12, my: 20, follow: 0.8, passLean: -7, idle: Mouth.neutral,
    intro: Intro.fall, react: React.none, delay: 0.5,
    shirtTop: 266, shirtL: 190, shirtR: 260, sleeve: 0.8, buttons: 3,
    logo: const Offset(209, 292), logoSize: 15,
    light: true,
  ),
  CharSpec(
    color: const Color(0xFFFF6F59),
    shape: Path()
      ..moveTo(8, 362)
      ..arcToPoint(const Offset(212, 362),
          radius: const Radius.circular(102), clockwise: true)
      ..close(),
    face: const Offset(110, 304),
    pivot: const Offset(110, 360),
    gap: 20, my: 22, follow: 0.4, passLean: -3, idle: Mouth.smile,
    intro: Intro.slideSide, react: React.jump, delay: 1.1,
    shirtTop: 336, shirtL: 11, shirtR: 209, sleeve: 0.55, buttons: 0,
    logo: const Offset(78, 349), logoSize: 13,
  ),
  CharSpec(
    color: const Color(0xFFF5C443),
    shape: Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(250, 250, 80, 150), const Radius.circular(40))),
    face: const Offset(290, 292),
    pivot: const Offset(290, 360),
    gap: 12, my: 18, follow: 0.6, passLean: -6, idle: Mouth.neutral,
    intro: Intro.slideTop, react: React.faint, delay: 1.7,
    shirtTop: 326, shirtL: 250, shirtR: 330, sleeve: 0.8, buttons: 0,
    logo: const Offset(271, 346), logoSize: 14,
  ),
];

// 2. State animasi (dihitung setiap frame oleh Ticker)
class StageAnim extends ChangeNotifier {
  StageMode mode = StageMode.idle;
  Offset? pointer; // posisi kursor (koordinat layar)
  GlobalKey? key; // kunci milik widget kanvas, untuk konversi koordinat
  GlobalKey? emailKey, passKey; // kunci kolom email & password (target tatapan)

  /// Titik tengah sebuah widget dalam koordinat layar (null jika belum tampil).
  Offset? _centerOf(GlobalKey? k) {
    final rb = k?.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || !rb.attached || !rb.hasSize) return null;
    return rb.localToGlobal(rb.size.center(Offset.zero));
  }

  final List<double> lean = List.filled(4, 0.0); // radian
  final List<Offset> pupil = List.filled(4, Offset.zero);
  double eye = 1; // 1 = terbuka, 0.08 = tertutup
  double fly = 0, flyTarget = 0; // karakter hitam terlempar (0..1)
  double shakeT = -1, hopT = -1; // -1 = tidak aktif
  double _clock = 0;

  // --- Animasi muncul (intro) ---
  double introT = 0; // detik sejak intro dimulai
  final List<Offset> introOff = List.filled(4, Offset.zero); // geseran masuk
  final List<double> introRot = List.filled(4, 0.0); // condong saat bergerak
  final List<bool> moving = List.filled(4, false); // true = masih melayang
  bool ropeOn = false;
  Offset ropePivot = Offset.zero; // titik gantung tali (kanvas virtual)
  double ropeAngle = 0, ropeLen = 0; // sudut & panjang tali
  double swing = 0; // sudut ayunan badan karakter yang bergelantungan

  // --- Reaksi saat login salah ---
  double errT = -1; // detik sejak error dimulai; -1 = tidak aktif
  final List<Offset> reactOff = List.filled(4, Offset.zero); // geser (loncat, getar)
  final List<double> reactRot = List.filled(4, 0.0); // oleng (radian)
  final List<double> eyeBig = List.filled(4, 1.0); // 1 = normal, >1 = mata melebar
  final List<bool> dizzy = List.filled(4, false); // true = mata X
  final List<bool> shock = List.filled(4, false); // true = mulut "o"
  final List<double> faint = List.filled(4, 0.0); // sudut rebah (radian)
  final List<double> excl = List.filled(4, 0.0); // skala tanda seru "!"
  final List<double> stars = List.filled(4, 0.0); // skala bintang pusing

  /// Mainkan ulang animasi muncul (dipanggil saat panggung diketuk).
  void replayIntro() => introT = 0;

  /// Posisi vertikal (<= 0) benda yang dijatuhkan dari ketinggian [h],
  /// lalu memantul beberapa kali sampai diam di tanah (0).
  static double _bounce(double tau, double h) {
    const g = 2600.0, e = 0.36;
    if (tau <= 0) return -h;
    final t0 = math.sqrt(2 * h / g);
    if (tau < t0) return -h + 0.5 * g * tau * tau;
    var rem = tau - t0;
    var v = g * t0 * e;
    while (v > 25) {
      final dur = 2 * v / g;
      if (rem < dur) return -(v * rem - 0.5 * g * rem * rem);
      rem -= dur;
      v *= e;
    }
    return 0;
  }

  void _stepIntro(double topSpace, double leftSpace) {
    ropeOn = false;
    for (var i = 0; i < kSpecs.length; i++) {
      final sp = kSpecs[i];
      final t = introT - sp.delay;
      var off = Offset.zero;
      var rot = 0.0;
      var air = false;

      switch (sp.intro) {
        case Intro.fall:
          {
            // Jatuh bebas dari luar layar, lalu memantul.
            final dy = _bounce(t, topSpace + 380);
            off = Offset(0, dy);
            air = dy < -2;
          }

        case Intro.rope:
          {
            const hang = 150.0, lowerDur = 1.3, swingDur = 1.9;
            const amp = 0.34, decay = 0.6, omega = 4.6;
            final pivotY = math.min(-200.0, -(topSpace + 20));
            final top = sp.bounds.top;
            ropePivot = Offset(sp.face.dx, pivotY);
            final startDy = -(topSpace + 400);
            final thetaRel =
                amp * math.exp(-decay * swingDur) * math.sin(omega * swingDur);

            double dy, theta = 0, len;
            if (t < lowerDur) {
              // 1) Diturunkan perlahan lewat tali.
              final u = (t / lowerDur).clamp(0.0, 1.0).toDouble();
              dy = startDy + (-hang - startDy) * Curves.easeOutCubic.transform(u);
              len = top + dy - pivotY;
              ropeAngle = 0;
              ropeOn = t >= 0;
              air = true;
            } else if (t < lowerDur + swingDur) {
              // 2) Berayun seperti bandul, makin lama makin kecil.
              final ts = t - lowerDur;
              theta = amp * math.exp(-decay * ts) * math.sin(omega * ts);
              dy = -hang;
              len = top + dy - pivotY;
              ropeAngle = theta;
              ropeOn = true;
              air = true;
            } else {
              // 3) Tali lepas: karakter jatuh ke tanah, tali ditarik ke atas.
              final tau = t - lowerDur - swingDur;
              final t0 = math.sqrt(2 * hang / 2600);
              dy = _bounce(tau, hang);
              theta = thetaRel * (1 - (tau / t0).clamp(0.0, 1.0).toDouble());
              final r = (tau / 0.5).clamp(0.0, 1.0).toDouble();
              len = (top - hang - pivotY) * (1 - Curves.easeIn.transform(r));
              ropeAngle = thetaRel;
              ropeOn = r < 1;
              air = dy < -2;
            }
            off = Offset(0, dy);
            swing = theta;
            ropeLen = math.max(0.0, len);
          }

        case Intro.slideSide:
          {
            // Meluncur dari kiri, sedikit melewati titik akhir lalu kembali.
            const dur = 1.0;
            final u = (t / dur).clamp(0.0, 1.0).toDouble();
            final p = Curves.easeOutBack.transform(u);
            final start = -(sp.bounds.right + leftSpace + 30);
            off = Offset(start * (1 - p), 0);
            rot = 0.22 * (1 - p);
            air = u < 1;
          }

        case Intro.slideTop:
          {
            // Meluncur turun dari atas, lalu melompat kecil saat tiba.
            const dur = 0.95;
            final u = (t / dur).clamp(0.0, 1.0).toDouble();
            final p = Curves.easeOutQuart.transform(u);
            final start = -(topSpace + 440);
            final hu = ((t - dur) / 0.4).clamp(0.0, 1.0).toDouble();
            off = Offset(0, start * (1 - p) - 16 * math.sin(math.pi * hu));
            air = t < dur + 0.4;
          }
      }

      introOff[i] = off;
      introRot[i] = rot;
      moving[i] = air;
    }
  }

  void _stepReact() {
    for (var i = 0; i < kSpecs.length; i++) {
      reactOff[i] = Offset.zero;
      reactRot[i] = 0;
      eyeBig[i] = 1;
      dizzy[i] = false;
      shock[i] = false;
      faint[i] = 0;
      excl[i] = 0;
      stars[i] = 0;
    }
    if (errT < 0) return;
    final t = errT;

    for (var i = 0; i < kSpecs.length; i++) {
      final sp = kSpecs[i];
      switch (sp.react) {
        case React.none:
          break;

        case React.startle:
          {
            // Melonjak kaget, miring ke belakang, lalu gemetar sebelum tenang.
            final hop = (t / 0.28).clamp(0.0, 1.0).toDouble();
            final env = t < 1.3 ? 1.0 : (1 - (t - 1.3) / 0.4).clamp(0.0, 1.0).toDouble();
            final tilt = Curves.easeOut.transform((t / 0.15).clamp(0.0, 1.0).toDouble());
            reactOff[i] = Offset(math.sin(t * 70) * 2.2 * env, -20 * math.sin(math.pi * hop));
            reactRot[i] = -0.2 * tilt * env;
            eyeBig[i] = env > 0 ? 1.3 : 1;
            shock[i] = env > 0;
            final pop = Curves.easeOutBack.transform((t / 0.2).clamp(0.0, 1.0).toDouble());
            final fade = t < 1.1 ? 1.0 : (1 - (t - 1.1) / 0.2).clamp(0.0, 1.0).toDouble();
            excl[i] = pop * fade;
          }

        case React.jump:
          {
            // Tiga kali loncat, makin lama makin pendek.
            const heights = [46.0, 34.0, 20.0];
            const dur = 0.42;
            final tj = t - 0.12;
            var dy = 0.0, rot = 0.0;
            var air = false;
            if (tj > 0) {
              final idx = (tj / dur).floor();
              if (idx < heights.length) {
                final u = tj / dur - idx;
                dy = -heights[idx] * 4 * u * (1 - u);
                rot = 0.12 * math.sin(u * 2 * math.pi);
                air = true;
              }
            }
            reactOff[i] = Offset(0, dy);
            reactRot[i] = rot;
            shock[i] = air || t < 0.12;
            eyeBig[i] = shock[i] ? 1.25 : 1;
          }

        case React.faint:
          {
            const fallAt = 0.95, fallDur = 0.32, wakeAt = 2.5, wakeDur = 0.65;
            // Geser sedikit saat rebah supaya tubuh yang berbaring tidak keluar kanvas.
            final slide = math.min(0.0, 420 - (sp.bounds.right + (360 - sp.bounds.top)));
            var ang = 0.0, rot = 0.0, shake = 0.0;

            if (t < 0.3) {
              // Kaget sesaat.
              shake = math.sin(t * 70) * 2.2;
              eyeBig[i] = 1.3;
            } else if (t < fallAt) {
              // Pusing: oleng kiri-kanan makin besar.
              final k = (t - 0.3) / (fallAt - 0.3);
              rot = math.sin((t - 0.3) * 12) * (0.04 + 0.12 * k);
              dizzy[i] = true;
            } else if (t < wakeAt) {
              // Rebah ke kanan dengan percepatan, memantul sedikit saat menyentuh tanah.
              final u = ((t - fallAt) / fallDur).clamp(0.0, 1.0).toDouble();
              ang = (math.pi / 2) * u * u;
              final tb = t - fallAt - fallDur;
              if (tb > 0) ang -= 0.12 * math.exp(-9 * tb) * math.sin(16 * tb).abs();
              dizzy[i] = true;
            } else if (t < wakeAt + wakeDur) {
              // Sadar lagi dan bangun perlahan.
              final u = ((t - wakeAt) / wakeDur).clamp(0.0, 1.0).toDouble();
              ang = (math.pi / 2) * (1 - Curves.easeInOut.transform(u));
              dizzy[i] = u < 0.35;
            }

            faint[i] = ang;
            reactOff[i] = Offset(slide * ang / (math.pi / 2) + shake, 0);
            reactRot[i] = rot;
            shock[i] = t < wakeAt + 0.2;

            final starIn = ((t - 0.3) / 0.15).clamp(0.0, 1.0).toDouble();
            final starOut = (1 - (t - wakeAt) / 0.3).clamp(0.0, 1.0).toDouble();
            stars[i] = starIn * starOut;
          }
      }
    }
  }

  void triggerError() {
    errT = 0;
    flyTarget = 1;
    shakeT = 0;
    Future.delayed(const Duration(milliseconds: 1000), () => flyTarget = 0);
  }

  void triggerOk() => hopT = 0;

  Mouth mouthFor(int i) {
    if (moving[i] || shock[i]) return Mouth.o; // kaget / melayang
    return switch (mode) {
      StageMode.error => Mouth.sad,
      StageMode.ok || StageMode.email => Mouth.smile,
      StageMode.peek => Mouth.o,
      _ => kSpecs[i].idle,
    };
  }

  void step(double dt) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _clock += dt;

    final size = box.size;
    final s = math.min(size.width / 420, size.height / 360);
    final origin = Offset((size.width - 420 * s) / 2, size.height - 360 * s);

    introT += dt;
    _stepIntro(origin.dy / s, origin.dx / s); // ruang kosong di atas & kiri
    if (errT >= 0) {
      errT += dt;
      if (errT > 3.3) errT = -1;
    }
    _stepReact();

    final kPupil = 1 - math.exp(-dt * 16);
    final kLean = 1 - math.exp(-dt * 8);
    final kEye = 1 - math.exp(-dt * 25);

    // Posisi kolom email & password saat ini (ikut berubah jika layar di-resize).
    final emailT = _centerOf(emailKey);
    final passT = _centerOf(passKey);

    // Kedip tiap 3,8 detik, kecuali saat mata memang tertutup.
    final blinking = mode != StageMode.pass && (_clock % 3.8) < 0.13;
    final eyeTarget = (mode == StageMode.pass || blinking) ? 0.08 : 1.0;
    eye += (eyeTarget - eye) * kEye;

    for (var i = 0; i < kSpecs.length; i++) {
      final sp = kSpecs[i];
      var look = Offset.zero;
      var leanDeg = 0.0;

      switch (mode) {
        case StageMode.idle:
          final p = pointer;
          if (p != null) {
            final face = box.localToGlobal(origin + sp.face * s);
            final d = p - face;
            final dist = math.max(d.distance, 1.0);
            look = d / dist * math.min(1.0, dist / 220) * 3.6;
            leanDeg = (d.dx / 260 * 5).clamp(-5.0, 5.0).toDouble() * sp.follow;
          }
        case StageMode.email: // menatap lurus ke kolom email
        case StageMode.peek: // menatap lurus ke kolom password yang ditampilkan
          {
            final target = mode == StageMode.email ? emailT : passT;
            final maxLean = mode == StageMode.email ? 2.0 : 3.0;
            if (target != null) {
              // Arah dari wajah karakter ke tengah kolom, jadi tiap karakter
              // menatap tepat ke kolomnya dari posisi masing-masing.
              final d = target - box.localToGlobal(origin + sp.face * s);
              look = d / math.max(d.distance, 1.0) * 3.8;
              leanDeg = (d.dx / 200 * maxLean).clamp(-maxLean, maxLean).toDouble() * sp.follow;
            }
          }
        case StageMode.pass: // menjauh dan menutup mata
          leanDeg = sp.passLean;
        case StageMode.error:
          look = const Offset(0, 2.5);
        case StageMode.ok:
          break;
      }

      if (moving[i]) leanDeg = 0;
      lean[i] += (leanDeg * math.pi / 180 - lean[i]) * kLean;
      pupil[i] = Offset.lerp(pupil[i], look, kPupil)!;
    }

    if (fly < flyTarget) fly = math.min(flyTarget, fly + dt / 0.55);
    if (fly > flyTarget) fly = math.max(flyTarget, fly - dt / 0.70);
    if (shakeT >= 0) {
      shakeT += dt;
      if (shakeT > 0.5) shakeT = -1;
    }
    if (hopT >= 0) {
      hopT += dt;
      if (hopT > 0.85) hopT = -1;
    }
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// 3. Painter: menggambar karakter di canvas
// ---------------------------------------------------------------------------

class StagePainter extends CustomPainter {
  StagePainter(this.a) : super(repaint: a);
  final StageAnim a;

  static const _dark = Color(0xFF16181F);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 420, size.height / 360);
    final shakeDx = a.shakeT >= 0
        ? math.sin(a.shakeT * 45) * 9 * (1 - a.shakeT / 0.5)
        : 0.0;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - 420 * s) / 2 + shakeDx * s, size.height - 360 * s);
    canvas.scale(s);
    if (a.ropeOn) _drawRope(canvas);
    for (var i = 0; i < kSpecs.length; i++) {
      _drawChar(canvas, i);
    }
    for (var i = 0; i < kSpecs.length; i++) {
      _drawStars(canvas, i); // bintang pusing di atas semua karakter
    }
    canvas.restore();
  }

  /// Tanda seru merah di atas kepala karakter yang kaget.
  void _drawExclaim(Canvas canvas, CharSpec sp, double k) {
    canvas.save();
    canvas.translate(sp.face.dx, sp.bounds.top - 22);
    canvas.scale(k);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = kErr;
    canvas.drawLine(const Offset(0, -16), const Offset(0, 2), p);
    canvas.drawCircle(const Offset(0, 14), 3.6, Paint()..color = kErr);
    canvas.restore();
  }

  /// Tiga bintang berputar di atas kepala karakter yang pusing / pingsan.
  void _drawStars(Canvas canvas, int i) {
    final k = a.stars[i];
    if (k <= 0) return;
    final sp = kSpecs[i];
    // Posisi wajah di layar, mengikuti rebahnya karakter.
    final pv = Offset(sp.bounds.right, 360);
    final rel = sp.face - pv;
    final c = math.cos(a.faint[i]), sn = math.sin(a.faint[i]);
    final head = pv + Offset(rel.dx * c - rel.dy * sn, rel.dx * sn + rel.dy * c) + a.reactOff[i];
    for (var j = 0; j < 3; j++) {
      final ph = a.errT * 6 + j * 2 * math.pi / 3;
      final pos = head + Offset(math.cos(ph) * 22, -46 + math.sin(ph) * 6);
      _drawStar(canvas, pos, 6.5 * k);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var j = 0; j < 10; j++) {
      final rad = j.isEven ? r : r * 0.45;
      final ang = -math.pi / 2 + j * math.pi / 5;
      final pt = c + Offset(math.cos(ang) * rad, math.sin(ang) * rad);
      if (j == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFC107));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = kInk,
    );
  }

  /// Tali tergantung dari titik di atas layar hingga ke kepala karakter.
  void _drawRope(Canvas canvas) {
    final p = a.ropePivot;
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(a.ropeAngle);
    canvas.drawLine(
      Offset.zero,
      Offset(0, a.ropeLen),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..color = kRope,
    );
    canvas.drawCircle(Offset(0, a.ropeLen), 5, Paint()..color = kRope); // simpul
    canvas.restore();
  }

  /// Baju merah: lengan, badan (mengikuti bentuk karakter), kerah V, kancing.
  void _drawShirt(Canvas canvas, CharSpec sp) {
    final k = sp.sleeve;
    final cx = sp.face.dx;
    final top = sp.shirtTop;
    final red = Paint()..color = kShirt;

    // Lengan baju, sedikit miring ke luar.
    for (final side in const [-1.0, 1.0]) {
      final edge = side < 0 ? sp.shirtL : sp.shirtR;
      canvas.save();
      canvas.translate(edge + side * 4 * k, top + 15 * k);
      canvas.rotate(-side * 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 18 * k, height: 34 * k),
          Radius.circular(8 * k),
        ),
        red,
      );
      canvas.restore();
    }

    // Badan baju: dipotong mengikuti bentuk karakter.
    canvas.save();
    canvas.clipPath(sp.shape);
    canvas.drawRect(Rect.fromLTRB(sp.shirtL - 30, top, sp.shirtR + 30, 420), red);

    // Kerah V: bagian tengah memperlihatkan warna badan karakter.
    final w = 13 * k, d = 18 * k;
    canvas.drawPath(
      Path()
        ..moveTo(cx - w, top - 1)
        ..lineTo(cx + w, top - 1)
        ..lineTo(cx, top + d)
        ..close(),
      Paint()..color = sp.color,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - w, top)
        ..lineTo(cx, top + d)
        ..lineTo(cx + w, top),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = kShirtDark,
    );

    // Kancing
    for (var j = 0; j < sp.buttons; j++) {
      canvas.drawCircle(
          Offset(cx, top + d + 14 + j * 20), 2.6, Paint()..color = kShirtDark);
    }

    // Logo "H": lencana putih dengan huruf H merah di dada kiri.
    final lc = sp.logo, ls = sp.logoSize;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: lc, width: ls, height: ls),
        Radius.circular(ls * 0.28),
      ),
      Paint()..color = Colors.white,
    );
    final hw = ls * 0.25, hh = ls * 0.3;
    canvas.drawPath(
      Path()
        ..moveTo(lc.dx - hw, lc.dy - hh)
        ..lineTo(lc.dx - hw, lc.dy + hh)
        ..moveTo(lc.dx + hw, lc.dy - hh)
        ..lineTo(lc.dx + hw, lc.dy + hh)
        ..moveTo(lc.dx - hw, lc.dy)
        ..lineTo(lc.dx + hw, lc.dy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ls * 0.14
        ..strokeCap = StrokeCap.round
        ..color = kShirt,
    );
    canvas.restore();
  }

  void _drawChar(Canvas canvas, int i) {
    final sp = kSpecs[i];
    final isB = i == 1;
    final flyE = isB ? Curves.easeIn.transform(a.fly) : 0.0;

    var hopY = 0.0;
    if (a.hopT >= 0) {
      final t = ((a.hopT - i * 0.07) / 0.6).clamp(0.0, 1.0).toDouble();
      hopY = -22 * math.sin(math.pi * t);
    }

    final layered = isB && flyE > 0;
    if (layered) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, 1 - flyE));
    }
    canvas.save();

    if (layered) {
      canvas.translate(190 * flyE, -320 * flyE);
      canvas.translate(225, 275);
      canvas.rotate(150 * math.pi / 180 * flyE);
      canvas.translate(-225, -275);
    }
    canvas.translate(0, hopY);

    // Animasi muncul: ayunan terhadap titik gantung tali (jika ada), lalu geseran.
    if (sp.intro == Intro.rope) {
      final rp = a.ropePivot;
      canvas.translate(rp.dx, rp.dy);
      canvas.rotate(a.swing);
      canvas.translate(-rp.dx, -rp.dy);
    }
    canvas.translate(a.introOff[i].dx, a.introOff[i].dy);

    // Reaksi error: loncat / gemetar (geser), dan rebah pingsan (putar di sudut kaki).
    canvas.translate(a.reactOff[i].dx, a.reactOff[i].dy);
    if (a.faint[i] > 0) {
      final fx = sp.bounds.right;
      canvas.translate(fx, 360);
      canvas.rotate(a.faint[i]);
      canvas.translate(-fx, -360);
    }

    // Badan miring dengan titik putar di dasar karakter.
    canvas.translate(sp.pivot.dx, sp.pivot.dy);
    canvas.rotate(a.lean[i] + a.introRot[i] + a.reactRot[i]);
    canvas.translate(-sp.pivot.dx, -sp.pivot.dy);

    canvas.drawPath(sp.shape, Paint()..color = sp.color);
    _drawShirt(canvas, sp);

    // Mata
    final big = a.eyeBig[i];
    // Badan bisa miring; putar balik pupil agar arah tatapan tetap lurus di layar.
    final bodyRot = a.lean[i] + a.introRot[i] + a.reactRot[i];
    final pc = math.cos(-bodyRot), ps = math.sin(-bodyRot);
    final pupilPos = Offset(
      a.pupil[i].dx * pc - a.pupil[i].dy * ps,
      a.pupil[i].dx * ps + a.pupil[i].dy * pc,
    );
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(sp.face.dx + side * sp.gap, sp.face.dy);
      canvas.scale(1, a.dizzy[i] ? 1.0 : a.eye);
      canvas.drawCircle(Offset.zero, 8 * big, Paint()..color = Colors.white);
      if (a.dizzy[i]) {
        // Mata X = pingsan.
        canvas.drawPath(
          Path()
            ..moveTo(-4.5, -4.5)
            ..lineTo(4.5, 4.5)
            ..moveTo(4.5, -4.5)
            ..lineTo(-4.5, 4.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round
            ..color = _dark,
        );
      } else {
        // Saat kaget pupil mengecil.
        canvas.drawCircle(pupilPos, big > 1 ? 2.8 : 4, Paint()..color = _dark);
      }
      canvas.restore();
    }

    // Mulut
    final m = Path();
    switch (a.mouthFor(i)) {
      case Mouth.neutral:
        m..moveTo(-6, 0)..lineTo(6, 0);
      case Mouth.smile:
        m..moveTo(-8, -2)..quadraticBezierTo(0, 8, 8, -2);
      case Mouth.sad:
        m..moveTo(-8, 3)..quadraticBezierTo(0, -5, 8, 3);
      case Mouth.o:
        m.addOval(Rect.fromCircle(center: Offset.zero, radius: 3));
    }
    canvas.save();
    canvas.translate(sp.face.dx, sp.face.dy + sp.my);
    canvas.drawPath(
      m,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = sp.light ? Colors.white : _dark,
    );
    canvas.restore();

    if (a.excl[i] > 0) _drawExclaim(canvas, sp, a.excl[i]);

    canvas.restore();
    if (layered) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StagePainter old) => old.a != a;
}

// ---------------------------------------------------------------------------
// 4. Pembungkus: ticker + kunci milik halaman login
// ---------------------------------------------------------------------------

/// Menyimpan animasi, ticker, dan kunci widget untuk satu halaman.
/// Dibuat di initState() dengan `AuthStageHost(vsync: this)` dan
/// wajib dipanggil dispose()-nya di dispose().
class AuthStageHost {
  AuthStageHost({required TickerProvider vsync}) {
    anim.key = stageKey;
    anim.emailKey = emailKey;
    anim.passKey = passKey;
    _ticker = vsync.createTicker((elapsed) {
      final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble();
      _last = elapsed;
      anim.step(dt);
    })
      ..start();
  }

  final StageAnim anim = StageAnim();
  final GlobalKey stageKey = GlobalKey();
  final GlobalKey emailKey = GlobalKey();
  final GlobalKey passKey = GlobalKey();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  void dispose() {
    _ticker.dispose();
    anim.dispose();
  }
}


/// Widget panggung yang dipasang ke AuthLayout(stage: ...).
class LoginStage extends StatelessWidget {
  const LoginStage({super.key, required this.host});
  final AuthStageHost host;

  @override
  Widget build(BuildContext context) => ClipRect(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: host.anim.replayIntro,
          child: CustomPaint(
            key: host.stageKey,
            painter: StagePainter(host.anim),
            size: Size.infinite,
          ),
        ),
      );
}