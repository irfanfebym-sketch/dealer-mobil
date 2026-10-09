import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

enum AccessLevel { guest, registered, complete }

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rx<AccessLevel> accessLevel = AccessLevel.guest.obs;

  final RxString uid = ''.obs;
  final RxString role = 'user'.obs; // 'user' atau 'admin'

  final RxString nama = ''.obs;
  final RxString email = ''.obs;

  final RxString nik = ''.obs;
  final RxString noKK = ''.obs;
  final RxString noHp = ''.obs;
  final RxString alamat = ''.obs;

  bool get isGuest => accessLevel.value == AccessLevel.guest;

  bool get isRegistered =>
      accessLevel.value.index >= AccessLevel.registered.index;

  bool get isComplete => accessLevel.value == AccessLevel.complete;

  bool get isAdmin => role.value == 'admin';

  Future<void> restoreSession() async {
    try {
      final user = await _auth.authStateChanges().first;
      if (user != null) {
        await _loadProfile(user);
      }
    } catch (_) {
    }
  }

  Future<String?> registerAccount({
    required String namaUser,
    required String emailUser,
    required String passwordUser,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailUser.trim(),
        password: passwordUser,
      );
      final user = cred.user!;
      await user.updateDisplayName(namaUser.trim());

      await _db.collection('users').doc(user.uid).set({
        'nama': namaUser.trim(),
        'email': emailUser.trim(),
        'role': 'user',
        'level': 'registered',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadProfile(user);
      return null;
    } on FirebaseAuthException catch (e) {
      return _pesanError(e);
    } on FirebaseException catch (e) {
      return 'Akun dibuat, tetapi data profil gagal disimpan (${e.code}).';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }


  Future<String?> login({
    required String emailUser,
    required String passwordUser,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: emailUser.trim(),
        password: passwordUser,
      );
      await _loadProfile(cred.user!);
      return null;
    } on FirebaseAuthException catch (e) {
      return _pesanError(e);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> completeProfile({
    required String nikUser,
    required String noKKUser,
    required String noHpUser,
    required String alamatUser,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'Sesi login tidak ditemukan. Silakan login ulang.';
    }
    try {
      await _db.collection('users').doc(user.uid).update({
        'nik': nikUser,
        'noKK': noKKUser,
        'noHp': noHpUser,
        'alamat': alamatUser,
        'level': 'complete',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      nik.value = nikUser;
      noKK.value = noKKUser;
      noHp.value = noHpUser;
      alamat.value = alamatUser;
      accessLevel.value = AccessLevel.complete;
      return null;
    } on FirebaseException catch (e) {
      return 'Data diri gagal disimpan (${e.code}).';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _resetState();
  }

  Future<void> _loadProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data();

    uid.value = user.uid;
    email.value = user.email ?? '';
    nama.value = (data?['nama'] as String?) ?? user.displayName ?? '';
    role.value = (data?['role'] as String?) ?? 'user';

    nik.value = (data?['nik'] as String?) ?? '';
    noKK.value = (data?['noKK'] as String?) ?? '';
    noHp.value = (data?['noHp'] as String?) ?? '';
    alamat.value = (data?['alamat'] as String?) ?? '';

    accessLevel.value = (data?['level'] == 'complete')
        ? AccessLevel.complete
        : AccessLevel.registered;
  }

  void _resetState() {
    accessLevel.value = AccessLevel.guest;
    uid.value = '';
    role.value = 'user';
    nama.value = '';
    email.value = '';
    nik.value = '';
    noKK.value = '';
    noHp.value = '';
    alamat.value = '';
  }

  String _pesanError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'operation-not-allowed':
        return 'Login Email/Password belum diaktifkan di Firebase Console.';
      default:
        return 'Terjadi kesalahan (${e.code}).';
    }
  }
}
