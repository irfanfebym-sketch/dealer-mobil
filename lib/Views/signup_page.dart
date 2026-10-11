import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';
import 'package:flutter_application_1/style/style_signup_stage.dart';
import 'package:flutter_application_1/Views/home_page.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _stage = SignUpStageController();

  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  // Tombol mata tidak boleh mengambil fokus dari kolom password.
  final _toggleF1 = FocusNode(canRequestFocus: false, skipTraversal: true);
  final _toggleF2 = FocusNode(canRequestFocus: false, skipTraversal: true);

  bool _show = false, _busy = false, _isError = false;
  String _msg = '';

  @override
  void dispose() {
    _stage.dispose();
    _nama.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _toggleF1.dispose();
    _toggleF2.dispose();
    super.dispose();
  }

  // Setiap kolom yang terisi benar membuat mobil maju satu langkah.
  void _onChanged() {
    if (_msg.isNotEmpty) setState(() => _msg = '');
    var n = 0;
    final nama = _nama.text.trim();
    if (nama.length >= 4 && nama.length <= 13) n++;
    if (kEmailRegex.hasMatch(_email.text.trim())) n++;
    if (_pass.text.length >= 6) n++;
    if (_confirm.text.isNotEmpty && _confirm.text == _pass.text) n++;
    _stage.setFilled(n);
  }

  void _showError(String pesan) {
    setState(() {
      _isError = true;
      _msg = pesan;
    });
    _stage.error();
  }

  /// Mengembalikan teks error pertama, atau null kalau semua isian valid.
  String? _validasi() {
    final nama = _nama.text.trim();
    if (nama.length < 4 || nama.length > 13) {
      return 'Username harus 4 sampai 13 karakter.';
    }
    if (!kEmailRegex.hasMatch(_email.text.trim())) {
      return 'Format email belum benar. Contoh: nama@contoh.com';
    }
    if (_pass.text.length < 6) return 'Password minimal 6 karakter.';
    if (_pass.text != _confirm.text) return 'Konfirmasi password tidak sama.';
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;

    final salah = _validasi();
    if (salah != null) {
      _showError(salah);
      return;
    }

    setState(() {
      _busy = true;
      _msg = '';
    });

    final error = await Get.find<AuthController>().registerAccount(
      namaUser: _nama.text,
      emailUser: _email.text,
      passwordUser: _pass.text,
    );
    if (!mounted) return;

    if (error != null) {
      setState(() => _busy = false);
      _showError(error);
      return;
    }

    setState(() {
      _isError = false;
      _msg = 'Akun dibuat. Mobilmu masuk garasi…';
    });
    _stage.win();

    // Beri waktu mobil masuk garasi dan pintu menutup (sekitar 2 detik).
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    Get.offAll(() => HomePage());
    Get.snackbar(
      'Berhasil',
      'Akun kamu sudah dibuat. Selamat datang!',
      backgroundColor: kShirt,
      colorText: Colors.white,
    );
  }

  Widget _panel(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeading(
          title: 'Buat akun baru',
          subtitle: 'Daftar untuk membuka detail unit Honda.',
        ),
        TextField(
          controller: _nama,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onChanged: (_) => _onChanged(),
          decoration: authDecoration('Username', '4 sampai 13 karakter'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => _onChanged(),
          decoration: authDecoration('Email', 'nama@contoh.com'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pass,
          obscureText: !_show,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) => _onChanged(),
          decoration: authDecoration(
            'Password',
            'Minimal 6 karakter',
            suffix: authToggle(_toggleF1, _show, () => setState(() => _show = !_show)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirm,
          obscureText: !_show,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) => _onChanged(),
          onSubmitted: (_) => _submit(),
          decoration: authDecoration(
            'Konfirmasi password',
            'Ulangi password',
            suffix: authToggle(_toggleF2, _show, () => setState(() => _show = !_show)),
          ),
        ),
        const SizedBox(height: 6),
        AuthMessage(msg: _msg, isError: _isError),
        const SizedBox(height: 6),
        AuthButton(label: 'Daftar', busy: _busy, onPressed: _submit),
        const SizedBox(height: 14),
        AuthLink(
          text: 'Sudah punya akun?',
          action: 'Masuk',
          onTap: () => Get.back(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      stage: SignUpStage(controller: _stage),
      panelBuilder: _panel,
      wideHeight: 680,
    );
  }
}