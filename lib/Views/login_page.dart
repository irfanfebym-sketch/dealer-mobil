import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Controller/simple_ui.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/style/style_login.dart';
import 'package:flutter_application_1/Views/home_page.dart';
import 'package:flutter_application_1/Views/signup_page.dart';
import 'package:flutter_application_1/Views/reset_password_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  static const Color kHondaRed = Color.fromARGB(255, 228, 5, 33);
  static const Color kAbu = Color.fromARGB(255, 107, 101, 101);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await Get.find<AuthController>().login(
      emailUser: emailController.text,
      passwordUser: passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      Get.snackbar(
        'Login gagal',
        error,
        backgroundColor: kHondaRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.offAll(() => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    SimpleUIController simpleUIController = Get.put(SimpleUIController());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 246, 246),
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildLargeScreen(size, simpleUIController);
            } else {
              return _buildSmallScreen(size, simpleUIController);
            }
          },
        ),
      ),
    );
  }

  // Large Screen
  Widget _buildLargeScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/honda_image.jpg',
                height: size.height * 0.8,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.08),
          Expanded(
            flex: 5,
            child: _buildMainBody(size, simpleUIController),
          ),
        ],
      ),
    );
  }

  // Small Screen
  Widget _buildSmallScreen(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Center(
      child: _buildMainBody(size, simpleUIController),
    );
  }

  /// Main Body
  Widget _buildMainBody(
    Size size,
    SimpleUIController simpleUIController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          size.width > 600 ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        size.width > 600
            ? Container()
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/honda_image.jpg',
                  height: size.height * 0.2,
                  width: size.width,
                  fit: BoxFit.cover,
                ),
              ),
        SizedBox(height: size.height * 0.03),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LOGIN',
                style: TextStyle(
                  color: Color.fromARGB(150, 0, 0, 0),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keluarga Honda',
                style: kmyLoginTextStyle(size),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Selamat Datang Kembali di Dealer Honda Terpercaya',
            style: kmyTitleTextStyle(size),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Email
                TextFormField(
                  style: kTextFormFieldStyle(),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dekorasi(hint: 'Email', icon: Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),

                /// Password
                Obx(
                  () => TextFormField(
                    style: kTextFormFieldStyle(),
                    controller: passwordController,
                    obscureText: simpleUIController.isObscure.value,
                    decoration: _dekorasi(
                      hint: 'Password',
                      icon: Icons.lock_open,
                      focusColor: kAbu,
                      suffix: IconButton(
                        icon: Icon(
                          simpleUIController.isObscure.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          simpleUIController.isObscureActive();
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const ResetPasswordPage());
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: kHondaRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                loginButton(),
                SizedBox(height: size.height * 0.03),

                GestureDetector(
                  onTap: () {
                    emailController.clear();
                    passwordController.clear();
                    _formKey.currentState?.reset();
                    simpleUIController.isObscure.value = true;
                    Get.to(() => const SignUpView());
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account?',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                      children: [
                        TextSpan(
                          text: ' Sign up',
                          style: kLoginOrSignUpTextStyle(size),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Login Button
  Widget loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(kHondaRed),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        onPressed: _loading ? null : _submit,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
      ),
    );
  }

  InputDecoration _dekorasi({
    required String hint,
    required IconData icon,
    Widget? suffix,
    Color focusColor = Colors.black,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kAbu),
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: suffix,
      enabledBorder: border(kAbu),
      focusedBorder: border(focusColor),
      border: border(kAbu),
    );
  }
}
