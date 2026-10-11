import 'package:flutter/material.dart';

const kInk = Color(0xFF1D2030);
const kMuted = Color(0xFF666B82);
const kLine = Color(0xFFCDD1E1);
const kStageBg = Color(0xFFDFE3EF);
const kPageBg = Color(0xFFE7E9F1);
const kErr = Color(0xFFD2402F);
const kOk = Color(0xFF12805C);
const kShirt = Color(0xFFE02F3A); // warna baju merah
const kShirtDark = Color(0xFFA81E2A); // kerah & kancing
const kRope = Color(0xFF8A6A47); // tali gelantungan

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.stage,
    required this.panelBuilder,
    this.wideHeight = 560,
  });

  final Widget stage;
  final Widget Function(bool wide) panelBuilder;
  final double wideHeight;

  Widget _stage() => Container(
        color: kStageBg,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: stage,
      );

  Widget _panel(bool wide) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 52 : 26,
          vertical: wide ? 48 : 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [panelBuilder(wide)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final canBack = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: kPageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canBack)
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Kembali'),
                      style: TextButton.styleFrom(foregroundColor: kMuted),
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: ColoredBox(
                      color: Colors.white,
                      child: LayoutBuilder(builder: (context, box) {
                        final wide = box.maxWidth >= 760;
                        if (wide) {
                          return SizedBox(
                            height: wideHeight,
                            child: Row(children: [
                              Expanded(flex: 105, child: _stage()),
                              Expanded(
                                flex: 100,
                                child: Center(
                                  child: SingleChildScrollView(child: _panel(true)),
                                ),
                              ),
                            ]),
                          );
                        }
                        return Column(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(height: 250, width: double.infinity, child: _stage()),
                          _panel(false),
                        ]);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration authDecoration(String label, String hint, {Widget? suffix}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      labelStyle: const TextStyle(color: kMuted),
      floatingLabelStyle: const TextStyle(color: kInk, fontWeight: FontWeight.w600),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: kLine, width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: kInk, width: 2),
      ),
    );

Widget authToggle(FocusNode focusNode, bool show, VoidCallback onTap) =>
    IconButton(
      focusNode: focusNode,
      tooltip: show ? 'Sembunyikan password' : 'Tampilkan password',
      icon: Icon(
        show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: kMuted,
      ),
      onPressed: onTap,
    );

class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.1,
              color: kInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 15, color: kMuted)),
          const SizedBox(height: 28),
        ],
      );
}

/// Baris pesan (error merah / sukses hijau). Tinggi tetap supaya layout stabil.
class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, required this.msg, required this.isError});
  final String msg;
  final bool isError;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            msg,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: isError ? kErr : kOk),
          ),
        ),
      );
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: kInk,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kInk.withOpacity(0.55),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label),
      );
}

/// Teks tautan di bawah tombol, contoh: "Belum punya akun? Daftar".
class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });
  final String text, action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 14, color: kMuted)),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: kShirt,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 36),
              ),
              child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}

final RegExp kEmailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');