import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';
import 'package:flutter_application_1/style/style_login_stage.dart';
import 'package:flutter_application_1/Views/home_page.dart';
import 'package:flutter_application_1/Views/signup_page.dart';
import 'package:flutter_application_1/Views/reset_password_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final AuthStageHost _host;

  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _emailF = FocusNode();
  final _passF = FocusNode();
  // Tombol mata tidak boleh mengambil fokus dari kolom password.
  final _toggleF = FocusNode(canRequestFocus: false, skipTraversal: true);

  bool _show = false, _busy = false, _isError = false;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _host = AuthStageHost(vsync: this);
    _emailF.addListener(_syncFocus);
    _passF.addListener(_syncFocus);
  }

  @override
  void dispose() {
    _host.dispose();
    _email.dispose();
    _pass.dispose();
    _emailF.dispose();
    _passF.dispose();
    _toggleF.dispose();
    super.dispose();
  }

  void _syncFocus() {
    final a = _host.anim;
    if (_emailF.hasFocus) {
      a.mode = StageMode.email;
    } else if (_passF.hasFocus) {
      a.mode = _show ? StageMode.peek : StageMode.pass;
    } else {
      a.mode = StageMode.idle;
    }
  }

  void _toggle() {
    setState(() => _show = !_show);
    _passF.requestFocus();
    _host.anim.mode = _show ? StageMode.peek : StageMode.pass;
  }

  void _clearMsg() {
    if (_msg.isNotEmpty) setState(() => _msg = '');
  }

  void _showError(String pesan) {
    setState(() {
      _isError = true;
      _msg = pesan;
    });
    _host.anim.mode = StageMode.error;
    _host.anim.triggerError();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted && _host.anim.mode == StageMode.error) _syncFocus();
    });
  }

  Future<void> _submit() async {
    if (_busy) return;

    final email = _email.text.trim();
    if (!kEmailRegex.hasMatch(email)) {
      _showError('Format email belum benar. Contoh: nama@contoh.com');
      return;
    }
    if (_pass.text.length < 6) {
      _showError('Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _busy = true;
      _msg = '';
    });

    final error = await Get.find<AuthController>().login(
      emailUser: email,
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
      _msg = 'Berhasil masuk. Mengalihkan…';
    });
    _host.anim.mode = StageMode.ok;
    _host.anim.triggerOk();

    // Beri waktu animasi senang sebelum pindah ke beranda.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Get.offAll(() => HomePage());
  }

  Widget _panel(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeading(
          title: 'Selamat datang kembali',
          subtitle: 'Masuk untuk melihat detail unit dan melanjutkan pembelian.',
        ),
        TextField(
          key: _host.emailKey,
          controller: _email,
          focusNode: _emailF,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => _clearMsg(),
          decoration: authDecoration('Email', 'nama@contoh.com'),
        ),
        const SizedBox(height: 18),
        TextField(
          key: _host.passKey,
          controller: _pass,
          focusNode: _passF,
          obscureText: !_show,
          autofillHints: const [AutofillHints.password],
          onChanged: (_) => _clearMsg(),
          onSubmitted: (_) => _submit(),
          decoration: authDecoration(
            'Password',
            'Minimal 6 karakter',
            suffix: authToggle(_toggleF, _show, _toggle),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => const ResetPasswordPage()),
            style: TextButton.styleFrom(foregroundColor: kShirt),
            child: const Text(
              'Lupa password?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        AuthMessage(msg: _msg, isError: _isError),
        const SizedBox(height: 6),
        AuthButton(label: 'Masuk', busy: _busy, onPressed: _submit),
        const SizedBox(height: 14),
        AuthLink(
          text: 'Belum punya akun?',
          action: 'Daftar',
          onTap: () => Get.to(() => const SignUpView()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Kursor di mana saja di halaman diikuti oleh mata karakter.
      onHover: (e) => _host.anim.pointer = e.position,
      child: AuthLayout(stage: LoginStage(host: _host), panelBuilder: _panel),
    );
  }
}