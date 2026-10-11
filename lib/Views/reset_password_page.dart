import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/style/style_auth_stage.dart';
import 'package:flutter_application_1/style/style_reset_stage.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _stage = ResetStageController();
  final _email = TextEditingController();

  bool _busy = false, _isError = false;
  String _msg = '';

  @override
  void dispose() {
    _stage.dispose();
    _email.dispose();
    super.dispose();
  }

  // Gembok bergoyang selama email diketik, diam lagi kalau kolom kosong.
  void _onChanged() {
    if (_msg.isNotEmpty) setState(() => _msg = '');
    _stage.setPhase(
      _email.text.isEmpty ? ResetPhase.idle : ResetPhase.typing,
    );
  }

  void _showError(String pesan) {
    setState(() {
      _isError = true;
      _msg = pesan;
    });
    _stage.setPhase(ResetPhase.error);
  }

  Future<void> _submit() async {
    if (_busy) return;

    final email = _email.text.trim();
    if (!kEmailRegex.hasMatch(email)) {
      _showError('Format email belum benar. Contoh: nama@contoh.com');
      return;
    }

    setState(() {
      _busy = true;
      _msg = '';
    });
    _stage.setPhase(ResetPhase.sending);

    final error = await Get.find<AuthController>().sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      _showError(error);
      return;
    }

    setState(() {
      _isError = false;
      _msg = 'Jika email terdaftar, link reset sudah dikirim. '
          'Cek inbox dan folder spam.';
    });
    _stage.setPhase(ResetPhase.sent);
  }

  Widget _panel(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeading(
          title: 'Lupa password?',
          subtitle: 'Masukkan email akunmu. Kami kirim link untuk membuat '
              'password baru.',
        ),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => _onChanged(),
          onSubmitted: (_) => _submit(),
          decoration: authDecoration('Email', 'nama@contoh.com'),
        ),
        const SizedBox(height: 12),
        AuthMessage(msg: _msg, isError: _isError),
        const SizedBox(height: 6),
        AuthButton(label: 'Kirim link reset', busy: _busy, onPressed: _submit),
        const SizedBox(height: 14),
        AuthLink(
          text: 'Ingat password?',
          action: 'Kembali ke login',
          onTap: () => Get.back(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      stage: ResetStage(controller: _stage),
      panelBuilder: _panel,
    );
  }
}