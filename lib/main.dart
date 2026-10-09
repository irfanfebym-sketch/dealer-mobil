import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/Controller/auth_controller.dart';
import 'package:flutter_application_1/Views/home_page.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (Firebase) di dalam main().
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = Get.put(AuthController(), permanent: true);

  // Cek apakah ada sesi login yang tersimpan di browser. Kalau ada, level
  // akses dipulihkan dari Firestore, jadi refresh tidak lagi jadi guest.
  await auth.restoreSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Icikiwir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}
